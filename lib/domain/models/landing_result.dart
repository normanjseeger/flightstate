// Landing performance result

class LandingResult {
  final double groundRollM;
  final double totalDistanceM;

  // Breakdown for transparency
  final double baseGroundRollM;
  final double massFactor;
  final double windFactor;
  final double surfaceFactor;
  final double obstacleFactor;
  final double safetyMargin;

  const LandingResult({
    required this.groundRollM,
    required this.totalDistanceM,
    this.baseGroundRollM = 0,
    this.massFactor = 1.0,
    this.windFactor = 1.0,
    this.surfaceFactor = 1.0,
    this.obstacleFactor = 1.0,
    this.safetyMargin = 1.0,
  });

  // Ground roll in selected unit (with safety margin applied)
  double groundRoll(String unit) {
    final withSafety = groundRollM * safetyMargin;
    if (unit == 'ft') return withSafety * 3.28084;
    return withSafety;
  }

  // Total distance over obstacle in selected unit (with safety margin applied)
  double totalDistance(String unit) {
    final withSafety = totalDistanceM * safetyMargin;
    if (unit == 'ft') return withSafety * 3.28084;
    return withSafety;
  }
}
