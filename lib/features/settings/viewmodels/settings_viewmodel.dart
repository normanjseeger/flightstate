import 'package:flutter/foundation.dart';
import 'package:flightstate/domain/models/app_settings.dart';

class SettingsViewModel extends ChangeNotifier {
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  // Unit getters
  bool get useImperial => _settings.useImperial;
  
  // Safety margins
  double get takeoffSafetyMargin => _settings.takeoffSafetyMargin;
  double get landingSafetyMargin => _settings.landingSafetyMargin;
  
  // Default corrections
  double get dryGrassCorrection => _settings.dryGrassCorrection;
  double get wetGrassCorrection => _settings.wetGrassCorrection;
  double get wetPavedCorrection => _settings.wetPavedCorrection;
  double get upslopeCorrection => _settings.upslopeCorrection;
  double get downslopeCorrection => _settings.downslopeCorrection;

  // Setters
  void setUseImperial(bool value) {
    _settings = _settings.copyWith(useImperial: value);
    notifyListeners();
  }

  void setTakeoffSafetyMargin(double value) {
    _settings = _settings.copyWith(takeoffSafetyMargin: value);
    notifyListeners();
  }

  void setLandingSafetyMargin(double value) {
    _settings = _settings.copyWith(landingSafetyMargin: value);
    notifyListeners();
  }

  void setDryGrassCorrection(double value) {
    _settings = _settings.copyWith(dryGrassCorrection: value);
    notifyListeners();
  }

  void setWetGrassCorrection(double value) {
    _settings = _settings.copyWith(wetGrassCorrection: value);
    notifyListeners();
  }

  void setWetPavedCorrection(double value) {
    _settings = _settings.copyWith(wetPavedCorrection: value);
    notifyListeners();
  }

  void setUpslopeCorrection(double value) {
    _settings = _settings.copyWith(upslopeCorrection: value);
    notifyListeners();
  }

  void setDownslopeCorrection(double value) {
    _settings = _settings.copyWith(downslopeCorrection: value);
    notifyListeners();
  }

  void resetToDefaults() {
    _settings = const AppSettings();
    notifyListeners();
  }
}
