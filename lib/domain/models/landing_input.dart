// Landing input parameters

import 'package:flightstate/domain/models/landing_surface_type.dart';

class LandingInput {
  final double oatC;
  final double pressureAltitudeFt;
  final double massKg;
  final double headwindKts;
  final double obstacleHeightM;
  final LandingSurfaceType surfaceType;

  const LandingInput({
    required this.oatC,
    required this.pressureAltitudeFt,
    required this.massKg,
    required this.headwindKts,
    required this.obstacleHeightM,
    required this.surfaceType,
  });

  LandingInput copyWith({
    double? oatC,
    double? pressureAltitudeFt,
    double? massKg,
    double? headwindKts,
    double? obstacleHeightM,
    LandingSurfaceType? surfaceType,
  }) {
    return LandingInput(
      oatC: oatC ?? this.oatC,
      pressureAltitudeFt: pressureAltitudeFt ?? this.pressureAltitudeFt,
      massKg: massKg ?? this.massKg,
      headwindKts: headwindKts ?? this.headwindKts,
      obstacleHeightM: obstacleHeightM ?? this.obstacleHeightM,
      surfaceType: surfaceType ?? this.surfaceType,
    );
  }
}
