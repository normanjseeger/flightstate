import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flightstate/domain/models/app_settings.dart';

class SettingsViewModel extends ChangeNotifier {
  static const String _storageKey = 'app_settings';

  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  // Unit getters
  bool get useImperial => _settings.useImperial;

  // Safety margins
  double get takeoffSafetyMargin => _settings.takeoffSafetyMargin;
  double get landingSafetyMargin => _settings.landingSafetyMargin;

  // Takeoff corrections
  double get takeoffDryGrassCorrection => _settings.takeoffDryGrassCorrection;
  double get takeoffWetGrassCorrection => _settings.takeoffWetGrassCorrection;
  double get takeoffWetPavedCorrection => _settings.takeoffWetPavedCorrection;
  double get takeoffUpslopeCorrection => _settings.takeoffUpslopeCorrection;

  // Landing corrections
  double get landingDryGrassCorrection => _settings.landingDryGrassCorrection;
  double get landingWetGrassCorrection => _settings.landingWetGrassCorrection;
  double get landingWetPavedCorrection => _settings.landingWetPavedCorrection;
  double get landingDownslopeCorrection => _settings.landingDownslopeCorrection;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      _settings = AppSettings.fromJson(json);
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_settings.toJson()));
  }

  // Setters
  void setUseImperial(bool value) {
    _settings = _settings.copyWith(useImperial: value);
    notifyListeners();
    _saveSettings();
  }

  void setTakeoffSafetyMargin(double value) {
    _settings = _settings.copyWith(takeoffSafetyMargin: value);
    notifyListeners();
    _saveSettings();
  }

  void setLandingSafetyMargin(double value) {
    _settings = _settings.copyWith(landingSafetyMargin: value);
    notifyListeners();
    _saveSettings();
  }

  // Takeoff correction setters
  void setTakeoffDryGrassCorrection(double value) {
    _settings = _settings.copyWith(takeoffDryGrassCorrection: value);
    notifyListeners();
    _saveSettings();
  }

  void setTakeoffWetGrassCorrection(double value) {
    _settings = _settings.copyWith(takeoffWetGrassCorrection: value);
    notifyListeners();
    _saveSettings();
  }

  void setTakeoffWetPavedCorrection(double value) {
    _settings = _settings.copyWith(takeoffWetPavedCorrection: value);
    notifyListeners();
    _saveSettings();
  }

  void setTakeoffUpslopeCorrection(double value) {
    _settings = _settings.copyWith(takeoffUpslopeCorrection: value);
    notifyListeners();
    _saveSettings();
  }

  // Landing correction setters
  void setLandingDryGrassCorrection(double value) {
    _settings = _settings.copyWith(landingDryGrassCorrection: value);
    notifyListeners();
    _saveSettings();
  }

  void setLandingWetGrassCorrection(double value) {
    _settings = _settings.copyWith(landingWetGrassCorrection: value);
    notifyListeners();
    _saveSettings();
  }

  void setLandingWetPavedCorrection(double value) {
    _settings = _settings.copyWith(landingWetPavedCorrection: value);
    notifyListeners();
    _saveSettings();
  }

  void setLandingDownslopeCorrection(double value) {
    _settings = _settings.copyWith(landingDownslopeCorrection: value);
    notifyListeners();
    _saveSettings();
  }

  void resetToDefaults() {
    _settings = const AppSettings();
    notifyListeners();
    _saveSettings();
  }
}
