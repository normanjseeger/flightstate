class TakeoffResult {
  /// Ground roll distance in meters
  final double groundRollM;

  /// Distance to clear obstacle in meters
  final double totalDistanceM;

  const TakeoffResult({
    required this.groundRollM,
    required this.totalDistanceM,
  });
}
