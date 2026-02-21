import 'package:flutter/foundation.dart';
import 'package:flightstate/core/models/aircraft_type.dart';
import 'package:flightstate/data/aircraft/aircraft_registry.dart';
import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/domain/models/landing_input.dart';
import 'package:flightstate/domain/models/landing_result.dart';
import 'package:flightstate/domain/performance/landing_calculator.dart';

class LandingViewModel extends ChangeNotifier {
  // Aircraft
  AircraftType _aircraftType = AircraftType.c172p;
  AircraftPerformanceData? _aircraftData;
  
  // Inputs
  double _oat = 15; // °C
  double _pressureAltitude = 0; // ft
  double _mass = 730; // kg (DV20)
  double _headwind = 0; // kts
  double _obstacleHeight = 15; // m (50 ft)
  bool _isWetSurface = false;
  
  // Units
  bool _useImperial = false;

  LandingViewModel() {
    _loadAircraftData();
  }

  // Getters
  AircraftType get aircraftType => _aircraftType;
  double get oat => _oat;
  double get pressureAltitude => _pressureAltitude;
  double get mass => _mass;
  double get headwind => _headwind;
  double get obstacleHeight => _obstacleHeight;
  bool get isWetSurface => _isWetSurface;
  bool get useImperial => _useImperial;

  // Unit getters
  String get tempUnit => useImperial ? '°F' : '°C';
  String get altUnit => useImperial ? 'ft' : 'ft';
  String get massUnit => useImperial ? 'lbs' : 'kg';
  String get windUnit => 'kts';
  String get obstUnit => useImperial ? 'ft' : 'm';
  String get distUnit => useImperial ? 'ft' : 'm';

  // Display values (converted)
  double get displayOat => useImperial ? (oat * 9 / 5) + 32 : oat;
  double get displayMass => useImperial ? mass * 2.20462 : mass;
  double get displayObstacleHeight => useImperial ? obstacleHeight * 3.28084 : obstacleHeight;
  double get displayGroundRoll => _result != null ? _result!.groundRoll(distUnit) : 0;
  double get displayTotalDistance => _result != null ? _result!.totalDistance(distUnit) : 0;
  double get displayLandingDistance50ft => _result != null ? _result!.landingDistanceOver50ft(distUnit) : 0;

  // Input ranges
  double get oatMin => -20;
  double get oatMax => 40;
  double get altMin => 0;
  double get altMax => 8000;
  double get massMin => _aircraftData?.massMinKg ?? 600;
  double get massMax => _aircraftData?.massMaxKg ?? 730;
  double get windMin => -10;
  double get windMax => 20;
  double get obstMin => 0;
  double get obstMax => 15;

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

  void setObstacleHeight(double value) {
    _obstacleHeight = value;
    _calculate();
    notifyListeners();
  }

  void setWetSurface(bool value) {
    _isWetSurface = value;
    _calculate();
    notifyListeners();
  }

  void toggleUnits() {
    _useImperial = !_useImperial;
    notifyListeners();
  }

  void _calculate() {
    if (_aircraftData == null) return;
    
    // Convert units for calculation
    double calcOat = useImperial ? (oat - 32) * 5 / 9 : oat;
    double calcMass = useImperial ? mass / 2.20462 : mass;
    double calcObst = useImperial ? obstacleHeight / 3.28084 : obstacleHeight;

    final input = LandingInput(
      oatC: calcOat,
      pressureAltitudeFt: pressureAltitude,
      massKg: calcMass,
      headwindKts: headwind,
      obstacleHeightM: calcObst,
      isWetSurface: isWetSurface,
    );

    final calculator = LandingCalculator(_aircraftData!);
    _result = calculator.calculate(input);
  }
}
