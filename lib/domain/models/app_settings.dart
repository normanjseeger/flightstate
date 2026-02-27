// App settings model

class AppSettings {
  // Units
  final bool useImperial;

  // Safety margins
  final double takeoffSafetyMargin; // e.g., 1.33
  final double landingSafetyMargin; // e.g., 1.43

  // Takeoff corrections (used when POH doesn't have specific data)
  final double takeoffDryGrassCorrection; // e.g., 1.20
  final double takeoffWetGrassCorrection; // e.g., 1.25
  final double takeoffWetPavedCorrection; // e.g., 1.15
  final double takeoffUpslopeCorrection; // % per 1% slope, e.g., 0.05

  // Landing corrections (used when POH doesn't have specific data)
  final double landingDryGrassCorrection; // e.g., 1.20
  final double landingWetGrassCorrection; // e.g., 1.38
  final double landingWetPavedCorrection; // e.g., 1.15
  final double landingDownslopeCorrection; // % per 1% slope, e.g., 0.05

  const AppSettings({
    this.useImperial = false,
    this.takeoffSafetyMargin = 1.33,
    this.landingSafetyMargin = 1.43,
    // Takeoff corrections (from Operations Manual)
    this.takeoffDryGrassCorrection = 1.20,
    this.takeoffWetGrassCorrection = 1.25,
    this.takeoffWetPavedCorrection = 1.15,
    this.takeoffUpslopeCorrection = 0.05,
    // Landing corrections (from Operations Manual)
    this.landingDryGrassCorrection = 1.20,
    this.landingWetGrassCorrection = 1.38,
    this.landingWetPavedCorrection = 1.15,
    this.landingDownslopeCorrection = 0.05,
  });

  AppSettings copyWith({
    bool? useImperial,
    double? takeoffSafetyMargin,
    double? landingSafetyMargin,
    double? takeoffDryGrassCorrection,
    double? takeoffWetGrassCorrection,
    double? takeoffWetPavedCorrection,
    double? takeoffUpslopeCorrection,
    double? landingDryGrassCorrection,
    double? landingWetGrassCorrection,
    double? landingWetPavedCorrection,
    double? landingDownslopeCorrection,
  }) {
    return AppSettings(
      useImperial: useImperial ?? this.useImperial,
      takeoffSafetyMargin: takeoffSafetyMargin ?? this.takeoffSafetyMargin,
      landingSafetyMargin: landingSafetyMargin ?? this.landingSafetyMargin,
      takeoffDryGrassCorrection: takeoffDryGrassCorrection ?? this.takeoffDryGrassCorrection,
      takeoffWetGrassCorrection: takeoffWetGrassCorrection ?? this.takeoffWetGrassCorrection,
      takeoffWetPavedCorrection: takeoffWetPavedCorrection ?? this.takeoffWetPavedCorrection,
      takeoffUpslopeCorrection: takeoffUpslopeCorrection ?? this.takeoffUpslopeCorrection,
      landingDryGrassCorrection: landingDryGrassCorrection ?? this.landingDryGrassCorrection,
      landingWetGrassCorrection: landingWetGrassCorrection ?? this.landingWetGrassCorrection,
      landingWetPavedCorrection: landingWetPavedCorrection ?? this.landingWetPavedCorrection,
      landingDownslopeCorrection: landingDownslopeCorrection ?? this.landingDownslopeCorrection,
    );
  }

  Map<String, dynamic> toJson() => {
    'useImperial': useImperial,
    'takeoffSafetyMargin': takeoffSafetyMargin,
    'landingSafetyMargin': landingSafetyMargin,
    'takeoffDryGrassCorrection': takeoffDryGrassCorrection,
    'takeoffWetGrassCorrection': takeoffWetGrassCorrection,
    'takeoffWetPavedCorrection': takeoffWetPavedCorrection,
    'takeoffUpslopeCorrection': takeoffUpslopeCorrection,
    'landingDryGrassCorrection': landingDryGrassCorrection,
    'landingWetGrassCorrection': landingWetGrassCorrection,
    'landingWetPavedCorrection': landingWetPavedCorrection,
    'landingDownslopeCorrection': landingDownslopeCorrection,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      useImperial: json['useImperial'] as bool? ?? false,
      takeoffSafetyMargin: (json['takeoffSafetyMargin'] as num?)?.toDouble() ?? 1.33,
      landingSafetyMargin: (json['landingSafetyMargin'] as num?)?.toDouble() ?? 1.43,
      takeoffDryGrassCorrection: (json['takeoffDryGrassCorrection'] as num?)?.toDouble() ?? 1.20,
      takeoffWetGrassCorrection: (json['takeoffWetGrassCorrection'] as num?)?.toDouble() ?? 1.25,
      takeoffWetPavedCorrection: (json['takeoffWetPavedCorrection'] as num?)?.toDouble() ?? 1.15,
      takeoffUpslopeCorrection: (json['takeoffUpslopeCorrection'] as num?)?.toDouble() ?? 0.05,
      landingDryGrassCorrection: (json['landingDryGrassCorrection'] as num?)?.toDouble() ?? 1.20,
      landingWetGrassCorrection: (json['landingWetGrassCorrection'] as num?)?.toDouble() ?? 1.38,
      landingWetPavedCorrection: (json['landingWetPavedCorrection'] as num?)?.toDouble() ?? 1.15,
      landingDownslopeCorrection: (json['landingDownslopeCorrection'] as num?)?.toDouble() ?? 0.05,
    );
  }
}
