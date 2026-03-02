import 'package:flutter/foundation.dart';
import 'package:flightstate/core/models/aircraft_type.dart';
import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/data/aircraft/aircraft_registry.dart';
import 'package:flightstate/domain/models/takeoff_input.dart';
import 'package:flightstate/domain/models/takeoff_result.dart';
import 'package:flightstate/domain/models/surface_type.dart';
import 'package:flightstate/domain/performance/takeoff_calculator.dart';
import 'package:flightstate/core/math/unit_conversion.dart';

class TakeoffViewModel extends ChangeNotifier {
  // Aircraft selection
  AircraftType _aircraftType = AircraftType.c172p;
  AircraftPerformanceData _aircraftData =
      AircraftRegistry.getPerformanceData(AircraftType.c172p);

  // Input values
  double _oat = 15;
  double _pressureAltitude = 0;
  double _mass = lbsToKg(2400); // C172P max weight (2400 lbs ≈ 1088.62 kg)
  double _headwind = 0;
  double _obstacleHeight = ftToM(50); // Exactly 50 ft (15.24 m) to match POH table
  SurfaceType _surfaceType = SurfaceType.paved;
  double _slopePercentage = 0.0; // Runway slope: negative = downslope, positive = upslope
  double _customSurfaceFactor = 0.0; // Custom surface correction (0 = use enum, >0 = use this value)

  // Getters
  AircraftType get aircraftType => _aircraftType;
  AircraftPerformanceData get aircraftData => _aircraftData;
  double get oat => _oat;
  double get pressureAltitude => _pressureAltitude;
  double get mass => _mass;
  double get headwind => _headwind;
  double get obstacleHeight => _obstacleHeight;
  SurfaceType get surfaceType => _surfaceType;
  double get slopePercentage => _slopePercentage;
  double get customSurfaceFactor => _customSurfaceFactor;

  /// Effective surface correction factor (custom overrides enum if set)
  double get effectiveSurfaceFactor => _customSurfaceFactor > 0 ? _customSurfaceFactor : _surfaceType.correctionFactor;

  // Display values for imperial mode (provided by caller from SettingsViewModel)
  double displayOat(bool useImperial) => useImperial ? celsiusToFahrenheit(_oat) : _oat;
  double displayMass(bool useImperial) => useImperial ? kgToLbs(_mass) : _mass;
  double displayObstacleHeight(bool useImperial) => useImperial ? obstacleHeightMToFt(_obstacleHeight) : _obstacleHeight;

  String tempUnit(bool useImperial) => useImperial ? '°F' : '°C';
  String massUnit(bool useImperial) => useImperial ? 'lbs' : 'kg';
  String get altUnit => 'ft'; // Always ft for pressure altitude
  String distUnit(bool useImperial) => useImperial ? 'ft' : 'm';
  String obstUnit(bool useImperial) => useImperial ? 'ft' : 'm';
  String get windUnit => 'kts'; // Always kts

  // Slider ranges from aircraft data
  double get oatMin => _aircraftData.oatMinC;
  double get oatMax => _aircraftData.oatMaxC;
  double get altMin => _aircraftData.altMinFt;
  double get altMax => _aircraftData.altMaxFt;
  double get massMin => _aircraftData.massMinKg;
  double get massMax => _aircraftData.massMaxKg;
  double get windMin => _aircraftData.windMinKts;
  double get windMax => _aircraftData.windMaxKts;
  double get obstMin => _aircraftData.obstMinM;
  double get obstMax => _aircraftData.obstMaxM;
  double get slopeMin => -10.0; // -10% downslope
  double get slopeMax => 10.0;  // +10% upslope

  /// Whether the obstacle slider should be shown (false if fixed).
  bool get showObstacleSlider => obstMin != obstMax;

  /// Supported surfaces for the current aircraft.
  List<SurfaceType> get supportedSurfaces => _aircraftData.supportedSurfaces;

  TakeoffResult? _cachedResult;
  double _cachedSafetyMargin = 1.33;

