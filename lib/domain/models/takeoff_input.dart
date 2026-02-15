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

  /// Validates all inputs are within chart range.
  String? validate() {
    if (oat < -20 || oat > 40) return 'OAT must be between -20°C and 40°C';
    if (pressureAltitude < 0 || pressureAltitude > 8000) {
      return 'Pressure altitude must be between 0 and 8000 ft';
    }
    if (mass < 600 || mass > 730) return 'Mass must be between 600 and 730 kg';
    if (headwind < -10 || headwind > 20) {
      return 'Wind must be between -10 (tailwind) and 20 kts (headwind)';
    }
    if (obstacleHeight < 0 || obstacleHeight > 15) {
      return 'Obstacle height must be between 0 and 15 m';
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
