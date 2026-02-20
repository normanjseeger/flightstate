// Digitized takeoff performance data for Diamond DV-20 Katana.
//
// Source: POH Figure 5.6 "Take-off Distance"
// Conditions: max takeoff power, 57 kts / 105 km/h IAS,
//             level runway, paved, flaps in T/O position.
//
// The chart is a 4-panel nomogram:
//   Panel 1: OAT + Pressure Altitude → reference distance
//   Panel 2: Reference distance × mass correction
//   Panel 3: Corrected distance × headwind correction
//   Panel 4: Corrected distance → total distance over obstacle

import 'package:flightstate/core/math/interpolation.dart';
import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/domain/models/surface_type.dart';

class Dv20TakeoffData extends AircraftPerformanceData {
  const Dv20TakeoffData();

  // ── Input ranges ──

  @override
  String get name => 'Diamond DV-20 Katana';

  @override
  double get oatMinC => -20;
  @override
  double get oatMaxC => 40;
  @override
  double get altMinFt => 0;
  @override
  double get altMaxFt => 8000;
  @override
  double get massMinKg => 600;
  @override
  double get massMaxKg => 730;
  @override
  double get windMinKts => -10;
  @override
  double get windMaxKts => 20;
  @override
  double get obstMinM => 0;
  @override
  double get obstMaxM => 15;

  @override
  List<SurfaceType> get supportedSurfaces =>
      [SurfaceType.paved, SurfaceType.dryShortGrass, SurfaceType.softGrass];

  // ──────────────────────────────────────────────────────
  // Panel 1: OAT × Pressure Altitude → Ground Roll (m)
  // ──────────────────────────────────────────────────────
  //
  // Rows = temperature breakpoints (°C)
  // Columns = pressure altitude breakpoints (ft)
  // Values = ground roll distance in meters at 730 kg (max weight)

  static const List<double> _temperatures = [-20, -10, 0, 10, 20, 30, 40];

  static const List<double> _pressureAltitudes = [
    0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000,
  ];

  /// Ground roll (m) at max weight (730 kg), paved, no wind.
  /// groundRoll[tempIndex][altIndex]
  ///
  /// Calibrated against POH Figure 5.6 Panel 1.
  /// Anchor: 3000ft/15°C → 492m at 730 kg (produces 330m at 675 kg, 10 kts HW).
  /// Model: base=326m at 0°C/SL, ×1.08 per 1000ft, ×1.012 per °C.
  /// Each row is a temperature, each column is a pressure altitude.
  static const List<List<double>> _groundRoll = [
    // -20°C:  0ft   1000  2000  3000  4000  5000  6000  7000  8000
    [257, 277, 300, 323, 349, 377, 407, 440, 475],
    // -10°C
    [289, 312, 337, 364, 393, 424, 458, 495, 534],
    // 0°C
    [326, 352, 380, 411, 443, 479, 517, 559, 604],
    // 10°C
    [368, 397, 429, 463, 500, 540, 583, 630, 681],
    // 20°C
    [414, 447, 483, 522, 563, 609, 658, 710, 767],
    // 30°C
    [467, 504, 544, 588, 635, 686, 741, 800, 864],
    // 40°C
    [526, 568, 613, 662, 715, 772, 834, 901, 973],
  ];

  // ──────────────────────────────────────────────────────
  // Panel 2: Mass correction
  // ──────────────────────────────────────────────────────

  static const List<double> _masses = [600, 625, 650, 675, 700, 730];

  static const List<double> _massFactors = [
    0.68, // 600 kg
    0.74, // 625 kg
    0.80, // 650 kg
    0.86, // 675 kg
    0.93, // 700 kg
    1.00, // 730 kg
  ];

  // ──────────────────────────────────────────────────────
  // Panel 3: Headwind/tailwind correction
  // ──────────────────────────────────────────────────────

  static const List<double> _winds = [-10, -5, 0, 5, 10, 15, 20];

  static const List<double> _windFactors = [
    1.30, // 10 kts tailwind
    1.15, //  5 kts tailwind
    1.00, //  0 kts
    0.88, //  5 kts headwind
    0.78, // 10 kts headwind
    0.70, // 15 kts headwind
    0.63, // 20 kts headwind
  ];