  // Computed result
  TakeoffResult get result => _cachedResult ?? _calculateResult();

  TakeoffResult _calculateResult({double safetyMargin = 1.33, double slopeCorrectionPerPercent = 0.05}) {
    final input = TakeoffInput(
      oat: _oat,
      pressureAltitude: _pressureAltitude,
      mass: _mass,
      headwind: _headwind,
      obstacleHeight: _obstacleHeight,
      surfaceType: _surfaceType,
      slopePercentage: _slopePercentage,
      slopeCorrectionPerPercent: slopeCorrectionPerPercent,
      customSurfaceFactor: _customSurfaceFactor,
    );
    _cachedSafetyMargin = safetyMargin;
    _cachedResult = TakeoffCalculator.calculate(input, _aircraftData, safetyMargin: safetyMargin);
    return _cachedResult!;
  }

  void recalculateWithSafetyMargin(double safetyMargin, {double slopeCorrectionPerPercent = 0.05}) {
    if (_cachedSafetyMargin != safetyMargin) {
      _calculateResult(safetyMargin: safetyMargin, slopeCorrectionPerPercent: slopeCorrectionPerPercent);
      notifyListeners();
    }
  }

  String? get validationError {
    final input = TakeoffInput(
      oat: _oat,
      pressureAltitude: _pressureAltitude,
      mass: _mass,
      headwind: _headwind,
      obstacleHeight: _obstacleHeight,
      surfaceType: _surfaceType,
      slopePercentage: _slopePercentage,
      customSurfaceFactor: _customSurfaceFactor,
    );
    return input.validate(_aircraftData);
  }

  // Display results (with safety margin applied)
  double displayGroundRoll(bool useImperial) =>
      useImperial ? mToFt(result.groundRollWithSafetyM) : result.groundRollWithSafetyM;
  double displayTotalDistance(bool useImperial) =>
      useImperial ? mToFt(result.totalDistanceWithSafetyM) : result.totalDistanceWithSafetyM;

  // Setters
  void setAircraftType(AircraftType type) {
    if (type == _aircraftType) return;
    _aircraftType = type;
    _aircraftData = AircraftRegistry.getPerformanceData(type);

    // Clamp inputs to new ranges
    _oat = _oat.clamp(oatMin, oatMax);
    _pressureAltitude = _pressureAltitude.clamp(altMin, altMax);
    _mass = _mass.clamp(massMin, massMax);
    _headwind = _headwind.clamp(windMin, windMax);
    _obstacleHeight = _obstacleHeight.clamp(obstMin, obstMax);

    // Reset surface if not supported
    if (!supportedSurfaces.contains(_surfaceType)) {
      _surfaceType = SurfaceType.paved;
    }

    _cachedResult = null; // Invalidate cache
    notifyListeners();
  }

  void setOat(double value) {
    _oat = value;
    _cachedResult = null; // Invalidate cache
    notifyListeners();
  }

  void setPressureAltitude(double value) {
    _pressureAltitude = value;
    _cachedResult = null; // Invalidate cache
    notifyListeners();
  }

  void setMass(double value) {
    _mass = value;
    _cachedResult = null; // Invalidate cache
    notifyListeners();
  }

  void setHeadwind(double value) {
    _headwind = value;
    _cachedResult = null; // Invalidate cache
    notifyListeners();
  }

  void setObstacleHeight(double value) {
    _obstacleHeight = value;
    _cachedResult = null; // Invalidate cache
    notifyListeners();
  }

  void setSurfaceType(SurfaceType value) {
    _surfaceType = value;
    _customSurfaceFactor = 0.0; // Clear custom when POH surface selected
    _cachedResult = null; // Invalidate cache
    notifyListeners();
  }

  void setCustomSurfaceFactor(double factor) {
    _customSurfaceFactor = factor;
    _cachedResult = null; // Invalidate cache
    notifyListeners();
  }

  void setSlopePercentage(double value) {
    _slopePercentage = value;
    _cachedResult = null; // Invalidate cache
    notifyListeners();
  }
}
