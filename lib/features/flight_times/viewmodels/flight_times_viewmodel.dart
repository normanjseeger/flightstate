import 'package:flutter/material.dart';
import '../../../core/services/audio_recording_service.dart';
import '../../../core/services/whisper_service.dart';
import '../../../core/services/voice_command_parser.dart';

/// Input mode for HOBBS/Flight time values.
enum InputMode { direct, readings }

class FlightTimesViewModel extends ChangeNotifier {
  // Voice input services
  late final AudioRecordingService _audioService;
  WhisperService? _whisperService;
  late final VoiceCommandParser _parser;
  // Input mode toggle
  InputMode _inputMode = InputMode.direct;
  InputMode get inputMode => _inputMode;

  // Block On time (UTC)
  TimeOfDay _blockOnUtc = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay get blockOnUtc => _blockOnUtc;

  // Direct mode: decimal hours difference
  double _hobbsDiff = 0.0;
  double get hobbsDiff => _hobbsDiff;

  double _vutDiff = 0.0;
  double get vutDiff => _vutDiff;

  // Readings mode: start + end values
  double _hobbsStart = 0.0;
  double get hobbsStart => _hobbsStart;

  double _hobbsEnd = 0.0;
  double get hobbsEnd => _hobbsEnd;

  double _vutStart = 0.0;
  double get vutStart => _vutStart;

  double _vutEnd = 0.0;
  double get vutEnd => _vutEnd;

  // UTC offset: 1 (winter) or 2 (summer)
  int _utcOffsetHours = 1;
  int get utcOffsetHours => _utcOffsetHours;

  // Taxi time in minutes
  int _taxiMinutes = 3;
  int get taxiMinutes => _taxiMinutes;

  // Voice input state
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isVoiceAvailable = false;
  String _currentTranscription = '';
  String? _voiceError;

  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  bool get isVoiceAvailable => _isVoiceAvailable && _whisperService != null;
  String get currentTranscription => _currentTranscription;
  String? get voiceError => _voiceError;

  // Audio amplitude stream for visual feedback
  Stream<double>? get audioAmplitudeStream {
    if (!_isRecording) return null;
    return _audioService.amplitudeStream.map((amplitude) {
      // Convert Amplitude object to double (0.0 to 1.0)
      // The current value typically ranges from -160 (silence) to 0 (loud)
      final current = amplitude.current;
      final normalized = ((current + 160) / 160).clamp(0.0, 1.0);
      return normalized;
    });
  }

  // Constructor
  FlightTimesViewModel() {
    _audioService = AudioRecordingService();
    _parser = VoiceCommandParser();
    _initializeVoice();
  }

  Future<void> _initializeVoice() async {
    final hasPermission = await _audioService.hasPermission();
    _isVoiceAvailable = hasPermission;
    notifyListeners();
  }

  /// Request microphone permission explicitly
  Future<bool> requestMicrophonePermission() async {
    final hasPermission = await _audioService.hasPermission();
    if (!hasPermission) {
      print('DEBUG: Microphone permission denied or not requested');
    } else {
      print('DEBUG: Microphone permission granted');
    }
    _isVoiceAvailable = hasPermission;
    notifyListeners();
    return hasPermission;
  }

  /// Inject WhisperService when API key is available
  void setApiKey(String apiKey) {
    _whisperService = WhisperService(apiKey);
    notifyListeners();
  }

  // --- Computed values ---

  /// Effective HOBBS hours (decimal).
  double get hobbsHours =>
      _inputMode == InputMode.direct ? _hobbsDiff : (_hobbsEnd - _hobbsStart);

  /// Effective Flight time hours (decimal).
  double get vutHours =>
      _inputMode == InputMode.direct ? _vutDiff : (_vutEnd - _vutStart);

  /// HOBBS time formatted as hh:mm.
  String get hobbsFormatted => _decimalHoursToHhMm(hobbsHours);

  /// Flight time formatted as hh:mm.
  String get vutFormatted => _decimalHoursToHhMm(vutHours);

  /// Block Off (UTC) = Block On - HOBBS time.
  TimeOfDay get blockOffUtc => _subtractMinutes(_blockOnUtc, _decimalToMinutes(hobbsHours));

  /// Arrival (UTC) = Block On - taxi time.
  TimeOfDay get arrivalUtc => _subtractMinutes(_blockOnUtc, _taxiMinutes);

  /// Takeoff (UTC) = Arrival - Flight time.
  TimeOfDay get takeoffUtc => _subtractMinutes(arrivalUtc, _decimalToMinutes(vutHours));

  /// Local time variants (UTC + offset).
  TimeOfDay get blockOnLocal => _addMinutes(_blockOnUtc, _utcOffsetHours * 60);
  TimeOfDay get blockOffLocal => _addMinutes(blockOffUtc, _utcOffsetHours * 60);
  TimeOfDay get arrivalLocal => _addMinutes(arrivalUtc, _utcOffsetHours * 60);
  TimeOfDay get takeoffLocal => _addMinutes(takeoffUtc, _utcOffsetHours * 60);

  // --- Setters ---

  void setInputMode(InputMode mode) {
    _inputMode = mode;
    notifyListeners();
  }

  void setBlockOnUtc(TimeOfDay time) {
    _blockOnUtc = time;
    notifyListeners();
  }

  void setHobbsDiff(double value) {
    _hobbsDiff = value;
    notifyListeners();
  }

  void setVutDiff(double value) {
    _vutDiff = value;
    notifyListeners();
  }

  void setHobbsStart(double value) {
    _hobbsStart = value;
    notifyListeners();
  }

