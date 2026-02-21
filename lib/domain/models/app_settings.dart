// App settings model

class AppSettings {
  // Units
  final bool useImperial;

  // Safety margins
  final double takeoffSafetyMargin; // e.g., 1.33
  final double landingSafetyMargin; // e.g., 1.43

  // Default corrections (used when POH doesn't have specific data)
  final double dryGrassCorrection; // e.g., 1.20
  final double wetGrassCorrection; // e.g., 1.25
  final double wetPavedCorrection; // e.g., 1.15
  final double upslopeCorrection; // % per 1% slope
  final double downslopeCorrection; // % per 1% slope

  const AppSettings({
    this.useImperial = false,
    this.takeoffSafetyMargin = 1.33,
    this.landingSafetyMargin = 1.43,
    this.dryGrassCorrection = 1.20,
    this.wetGrassCorrection = 1.25,
    this.wetPavedCorrection = 1.15,
    this.upslopeCorrection = 0.05,
    this.downslopeCorrection = 0.05,
  });

  AppSettings copyWith({
    bool? useImperial,
    double? takeoffSafetyMargin,
    double? landingSafetyMargin,
    double? dryGrassCorrection,
    double? wetGrassCorrection,
    double? wetPavedCorrection,
    double? upslopeCorrection,
    double? downslopeCorrection,
  }) {
    return AppSettings(
      useImperial: useImperial ?? this.useImperial,
      takeoffSafetyMargin: takeoffSafetyMargin ?? this.takeoffSafetyMargin,
      landingSafetyMargin: landingSafetyMargin ?? this.landingSafetyMargin,
      dryGrassCorrection: dryGrassCorrection ?? this.dryGrassCorrection,
      wetGrassCorrection: wetGrassCorrection ?? this.wetGrassCorrection,
      wetPavedCorrection: wetPavedCorrection ?? this.wetPavedCorrection,
      upslopeCorrection: upslopeCorrection ?? this.upslopeCorrection,
      downslopeCorrection: downslopeCorrection ?? this.downslopeCorrection,
    );
  }

  // Get surface correction based on type
  double getSurfaceCorrection(SurfaceCondition condition) {
    switch (condition) {
      case SurfaceCondition.dryGrass:
        return dryGrassCorrection;
      case SurfaceCondition.wetGrass:
        return wetGrassCorrection;
      case SurfaceCondition.wetPaved:
        return wetPavedCorrection;
      case SurfaceCondition.dryPaved:
        return 1.0;
    }
  }
}

enum SurfaceCondition {
  dryPaved('Dry Paved', 1.0),
  wetPaved('Wet Paved', 1.15),
  dryGrass('Dry Grass', 1.20),
  wetGrass('Wet Grass', 1.25);

  const SurfaceCondition(this.label, this.defaultCorrection);
  
  final String label;
  final double defaultCorrection;
}
