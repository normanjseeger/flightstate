// Landing input parameters

import 'package:flightstate/domain/models/landing_surface_type.dart';

class LandingInput {
  final double oatC;
  final double pressureAltitudeFt;
  final double massKg;
  final double headwindKts;
  final double obstacleHeightM;
  final LandingSurfaceType surfaceType;
  final double slopePercentage;
  final double slopeCorrectionPerPercent;
  final double customSurfaceFactor;

  const LandingInput({
    required this.oatC,
    required this.pressureAltitudeFt,
    required this.massKg,
    required this.headwindKts,
    required this.obstacleHeightM,
    required this.surfaceType,
    this.slopePercentage = 0.0,
    this.slopeCorrectionPerPercent = 0.05,
    this.customSurfaceFactor = 0.0,
  });

  LandingInput copyWith({
    double? oatC,
    double? pressureAltitudeFt,
    double? massKg,
    double? headwindKts,
    double? obstacleHeightM,
    LandingSurfaceType? surfaceType,
    double? slopePercentage,
    double? slopeCorrectionPerPercent,
    double? customSurfaceFactor,
  }) {
    return LandingInput(
      oatC: oatC ?? this.oatC,
      pressureAltitudeFt: pressureAltitudeFt ?? this.pressureAltitudeFt,
      massKg: massKg ?? this.massKg,
      headwindKts: headwindKts ?? this.headwindKts,
      obstacleHeightM: obstacleHeightM ?? this.obstacleHeightM,
      surfaceType: surfaceType ?? this.surfaceType,
      slopePercentage: slopePercentage ?? this.slopePercentage,
      slopeCorrectionPerPercent: slopeCorrectionPerPercent ?? this.slopeCorrectionPerPercent,
      customSurfaceFactor: customSurfaceFactor ?? this.customSurfaceFactor,
    );
  }
}
