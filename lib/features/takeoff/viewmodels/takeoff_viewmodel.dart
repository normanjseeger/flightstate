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
      AircraftRegistry.getPerformanceData(AircraftType.dv20);

  // Input values
  double _oat = 15;
  double _pressureAltitude = 0;
  double _mass = 700;
  double _headwind = 0;
  double _obstacleHeight = 15;
  SurfaceType _surfaceType = SurfaceType.paved;
  bool _useImperial = false;

  // Getters
  AircraftType get aircraftType => _aircraftType;
  AircraftPerformanceData get aircraftData => _aircraftData;
  double get oat => _oat;
  double get pressureAltitude => _pressureAltitude;
  double get mass => _mass;
  double get headwind => _headwind;
  double get obstacleHeight => _obstacleHeight;
  SurfaceType get surfaceType => _surfaceType;
  bool get useImperial => _useImperial;

  // Display values for imperial mode
  double get displayOat => _useImperial ? celsiusToFahrenheit(_oat) : _oat;
  double get displayMass => _useImperial ? kgToLbs(_mass) : _mass;
  double get displayObstacleHeight =>
      _useImperial ? mToFt(_obstacleHeight) : _obstacleHeight;

  String get tempUnit => _useImperial ? '°F' : '°C';
  String get massUnit => _useImperial ? 'lbs' : 'kg';
  String get altUnit => 'ft'; // Always ft for pressure altitude
  String get distUnit => _useImperial ? 'ft' : 'm';
  String get obstUnit => _useImperial ? 'ft' : 'm';
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

  /// Whether the obstacle slider should be shown (false if fixed).
  bool get showObstacleSlider => obstMin != obstMax;

  /// Supported surfaces for the current aircraft.
  List<SurfaceType> get supportedSurfaces => _aircraftData.supportedSurfaces;

  // Computed result
  TakeoffResult get result {
    final input = TakeoffInput(
      oat: _oat,
      pressureAltitude: _pressureAltitude,
      mass: _mass,
      headwind: _headwind,
      obstacleHeight: _obstacleHeight,
      surfaceType: _surfaceType,
    );
    return TakeoffCalculator.calculate(input, _aircraftData);
  }

  String? get validationError {
    final input = TakeoffInput(
      oat: _oat,
      pressureAltitude: _pressureAltitude,
      mass: _mass,
      headwind: _headwind,
      obstacleHeight: _obstacleHeight,
      surfaceType: _surfaceType,
    );
    return input.validate(_aircraftData);
  }

  // Display results
  double get displayGroundRoll =>
      _useImperial ? mToFt(result.groundRollM) : result.groundRollM;
  double get displayTotalDistance =>
      _useImperial ? mToFt(result.totalDistanceM) : result.totalDistanceM;

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

    notifyListeners();
  }

  void setOat(double value) {
    _oat = value;
    notifyListeners();
  }

  void setPressureAltitude(double value) {
    _pressureAltitude = value;
    notifyListeners();
  }

  void setMass(double value) {
    _mass = value;
    notifyListeners();
  }

  void setHeadwind(double value) {
    _headwind = value;
    notifyListeners();
  }

  void setObstacleHeight(double value) {
    _obstacleHeight = value;
    notifyListeners();
  }

  void setSurfaceType(SurfaceType value) {
    _surfaceType = value;
    notifyListeners();
  }

  void toggleUnits() {
    _useImperial = !_useImperial;
    notifyListeners();
  }
}
