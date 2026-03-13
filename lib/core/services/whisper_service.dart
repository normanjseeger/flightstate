import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'file_cleanup_stub.dart'
    if (dart.library.io) 'file_cleanup_io.dart'
    if (dart.library.html) 'file_cleanup_web.dart';

/// Service for transcribing audio files using the OpenAI Whisper API.
///
/// This service handles:
/// - Uploading audio files/data to the OpenAI Whisper API
/// - Processing transcription responses
/// - Error handling for API failures
/// - Automatic cleanup of temporary audio files (native only)
///
/// Platform support:
/// - Native (iOS/Android): Works with file paths
/// - Web: Works with blob URLs from the recorder
class WhisperService {
  final String apiKey;
  static const String _baseUrl = 'https://api.openai.com/v1/audio/transcriptions';

  WhisperService(this.apiKey);

  /// Transcribe audio using the Whisper API.
  ///
  /// [audioFilePath]: Path to audio file (native) or blob URL (web).
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
    print('DEBUG: Transcribing audio from: $audioFilePath');

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

    // Add audio file - different handling for web vs native
    if (kIsWeb) {
      // Web: Fetch the blob URL and send bytes
      try {
        final response = await http.get(Uri.parse(audioFilePath));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          print('DEBUG: Audio file size: ${bytes.length} bytes');

          if (bytes.isEmpty) {
            throw WhisperException('Audio recording is empty. Please try again.');
          }

          request.files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'audio.wav',
          ));
        } else {
          throw WhisperException('Failed to read audio data');
        }
      } catch (e) {
        if (e is WhisperException) rethrow;
        throw WhisperException('Failed to prepare audio for upload: $e');
      }
    } else {
      // Native: Use file path directly
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        audioFilePath,
      ));
    }

    try {
      print('DEBUG: Sending audio to Whisper API...');

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

        // Clean up temp file (no-op on web)
        await deleteFileIfExists(audioFilePath);

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

        // Clean up temp file (no-op on web)
        await deleteFileIfExists(audioFilePath);

        throw WhisperException(
          'API Error ${response.statusCode}: $errorMessage',
        );
      }
    } catch (e) {
      // Clean up temp file (no-op on web)
      await deleteFileIfExists(audioFilePath);

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
