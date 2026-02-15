import 'package:flutter/foundation.dart';
import 'package:flightstate/domain/models/takeoff_input.dart';
import 'package:flightstate/domain/models/takeoff_result.dart';
import 'package:flightstate/domain/models/surface_type.dart';
import 'package:flightstate/domain/performance/takeoff_calculator.dart';
import 'package:flightstate/core/math/unit_conversion.dart';

class TakeoffViewModel extends ChangeNotifier {
  // Input values
  double _oat = 15;
  double _pressureAltitude = 0;
  double _mass = 700;
  double _headwind = 0;
  double _obstacleHeight = 15;
  SurfaceType _surfaceType = SurfaceType.paved;
  bool _useImperial = false;

  // Getters
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

  // Slider ranges (in metric, the internal unit)
  double get oatMin => -20;
  double get oatMax => 40;
  double get altMin => 0;
  double get altMax => 8000;
  double get massMin => 600;
  double get massMax => 730;
  double get windMin => -10;
  double get windMax => 20;
  double get obstMin => 0;
  double get obstMax => 15;

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
    return TakeoffCalculator.calculate(input);
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
    return input.validate();
  }

  // Display results
  double get displayGroundRoll =>
      _useImperial ? mToFt(result.groundRollM) : result.groundRollM;
  double get displayTotalDistance =>
      _useImperial ? mToFt(result.totalDistanceM) : result.totalDistanceM;

  // Setters
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