  // ──────────────────────────────────────────────────────
  // Panel 4: Obstacle clearance
  // ──────────────────────────────────────────────────────

  static const List<double> _obstacleHeights = [0, 5, 10, 15];

  static const List<double> _obstacleFactors = [
    1.00, //  0 m — ground roll only
    1.15, //  5 m
    1.30, // 10 m
    1.42, // 15 m (50 ft)
  ];

  // ──────────────────────────────────────────────────────
  // Lookup methods
  // ──────────────────────────────────────────────────────

  @override
  double getBaseGroundRoll(double oatC, double altFt) {
    return bilinearInterpolate(
      oatC,
      altFt,
      _temperatures,
      _pressureAltitudes,
      _groundRoll,
    );
  }

  @override
  double getMassFactor(double massKg) {
    return linearInterpolate(massKg, _masses, _massFactors);
  }

  @override
  double getWindFactor(double headwindKts) {
    return linearInterpolate(headwindKts, _winds, _windFactors);
  }

  @override
  double getObstacleFactor(double obstacleM) {
    return linearInterpolate(obstacleM, _obstacleHeights, _obstacleFactors);
  }

  // ──────────────────────────────────────────────────────
  // LANDING PERFORMANCE DATA
  // Based on POH Figure 5.8 "Landing Distance"
  // ──────────────────────────────────────────────────────

  /// Landing ground roll (m) at max weight (730 kg), paved, no wind.
  /// Approximate values derived from POH (typically ~54% of takeoff)
  static const List<List<double>> _landingGroundRoll = [
    // -20°C:  0ft   1000  2000  3000  4000  5000  6000  7000  8000
    [139, 150, 162, 175, 189, 204, 220, 237, 256],
    // -10°C
    [156, 168, 182, 196, 212, 229, 247, 267, 288],
    // 0°C
    [176, 190, 205, 221, 239, 258, 278, 300, 324],
    // 10°C
    [199, 215, 232, 250, 270, 292, 315, 340, 367],
    // 20°C
    [224, 242, 261, 281, 304, 328, 354, 382, 413],
    // 30°C
    [252, 272, 293, 316, 341, 369, 398, 429, 464],
    // 40°C
    [284, 306, 330, 356, 384, 415, 448, 483, 522],
  ];

  // Landing mass factors (lighter = shorter distance)
  static const List<double> _landingMasses = [600, 625, 650, 675, 700, 730];
  static const List<double> _landingMassFactors = [
    0.62, // 600 kg
    0.68, // 625 kg
    0.74, // 650 kg
    0.80, // 675 kg
    0.90, // 700 kg
    1.00, // 730 kg
  ];

  // Landing wind factors
  static const List<double> _landingWindFactors = [
    1.35, // -10 kts tailwind
    1.18, // -5 kts tailwind
    1.00, // 0 kts
    0.85, // 5 kts headwind
    0.73, // 10 kts headwind
    0.63, // 15 kts headwind
    0.55, // 20 kts headwind
  ];

  // Landing obstacle heights (0m = ground roll, 15m = 50ft)
  static const List<double> _landingObstacleHeights = [0, 5, 10, 15];
  static const List<double> _landingObstacleFactors = [
    1.00, // 0 m
    1.18, // 5 m
    1.35, // 10 m
    1.50, // 15 m (50 ft)
  ];

  // ──────────────────────────────────────────────────────
  // Landing lookup methods
  // ──────────────────────────────────────────────────────

  @override
  double getBaseLandingGroundRoll(double oatC, double altFt) {
    return bilinearInterpolate(
      oatC,
      altFt,
      _temperatures,
      _pressureAltitudes,
      _landingGroundRoll,
    );
  }

  @override
  double getLandingMassFactor(double massKg) {
    return linearInterpolate(massKg, _landingMasses, _landingMassFactors);
  }

  @override
  double getLandingWindFactor(double headwindKts) {
    return linearInterpolate(headwindKts, _winds, _landingWindFactors);
  }

  @override
  double getLandingObstacleFactor(double obstacleM) {
    return linearInterpolate(obstacleM, _landingObstacleHeights, _landingObstacleFactors);
  }
}
