import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flightstate/domain/models/app_settings.dart';

class SettingsViewModel extends ChangeNotifier {
  static const String _storageKey = 'app_settings';
  static const String _openaiKeyStorageKey = 'openai_api_key';

  final _secureStorage = const FlutterSecureStorage();

  AppSettings _settings = const AppSettings();
  String? _openaiApiKey;

  AppSettings get settings => _settings;

  // OpenAI API key management
  String? get openaiApiKey => _openaiApiKey;
  bool get hasApiKey => _openaiApiKey != null && _openaiApiKey!.isNotEmpty;

  // Use SharedPreferences for macOS (avoids keychain signing issues)
  // Use SecureStorage for iOS/Android (more secure)
  bool get _usePlainStorage => !kIsWeb && Platform.isMacOS;

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
    }

    // Load OpenAI API key
    if (_usePlainStorage) {
      // macOS: Use SharedPreferences (avoids keychain signing issues in development)
      _openaiApiKey = prefs.getString(_openaiKeyStorageKey);
    } else {
      // iOS/Android: Use secure storage
      _openaiApiKey = await _secureStorage.read(key: _openaiKeyStorageKey);
    }

    notifyListeners();
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

  // OpenAI API key management
  Future<void> setOpenAiApiKey(String key) async {
    _openaiApiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();

    if (_openaiApiKey!.isEmpty) {
      _openaiApiKey = null;
      if (_usePlainStorage) {
        await prefs.remove(_openaiKeyStorageKey);
      } else {
        await _secureStorage.delete(key: _openaiKeyStorageKey);
      }
    } else {
      if (_usePlainStorage) {
        // macOS: Store in SharedPreferences
        await prefs.setString(_openaiKeyStorageKey, _openaiApiKey!);
      } else {
        // iOS/Android: Store securely
        await _secureStorage.write(
          key: _openaiKeyStorageKey,
          value: _openaiApiKey,
        );
      }
    }

    notifyListeners();
  }

  Future<void> clearOpenAiApiKey() async {
    _openaiApiKey = null;
    final prefs = await SharedPreferences.getInstance();

    if (_usePlainStorage) {
      await prefs.remove(_openaiKeyStorageKey);
    } else {
      await _secureStorage.delete(key: _openaiKeyStorageKey);
    }

    notifyListeners();
  }
}
