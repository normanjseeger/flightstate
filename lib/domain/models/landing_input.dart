// Landing input parameters

class LandingInput {
  final double oatC;
  final double pressureAltitudeFt;
  final double massKg;
  final double headwindKts;
  final double obstacleHeightM;
  final bool isWetSurface;

  const LandingInput({
    required this.oatC,
    required this.pressureAltitudeFt,
    required this.massKg,
    required this.headwindKts,
    required this.obstacleHeightM,
    required this.isWetSurface,
  });

  LandingInput copyWith({
    double? oatC,
    double? pressureAltitudeFt,
    double? massKg,
    double? headwindKts,
    double? obstacleHeightM,
    bool? isWetSurface,
  }) {
    return LandingInput(
      oatC: oatC ?? this.oatC,
      pressureAltitudeFt: pressureAltitudeFt ?? this.pressureAltitudeFt,
      massKg: massKg ?? this.massKg,
      headwindKts: headwindKts ?? this.headwindKts,
      obstacleHeightM: obstacleHeightM ?? this.obstacleHeightM,
      isWetSurface: isWetSurface ?? this.isWetSurface,
    );
  }
}
