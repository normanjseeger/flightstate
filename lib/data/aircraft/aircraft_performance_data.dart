// Abstract interface for aircraft takeoff performance data.
//
// Each aircraft type provides its own implementation, accommodating
// different chart types (nomogram, lookup table, formula-based).

import 'package:flightstate/domain/models/surface_type.dart';

abstract class AircraftPerformanceData {
  const AircraftPerformanceData();
  /// Human-readable aircraft name.
  String get name;

  // ── Input ranges ──

  double get oatMinC;
  double get oatMaxC;
  double get altMinFt;
  double get altMaxFt;
  double get massMinKg;
  double get massMaxKg;
  double get windMinKts;
  double get windMaxKts;
  double get obstMinM;
  double get obstMaxM;

  /// Surface types supported by this aircraft's POH data.
  List<SurfaceType> get supportedSurfaces;

  // ── Takeoff Performance ──

  /// Base ground roll (m) at max weight, paved, no wind, no obstacle.
  double getBaseGroundRoll(double oatC, double altFt);

  /// Mass correction factor (multiplier). 1.0 at max weight.
  double getMassFactor(double massKg);

  /// Wind correction factor (multiplier). 1.0 at zero wind.
  double getWindFactor(double headwindKts);

  /// Obstacle clearance factor (multiplier on ground roll → total distance).
  /// 1.0 means ground roll only. >1.0 includes climb over obstacle.
  double getObstacleFactor(double obstacleM);

  // ── Landing Performance ──

  /// Base landing ground roll (m) at max weight, paved, no wind.
  double getBaseLandingGroundRoll(double oatC, double altFt);

  /// Landing mass correction factor.
  double getLandingMassFactor(double massKg);

  /// Landing wind correction factor.
  double getLandingWindFactor(double headwindKts);

  /// Landing obstacle factor.
  double getLandingObstacleFactor(double obstacleM);
}
