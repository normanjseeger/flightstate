class TakeoffResult {
  /// Ground roll distance in meters (before safety margin)
  final double groundRollM;

  /// Distance to clear obstacle in meters (before safety margin)
  final double totalDistanceM;

  // Breakdown fields for transparency
  /// Base ground roll from POH (before any corrections)
  final double baseGroundRollM;

  /// Mass correction factor applied
  final double massFactor;

  /// Wind correction factor applied
  final double windFactor;

  /// Surface correction factor applied
  final double surfaceFactor;

  /// Obstacle clearance factor applied (totalDistance / groundRoll)
  final double obstacleFactor;

  /// Safety margin multiplier
  final double safetyMargin;

  const TakeoffResult({
    required this.groundRollM,
    required this.totalDistanceM,
    this.baseGroundRollM = 0,
    this.massFactor = 1.0,
    this.windFactor = 1.0,
    this.surfaceFactor = 1.0,
    this.obstacleFactor = 1.0,
    this.safetyMargin = 1.0,
  });

  /// Ground roll with safety margin applied
  double get groundRollWithSafetyM => groundRollM * safetyMargin;

  /// Total distance with safety margin applied
  double get totalDistanceWithSafetyM => totalDistanceM * safetyMargin;
}
