import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Exception thrown when voice input operations fail
class VoiceInputException implements Exception {
  final String message;

  VoiceInputException(this.message);

  @override
  String toString() => message;
}

/// Service for handling speech-to-text voice input
class VoiceInputService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  /// Initialize the speech recognition service
  /// Returns true if initialization was successful
  /// Returns false if platform doesn't support speech recognition (e.g., web, simulator)
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) {
          // Log error but don't throw - just mark as not initialized
          _isInitialized = false;
        },
        onStatus: (status) {
          // Status updates are handled by the listening callback
        },
      );
      return _isInitialized;
    } catch (e) {
      // Platform doesn't support speech recognition - return false instead of throwing
      _isInitialized = false;
      return false;
    }
  }

  /// Check microphone permission status
  Future<PermissionStatus> checkPermission() async {
    return await Permission.microphone.status;
  }

  /// Request microphone permission if not granted
  Future<PermissionStatus> requestPermission() async {
    final status = await checkPermission();

    if (status.isGranted) {
      return status;
    }

    if (status.isPermanentlyDenied) {
      throw VoiceInputException(
        'Microphone permission permanently denied. Please enable it in Settings.'
      );
    }

    final result = await Permission.microphone.request();

    if (!result.isGranted) {
      throw VoiceInputException('Microphone permission denied');
    }

    return result;
  }

  /// Start listening with a callback for real-time transcription updates
  /// This allows manual control of when to stop listening
  Future<bool> startListeningWithCallback({
    required Function(String transcription) onResult,
    required Function(String error) onError,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // Ensure initialized
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError('Speech recognition is not available. Please use Chrome or Safari.');
        return false;
      }
    }

    // Check if available
    if (!_speech.isAvailable) {
      onError('Speech recognition is not initialized. Please refresh and try again.');
      return false;
    }

    // Start listening (browser will request permission if needed)
    try {
      print('🎤 Starting speech recognition...');

      final success = await _speech.listen(
        onResult: (result) {
          print('🎤 Got result: ${result.recognizedWords}');
          onResult(result.recognizedWords);
        },
        listenFor: timeout,
        pauseFor: const Duration(seconds: 5),
        onSoundLevelChange: (level) {
          print('🎤 Sound level: $level');
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.confirmation,
        ),
      );

      print('🎤 Listen started: $success');

      // On web, listen() may return null instead of bool
      // If it returns false explicitly, that's an error
      if (success == false) {
        // Get more specific error
        final lastError = _speech.lastError;
        if (lastError != null) {
          onError('Error: ${lastError.errorMsg}. Please allow microphone access when prompted.');
        } else {
          onError('Could not start microphone. Click "Allow" when browser asks for permission.');
        }
        return false;
      }

      // null or true both mean success on web
      print('🎤 Speech recognition started successfully');
      return true;
    } catch (e) {
      print('🎤 Exception: $e');
      onError('Error starting speech: $e');
      return false;
    }
  }

  /// Start listening for speech input and return the transcribed text
  /// Throws VoiceInputException on errors
  Future<String> startListening({Duration timeout = const Duration(seconds: 30)}) async {
    // Ensure initialized
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw VoiceInputException('Speech recognition not available on this device');
      }
    }

    // Check and request permission
    final permission = await requestPermission();
    if (!permission.isGranted) {
      throw VoiceInputException('Microphone permission is required for voice input');
    }

    // Check if speech recognition is available
    if (!await _speech.hasPermission) {
      throw VoiceInputException('Speech recognition permission denied');
    }

    final completer = Completer<String>();
    String transcription = '';

    // Start listening
    try {
      await _speech.listen(
        onResult: (result) {
          transcription = result.recognizedWords;

          // Complete when final result is received
          if (result.finalResult && !completer.isCompleted) {
            completer.complete(transcription);
          }
        },
        listenFor: timeout,
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
      );
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(
          VoiceInputException('Failed to start listening: $e')
        );
      }
    }

    // Wait for result or timeout
    try {
      final result = await completer.future.timeout(
        timeout,
        onTimeout: () {
          // Return partial results if we have any
          if (transcription.isNotEmpty) {
            return transcription;
          }
          throw VoiceInputException('Voice input timed out. Please try again.');
        },
      );

      // Stop listening
      await stopListening();

      if (result.isEmpty) {
        throw VoiceInputException('No speech detected. Please try again.');
      }

      return result;
    } catch (e) {
      await stopListening();
      if (e is VoiceInputException) {
        rethrow;
      }
      throw VoiceInputException('Voice input failed: $e');
    }
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Check if currently listening
  bool get isListening => _speech.isListening;

  /// Check if speech recognition is available on this device
  Future<bool> isAvailable() async {
    return await _speech.initialize();
  }

  /// Dispose of resources
  void dispose() {
    _speech.cancel();
  }
}
