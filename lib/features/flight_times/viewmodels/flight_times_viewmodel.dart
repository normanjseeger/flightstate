import 'package:flutter/material.dart';
import '../../../core/services/voice_input_service.dart';
import '../../../core/services/voice_command_parser.dart';

class FlightTimesViewModel extends ChangeNotifier {
  // Voice input services
  late final VoiceInputService _voiceService;
  late final VoiceCommandParser _parser;

  // Voice input state
  bool _isListening = false;
  bool get isListening => _isListening;

  bool _isVoiceAvailable = false;
  bool get isVoiceAvailable => _isVoiceAvailable;

  String? _voiceError;
  String? get voiceError => _voiceError;

  String _currentTranscription = '';
  String get currentTranscription => _currentTranscription;

  FlightTimesViewModel() {
    _voiceService = VoiceInputService();
    _parser = VoiceCommandParser();
    _initializeVoice();
  }

  Future<void> _initializeVoice() async {
    _isVoiceAvailable = await _voiceService.initialize();
    notifyListeners();
  }

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

  // --- Computed values ---

  /// Effective HOBBS hours (decimal).
  double get hobbsHours =>
      _inputMode == InputMode.direct ? _hobbsDiff : (_hobbsEnd - _hobbsStart);

  /// Effective VUT hours (decimal).
  double get vutHours =>
      _inputMode == InputMode.direct ? _vutDiff : (_vutEnd - _vutStart);

  /// HOBBS time formatted as hh:mm.
  String get hobbsFormatted => _decimalHoursToHhMm(hobbsHours);

  /// VUT time formatted as hh:mm.
  String get vutFormatted => _decimalHoursToHhMm(vutHours);

  /// Block Off (UTC) = Block On - HOBBS time.
  TimeOfDay get blockOffUtc => _subtractMinutes(_blockOnUtc, _decimalToMinutes(hobbsHours));

  /// Arrival (UTC) = Block On - taxi time.
  TimeOfDay get arrivalUtc => _subtractMinutes(_blockOnUtc, _taxiMinutes);

  /// Takeoff (UTC) = Arrival - VUT time.
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

  // --- Voice Input ---

  /// Start voice input (begins listening)
  Future<void> startVoiceInput() async {
    _voiceError = null;
    _currentTranscription = '';
    _isListening = true;
    notifyListeners();

    try {
      // Start listening with a callback to capture partial results
      final success = await _voiceService.startListeningWithCallback(
        onResult: (transcription) {
          // Only update if we got actual content (filter out empty results)
          if (transcription.trim().isNotEmpty) {
            _currentTranscription = transcription;
            _voiceError = null; // Clear any previous errors
            notifyListeners(); // Update UI with partial results
          }
        },
        onError: (error) {
          _voiceError = error;
          // Keep isListening = true so UI shows the error in the recording dialog
          notifyListeners();
        },
      );

      if (!success) {
        _voiceError = 'Failed to start speech recognition. Please check microphone permissions in your browser and click Retry.';
        // Keep isListening = true so UI shows the error with retry button
        notifyListeners();
      }
    } catch (e) {
      _voiceError = _mapErrorToUserMessage(e);
      // Keep isListening = true so UI shows the error
      notifyListeners();
    }
  }

  /// Stop voice input and process the transcription
  Future<void> stopVoiceInput() async {
    if (!_isListening) return;

    try {
      // Stop listening
      await _voiceService.stopListening();
      _isListening = false;
      notifyListeners();

      // Process the transcription
      if (_currentTranscription.isEmpty) {
        _voiceError = 'No speech detected. Please try again.';
        return;
      }

      final result = _parser.parse(_currentTranscription);

      if (result.hasError) {
        _voiceError = result.errorMessage;
      } else {
        _applyVoiceData(result.data!);
      }
    } catch (e) {
      _voiceError = _mapErrorToUserMessage(e);
    } finally {
      notifyListeners();
    }
  }

  /// Cancel voice input without processing
  Future<void> cancelVoiceInput() async {
    if (!_isListening) return;

    await _voiceService.stopListening();
    _isListening = false;
    _currentTranscription = '';
    notifyListeners();
  }

  /// Apply parsed voice data to the viewmodel
  void _applyVoiceData(FlightTimesVoiceData data) {
    // Auto-switch mode if detected
    if (data.mode != null && data.mode != _inputMode) {
      setInputMode(data.mode!);
    }

    // Apply values based on mode
    if (data.mode == InputMode.direct) {
      if (data.hobbsDiff != null) setHobbsDiff(data.hobbsDiff!);
      if (data.vutDiff != null) setVutDiff(data.vutDiff!);
    } else {
      if (data.hobbsStart != null) setHobbsStart(data.hobbsStart!);
      if (data.hobbsEnd != null) setHobbsEnd(data.hobbsEnd!);
      if (data.vutStart != null) setVutStart(data.vutStart!);
      if (data.vutEnd != null) setVutEnd(data.vutEnd!);
    }

    // Apply common values
    if (data.blockOnUtc != null) setBlockOnUtc(data.blockOnUtc!);
    if (data.taxiMinutes != null) setTaxiMinutes(data.taxiMinutes!);
    if (data.utcOffsetHours != null) setUtcOffsetHours(data.utcOffsetHours!);
  }

  /// Map error to user-friendly message
  String _mapErrorToUserMessage(dynamic error) {
    if (error is VoiceInputException) {
      return error.message;
    }
    return 'Voice input failed. Please try again.';
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
