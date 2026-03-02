import 'package:flutter/foundation.dart';
import 'package:flightstate/core/models/aircraft_type.dart';
import 'package:flightstate/core/math/unit_conversion.dart';
import 'package:flightstate/data/aircraft/aircraft_registry.dart';
import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/domain/models/landing_input.dart';
import 'package:flightstate/domain/models/landing_result.dart';
import 'package:flightstate/domain/models/landing_surface_type.dart';
import 'package:flightstate/domain/performance/landing_calculator.dart';

class LandingViewModel extends ChangeNotifier {
  // Aircraft
  AircraftType _aircraftType = AircraftType.c172p;
  AircraftPerformanceData? _aircraftData;

  // Inputs
  double _oat = 15; // °C
  double _pressureAltitude = 0; // ft
  double _mass = lbsToKg(2400); // C172P max weight (2400 lbs ≈ 1088.62 kg)
  double _headwind = 0; // kts
  LandingSurfaceType _surfaceType = LandingSurfaceType.dryPaved;
  double _slopePercentage = 0.0; // Runway slope: negative = downslope, positive = upslope
  double _customSurfaceFactor = 0.0; // Custom surface correction (0 = use enum, >0 = use this value)

  // Fixed at 15m/50ft obstacle for landing
  static const double _obstacleHeight = 15.0;

  LandingViewModel() {
    _loadAircraftData();
  }

  // Getters
  AircraftType get aircraftType => _aircraftType;
  AircraftPerformanceData get aircraftData => _aircraftData ?? AircraftRegistry.getPerformanceData(_aircraftType);
  double get oat => _oat;
  double get pressureAltitude => _pressureAltitude;
  double get mass => _mass;
  double get headwind => _headwind;
  LandingSurfaceType get surfaceType => _surfaceType;
  double get slopePercentage => _slopePercentage;
  double get customSurfaceFactor => _customSurfaceFactor;

  /// Effective surface correction factor (custom overrides enum if set)
  double get effectiveSurfaceFactor => _customSurfaceFactor > 0 ? _customSurfaceFactor : _surfaceType.correctionFactor;

  // Result getter
  LandingResult? get result => _result;

  // Unit getters
  String tempUnit(bool useImperial) => useImperial ? '°F' : '°C';
  String altUnit(bool useImperial) => useImperial ? 'ft' : 'ft';
  String massUnit(bool useImperial) => useImperial ? 'lbs' : 'kg';
  String get windUnit => 'kts';
  String distUnit(bool useImperial) => useImperial ? 'ft' : 'm';

  // Display values (converted)
  double displayOat(bool useImperial) => useImperial ? celsiusToFahrenheit(oat) : oat;
  double displayMass(bool useImperial) => useImperial ? kgToLbs(mass) : mass;
  double displayGroundRoll(bool useImperial) => _result != null ? _result!.groundRoll(distUnit(useImperial)) : 0;
  double displayTotalDistance(bool useImperial) => _result != null ? _result!.totalDistance(distUnit(useImperial)) : 0;

  // Input ranges
  double get oatMin => -20;
  double get oatMax => 40;
  double get altMin => 0;
  double get altMax => 8000;
  double get massMin => _aircraftData?.massMinKg ?? 600;
  double get massMax => _aircraftData?.massMaxKg ?? 730;
  double get windMin => -10;
  double get windMax => 20;
  double get slopeMin => -10.0; // -10% downslope
  double get slopeMax => 10.0;  // +10% upslope

  LandingResult? _result;

  // Validation
  String? get validationError {
    if (mass < massMin || mass > massMax) {
      return 'Mass must be between ${massMin.round()} and ${massMax.round()} kg';
    }
    return null;
  }

  void _loadAircraftData() {
    _aircraftData = AircraftRegistry.getPerformanceData(_aircraftType);
    _mass = (_aircraftData?.massMaxKg ?? 730);
    _calculate();
  }

  void setAircraftType(AircraftType type) {
    _aircraftType = type;
    _loadAircraftData();
    notifyListeners();
  }

  void setOat(double value) {
    _oat = value;
    _calculate();
    notifyListeners();
  }

  void setPressureAltitude(double value) {
    _pressureAltitude = value;
    _calculate();
    notifyListeners();
  }

  void setMass(double value) {
    _mass = value;
    _calculate();
    notifyListeners();
  }

  void setHeadwind(double value) {
    _headwind = value;
    _calculate();
    notifyListeners();
  }

  void setSurfaceType(LandingSurfaceType value) {
    _surfaceType = value;
    _customSurfaceFactor = 0.0; // Clear custom when POH surface selected
    _calculate();
    notifyListeners();
  }

  void setCustomSurfaceFactor(double factor) {
    _customSurfaceFactor = factor;
    _calculate();
    notifyListeners();
  }

  void setSlopePercentage(double value) {
    _slopePercentage = value;
    _calculate();
    notifyListeners();
  }

  void _calculate({double safetyMargin = 1.43, double slopeCorrectionPerPercent = 0.05}) {
    if (_aircraftData == null) return;

    final input = LandingInput(
      oatC: oat,
      pressureAltitudeFt: pressureAltitude,
      massKg: mass,
      headwindKts: headwind,
      obstacleHeightM: _obstacleHeight,
      surfaceType: surfaceType,
      slopePercentage: _slopePercentage,
      slopeCorrectionPerPercent: slopeCorrectionPerPercent,
      customSurfaceFactor: _customSurfaceFactor,
    );

    final calculator = LandingCalculator(_aircraftData!);
    _result = calculator.calculate(input, safetyMargin: safetyMargin);
  }

  // Allow recalculation with updated safety margin
  void recalculateWithSafetyMargin(double safetyMargin, {double slopeCorrectionPerPercent = 0.05}) {
    _calculate(safetyMargin: safetyMargin, slopeCorrectionPerPercent: slopeCorrectionPerPercent);
    notifyListeners();
  }
}
