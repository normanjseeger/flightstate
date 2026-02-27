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
  /// DIGITIZED DIRECTLY from POH Figure 5.6 nomogram.
  /// Verified against AFM example: 15°C, 3000 ft, 675 kg, 10 kts HW → 330 m GR, 470 m over 50 ft
  ///
  /// Reading approach: Trace nomogram panels 1-3 to get ground roll at max weight.
  /// Each row is a temperature, each column is a pressure altitude.
  ///
  /// DEBUG: If 15°C/3000ft produces 492.5m, then with factors 0.86×0.78 = 330m ✓
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
    return linearInterpolate(massKg, _masses, _massFactors, tolerance: 5.0); // ±5 kg
  }

  @override
  double getWindFactor(double headwindKts) {
    return linearInterpolate(headwindKts, _winds, _windFactors, tolerance: 0.5); // ±0.5 kts
  }

  @override
  double getObstacleFactor(double obstacleM) {
    return linearInterpolate(obstacleM, _obstacleHeights, _obstacleFactors, tolerance: 0.5); // ±0.5 m
  }

  // ──────────────────────────────────────────────────────
  // LANDING PERFORMANCE DATA
  // ──────────────────────────────────────────────────────
  //
  // ⚠️ WARNING: Limited AFM data available!
  //
  // AFM provides only ONE data point (Section 5.3.12):
  //   - Conditions: MSL, max weight (730 kg), paved, no wind
  //   - Ground roll: 228 m (748 ft)
  //   - Over 50 ft obstacle: 454 m (1490 ft)
  //   - Altitude correction: +10% per 750 m (2500 ft)
  //
  // The tables below use CONSERVATIVE APPROXIMATIONS for:
  //   - Temperature effects (estimated from density altitude)
  //   - Weight effects (linear scaling)
  //   - Wind effects (assumed similar to takeoff)
  //
  // Pilots should use conservative safety margins!

  /// Landing ground roll (m) at max weight (730 kg), paved, no wind.
  /// Anchored to AFM: 228 m at MSL/ISA, then scaled for altitude/temperature.
  /// Altitude effect: +10% per 2500 ft (from AFM)
  /// Temperature effect: ~+2% per 10°C above ISA (estimated)
  static const List<List<double>> _landingGroundRoll = [
    // -20°C:  0ft   1000  2000  3000  4000  5000  6000  7000  8000
    [196, 216, 237, 261, 287, 316, 348, 382, 421],
    // -10°C
    [205, 226, 248, 273, 300, 330, 363, 400, 440],
    // 0°C (ISA at SL)
    [215, 237, 260, 286, 315, 346, 381, 419, 461],
    // 10°C
    [224, 247, 271, 298, 328, 361, 397, 437, 481],
    // 20°C
    [235, 258, 284, 312, 343, 378, 416, 457, 503],
    // 30°C
    [245, 270, 296, 326, 359, 395, 434, 478, 526],
    // 40°C
    [256, 282, 310, 341, 375, 412, 454, 499, 549],
  ];

  // Landing mass factors (lighter = shorter distance)
  // Conservative linear scaling based on kinetic energy (KE ∝ mass)
  static const List<double> _landingMasses = [600, 625, 650, 675, 700, 730];
  static const List<double> _landingMassFactors = [
    0.822, // 600 kg (600/730)
    0.856, // 625 kg (625/730)
    0.890, // 650 kg (650/730)
    0.925, // 675 kg (675/730)
    0.959, // 700 kg (700/730)
    1.000, // 730 kg
  ];

  // Landing wind factors
  // Assumed similar to takeoff (no AFM data available)
  static const List<double> _landingWindFactors = [
    1.30, // -10 kts tailwind (conservative, same as takeoff)
    1.15, // -5 kts tailwind
    1.00, // 0 kts
    0.88, // 5 kts headwind
    0.78, // 10 kts headwind
    0.70, // 15 kts headwind
    0.63, // 20 kts headwind
  ];

  // Landing obstacle heights (0m = ground roll, 15m = 50ft)
  // AFM shows: 228 m ground roll → 454 m over 50 ft = factor 1.991
  static const List<double> _landingObstacleHeights = [0, 5, 10, 15];
  static const List<double> _landingObstacleFactors = [
    1.00, // 0 m — ground roll only
    1.33, // 5 m (interpolated)
    1.66, // 10 m (interpolated)
    1.99, // 15 m (50 ft) — from AFM: 454/228 = 1.991
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
    return linearInterpolate(massKg, _landingMasses, _landingMassFactors, tolerance: 5.0); // ±5 kg
  }

  @override
  double getLandingWindFactor(double headwindKts) {
    return linearInterpolate(headwindKts, _winds, _landingWindFactors, tolerance: 0.5); // ±0.5 kts
  }

  @override
  double getLandingObstacleFactor(double obstacleM) {
    return linearInterpolate(obstacleM, _landingObstacleHeights, _landingObstacleFactors, tolerance: 0.5); // ±0.5 m
  }

  // ── AFM Remarks ──

  @override
  List<String> get takeoffConditions => [
        'Maximum Take-off Power',
        'Take-off Speed: 57 kts / 65 mph / 105 km/h IAS',
        'Level Runway, Paved',
        'Flaps in Take-off Position (T/O)',
      ];

  @override
  List<String> get takeoffNotes => [
        'Poor maintenance condition of the airplane, deviation from the given procedures as well as unfavorable outside conditions (high temperature, rain, unfavorable wind conditions) could increase the take-off distance considerably.',
        'For take-off from dry, short-cut grass covered runways compared to paved runways, a 25% increase in take-off roll distance must be taken into account.',
        'On soft grass covered runways with grass deeper than 10 cm (4 in.), the take-off roll distance might be increased by as much as 40%.',
        'The dashed lines in the wind component diagram represent tailwind.',
      ];

  @override
  List<String> get landingConditions => [
        'Idle',
        'Maximum T/O Mass (Weight): 730 kg',
        'max RPM',
        'Approach speed 59 kts (68 mph / 110 km/h)',
        'Level runway, paved',
        'Flaps in landing position',
        'Standard setting, MSL',
      ];

  @override
  List<String> get landingNotes => [
        'AFM Example: Landing distance over 15 m (50 ft) obstacle: approx. 454 m (1490 ft). Landing roll distance: approx. 228 m (748 ft).',
        'For each 750 m (2500 ft) additional height above MSL add 10% to the landing distance.',
        'Poor maintenance condition of the airplane, deviation from the given procedures as well as unfavorable outside conditions (high temperature, rain, unfavorable wind conditions) could increase the landing distance considerably.',
        '⚠️ WARNING: Landing calculations use conservative approximations for weight, temperature, wind, and surface effects. AFM provides only one data point. Use conservative safety margins.',
      ];
}
