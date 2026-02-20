// Landing performance result

class LandingResult {
  final double groundRollM;
  final double totalDistanceM;
  final double landingDistanceOver50ftM;

  const LandingResult({
    required this.groundRollM,
    required this.totalDistanceM,
    required this.landingDistanceOver50ftM,
  });

  // Ground roll in selected unit
  double groundRoll(String unit) {
    if (unit == 'ft') return groundRollM * 3.28084;
    return groundRollM;
  }

  // Total distance over obstacle in selected unit
  double totalDistance(String unit) {
    if (unit == 'ft') return totalDistanceM * 3.28084;
    return totalDistanceM;
  }

  // Landing distance over 50ft obstacle in selected unit
  double landingDistanceOver50ft(String unit) {
    if (unit == 'ft') return landingDistanceOver50ftM * 3.28084;
    return landingDistanceOver50ftM;
  }
}
