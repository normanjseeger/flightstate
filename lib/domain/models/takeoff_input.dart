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

  /// Runway slope percentage (negative = downslope, positive = upslope)
  final double slopePercentage;

  /// Slope correction factor per 1% slope (e.g., 0.05 = 5% per 1%)
  final double slopeCorrectionPerPercent;

  /// Custom surface correction factor (0 = use enum factor, >0 = override)
  final double customSurfaceFactor;

  const TakeoffInput({
    required this.oat,
    required this.pressureAltitude,
    required this.mass,
    required this.headwind,
    required this.obstacleHeight,
    this.surfaceType = SurfaceType.paved,
    this.slopePercentage = 0.0,
    this.slopeCorrectionPerPercent = 0.05,
    this.customSurfaceFactor = 0.0,
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
    double? slopePercentage,
    double? slopeCorrectionPerPercent,
    double? customSurfaceFactor,
  }) {
    return TakeoffInput(
      oat: oat ?? this.oat,
      pressureAltitude: pressureAltitude ?? this.pressureAltitude,
      mass: mass ?? this.mass,
      headwind: headwind ?? this.headwind,
      obstacleHeight: obstacleHeight ?? this.obstacleHeight,
      surfaceType: surfaceType ?? this.surfaceType,
      slopePercentage: slopePercentage ?? this.slopePercentage,
      slopeCorrectionPerPercent: slopeCorrectionPerPercent ?? this.slopeCorrectionPerPercent,
      customSurfaceFactor: customSurfaceFactor ?? this.customSurfaceFactor,
    );
  }
}