  void setHobbsEnd(double value) {
    _hobbsEnd = value;
    notifyListeners();
  }

  void setVutStart(double value) {
    _vutStart = value;
    notifyListeners();
  }

  void setVutEnd(double value) {
    _vutEnd = value;
    notifyListeners();
  }

  void setUtcOffsetHours(int offset) {
    _utcOffsetHours = offset;
    notifyListeners();
  }

  void setTaxiMinutes(int minutes) {
    _taxiMinutes = minutes;
    notifyListeners();
  }

  // --- Helpers ---

  static int _decimalToMinutes(double decimalHours) {
    return (decimalHours * 60).round();
  }

  static String _decimalHoursToHhMm(double decimalHours) {
    final totalMinutes = _decimalToMinutes(decimalHours.abs());
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    final sign = decimalHours < 0 ? '-' : '';
    return '$sign${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static TimeOfDay _subtractMinutes(TimeOfDay time, int minutes) {
    final totalMins = (time.hour * 60 + time.minute - minutes) % 1440;
    final adjusted = totalMins < 0 ? totalMins + 1440 : totalMins;
    return TimeOfDay(hour: adjusted ~/ 60, minute: adjusted % 60);
  }

  static TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final totalMins = (time.hour * 60 + time.minute + minutes) % 1440;
    final adjusted = totalMins < 0 ? totalMins + 1440 : totalMins;
    return TimeOfDay(hour: adjusted ~/ 60, minute: adjusted % 60);
  }

  /// Format TimeOfDay as HH:MM.
  static String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // --- Voice Input Methods ---

  /// Start recording voice input
  Future<void> startVoiceInput() async {
    if (_whisperService == null) {
      _voiceError = 'Please configure OpenAI API key in Settings';
      notifyListeners();
      return;
    }

    // Check microphone permission (record package handles the request)
    print('DEBUG: Checking microphone permission...');
    final hasPermission = await _audioService.hasPermission();
    print('DEBUG: Has permission: $hasPermission');

    if (!hasPermission) {
      _voiceError = 'Microphone permission required.\n\nPlease:\n1. Close this dialog\n2. Go to System Settings → Privacy & Security → Microphone\n3. Manually add FlightState to the list\n4. Enable the checkbox\n5. Try again';
      notifyListeners();
      return;
    }

    _voiceError = null;
    _currentTranscription = '';
    _isRecording = true;
    notifyListeners();

    try {
      print('DEBUG: Starting audio recording...');
      await _audioService.startRecording();
      print('DEBUG: Recording started successfully');
    } catch (e) {
      print('DEBUG: Failed to start recording: $e');
      _voiceError = 'Failed to start recording: $e';
      _isRecording = false;
      notifyListeners();
    }
  }

  /// Stop recording and transcribe with Whisper API
  Future<void> stopVoiceInput() async {
    if (!_isRecording) return;

    _isRecording = false;
    _isProcessing = true;
    notifyListeners();

    try {
      // Stop recording and get file path
      final audioFilePath = await _audioService.stopRecording();

      if (audioFilePath == null || audioFilePath.isEmpty) {
        throw Exception('No audio recorded. Please try again.');
      }

      print('DEBUG: Audio file path: $audioFilePath');

      // Transcribe with Whisper API with timeout
      final transcription = await _whisperService!.transcribe(
        audioFilePath: audioFilePath,
        language: 'en',
        prompt: 'Aviation flight log: HOBBS meter, Flight time hours, block on time',
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Transcription timed out after 30 seconds. Please check your internet connection.');
        },
      );

      print('DEBUG: Transcription received: $transcription');
      _currentTranscription = transcription;

      // Parse transcription using existing parser
      final result = _parser.parse(transcription);

      if (result.hasError) {
        _voiceError = result.errorMessage;
      } else {
        _applyVoiceData(result.data!);
        _voiceError = null;
      }
    } on WhisperException catch (e) {
      print('DEBUG: WhisperException: ${e.message}');
      _voiceError = 'Transcription failed: ${e.message}';
    } catch (e) {
      print('DEBUG: Error: $e');
      _voiceError = 'Error: $e';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Cancel recording without transcribing
  Future<void> cancelVoiceInput() async {
    if (_isRecording) {
      await _audioService.stopRecording();
      _isRecording = false;
      _currentTranscription = '';
      _voiceError = null;
      notifyListeners();
    }
  }

  /// Apply parsed voice data to the view model
  void _applyVoiceData(FlightTimesVoiceData data) {
    // Apply input mode
    if (data.mode != null) {
      _inputMode = data.mode!;
    }

    // Apply direct mode values
    if (data.hobbsDiff != null) {
      _hobbsDiff = data.hobbsDiff!;
    }
    if (data.vutDiff != null) {
      _vutDiff = data.vutDiff!;
    }

    // Apply readings mode values
    if (data.hobbsStart != null) {
      _hobbsStart = data.hobbsStart!;
    }
    if (data.hobbsEnd != null) {
      _hobbsEnd = data.hobbsEnd!;
    }
    if (data.vutStart != null) {
      _vutStart = data.vutStart!;
    }
    if (data.vutEnd != null) {
      _vutEnd = data.vutEnd!;
    }

    // Apply common values
    if (data.blockOnUtc != null) {
      _blockOnUtc = data.blockOnUtc!;
    }
    if (data.taxiMinutes != null) {
      _taxiMinutes = data.taxiMinutes!;
    }
    if (data.utcOffsetHours != null) {
      _utcOffsetHours = data.utcOffsetHours!;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
