import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for transcribing audio files using the OpenAI Whisper API.
///
/// This service handles:
/// - Uploading audio files to the OpenAI Whisper API
/// - Processing transcription responses
/// - Error handling for API failures
/// - Automatic cleanup of temporary audio files
class WhisperService {
  final String apiKey;
  static const String _baseUrl = 'https://api.openai.com/v1/audio/transcriptions';

  WhisperService(this.apiKey);

  /// Transcribe an audio file using the Whisper API.
  ///
  /// [audioFilePath]: Path to the audio file to transcribe.
  /// [language]: Language code (default: 'en' for English).
  /// [prompt]: Optional prompt to improve accuracy for specific terminology.
  ///
  /// Returns the transcribed text.
  ///
  /// Throws [WhisperException] if the API request fails.
  Future<String> transcribe({
    required String audioFilePath,
    String language = 'en',
    String? prompt,
  }) async {
    final audioFile = File(audioFilePath);

    if (!await audioFile.exists()) {
      throw WhisperException('Audio file not found: $audioFilePath');
    }

    // Check file size
    final fileSize = await audioFile.length();
    print('DEBUG: Audio file size: $fileSize bytes');

    if (fileSize == 0) {
      throw WhisperException('Audio file is empty (0 bytes). Recording may have failed.');
    }

    final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $apiKey';

    // Add form fields
    request.fields['model'] = 'whisper-1';
    request.fields['language'] = language;
    request.fields['response_format'] = 'json';

    // Add optional prompt to improve aviation term recognition
    if (prompt != null && prompt.isNotEmpty) {
      request.fields['prompt'] = prompt;
    }

    // Add audio file
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      audioFilePath,
    ));

    try {
      print('DEBUG: Sending audio file to Whisper API...');

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('DEBUG: Request timed out');
          throw WhisperException('Request timed out after 30 seconds. Please check your internet connection.');
        },
      );

      print('DEBUG: Got response, status: ${streamedResponse.statusCode}');
      final response = await http.Response.fromStream(streamedResponse);

      // Handle response
      if (response.statusCode == 200) {
        print('DEBUG: Transcription successful');
        final jsonData = json.decode(response.body);
        final text = jsonData['text'] as String;

        // Clean up temp file after successful transcription
        try {
          await audioFile.delete();
        } catch (e) {
          // Ignore cleanup errors
        }

        return text.trim();
      } else {
        // Handle API errors
        print('DEBUG: API error ${response.statusCode}: ${response.body}');
        String errorMessage = 'Unknown error';
        try {
          final errorBody = json.decode(response.body);
          errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        } catch (e) {
          errorMessage = response.body;
        }

        // Provide helpful error messages
        if (response.statusCode == 401) {
          errorMessage = 'Invalid API key. Please check your OpenAI API key in Settings.';
        } else if (response.statusCode == 429) {
          errorMessage = 'Rate limit exceeded. Please try again in a moment.';
        }

        // Clean up temp file even on error
        try {
          await audioFile.delete();
        } catch (e) {
          // Ignore cleanup errors
        }

        throw WhisperException(
          'API Error ${response.statusCode}: $errorMessage',
        );
      }
    } on SocketException catch (e) {
      // Clean up temp file on network error
      try {
        await audioFile.delete();
      } catch (_) {}
      throw WhisperException('Network error: ${e.message}');
    } catch (e) {
      // Clean up temp file on any other error
      try {
        await audioFile.delete();
      } catch (_) {}
      if (e is WhisperException) {
        rethrow;
      }
      throw WhisperException('Transcription failed: $e');
    }
  }
}

/// Exception thrown when the Whisper API request fails.
class WhisperException implements Exception {
  final String message;

  WhisperException(this.message);

  @override
  String toString() => message;
}
