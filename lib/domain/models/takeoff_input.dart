import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';

import 'surface_type.dart';

class TakeoffInput {
  /// Outside Air Temperature in °C
  final double oat;

  /// Pressure altitude in ft
  final double pressureAltitude;

  /// Aircraft mass in kg
  final double mass;

  /// Headwind component in kts (negative = tailwind)
  final double headwind;

  /// Obstacle height in m
  final double obstacleHeight;

  /// Runway surface type
  final SurfaceType surfaceType;

  const TakeoffInput({
    required this.oat,
    required this.pressureAltitude,
    required this.mass,
    required this.headwind,
    required this.obstacleHeight,
    this.surfaceType = SurfaceType.paved,
  });

  /// Validates all inputs are within the aircraft's chart range.
  String? validate(AircraftPerformanceData data) {
    if (oat < data.oatMinC || oat > data.oatMaxC) {
      return 'OAT must be between ${data.oatMinC.round()}°C and ${data.oatMaxC.round()}°C';
    }
    if (pressureAltitude < data.altMinFt || pressureAltitude > data.altMaxFt) {
      return 'Pressure altitude must be between ${data.altMinFt.round()} and ${data.altMaxFt.round()} ft';
    }
    if (mass < data.massMinKg || mass > data.massMaxKg) {
      return 'Mass must be between ${data.massMinKg.round()} and ${data.massMaxKg.round()} kg';
    }
    if (headwind < data.windMinKts || headwind > data.windMaxKts) {
      return 'Wind must be between ${data.windMinKts.round()} (tailwind) and ${data.windMaxKts.round()} kts (headwind)';
    }
    if (obstacleHeight < data.obstMinM || obstacleHeight > data.obstMaxM) {
      return 'Obstacle height must be between ${data.obstMinM.round()} and ${data.obstMaxM.round()} m';
    }
    return null;
  }

  TakeoffInput copyWith({
    double? oat,
    double? pressureAltitude,
    double? mass,
    double? headwind,
    double? obstacleHeight,
    SurfaceType? surfaceType,
  }) {
    return TakeoffInput(
      oat: oat ?? this.oat,
      pressureAltitude: pressureAltitude ?? this.pressureAltitude,
      mass: mass ?? this.mass,
      headwind: headwind ?? this.headwind,
      obstacleHeight: obstacleHeight ?? this.obstacleHeight,
      surfaceType: surfaceType ?? this.surfaceType,
    );
  }
}
