import 'package:flutter/material.dart';

/// Input mode for HOBBS/VUT values.
enum InputMode { direct, readings }

class FlightTimesViewModel extends ChangeNotifier {
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
}
