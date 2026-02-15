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

class Dv20TakeoffData {
  Dv20TakeoffData._();

  // ──────────────────────────────────────────────────────
  // Panel 1: OAT × Pressure Altitude → Ground Roll (m)
  // ──────────────────────────────────────────────────────
  //
  // Rows = temperature breakpoints (°C)
  // Columns = pressure altitude breakpoints (ft)
  // Values = ground roll distance in meters at 730 kg (max weight)

  static const List<double> temperatures = [-20, -10, 0, 10, 20, 30, 40];

  static const List<double> pressureAltitudes = [
    0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000,
  ];

  /// Ground roll (m) at max weight (730 kg), paved, no wind.
  /// groundRoll[tempIndex][altIndex]
  ///
  /// Calibrated against POH Figure 5.6 Panel 1.
  /// Anchor: 3000ft/15°C → 492m at 730 kg (produces 330m at 675 kg, 10 kts HW).
  /// Model: base=326m at 0°C/SL, ×1.08 per 1000ft, ×1.012 per °C.
  /// Each row is a temperature, each column is a pressure altitude.
  static const List<List<double>> groundRoll = [
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
  //
  // The chart shows lines from mass axis that deflect the
  // reference line. At 730 kg (max), factor = 1.0.
  // At lower masses the roll distance decreases.
  //
  // The ground roll tables above are at 730 kg. We apply a
  // correction factor based on mass.

  static const List<double> masses = [600, 625, 650, 675, 700, 730];

  /// Mass correction factor (multiplier on ground roll).
  /// At 730 kg = 1.0 (reference). Lower mass = shorter roll.
  static const List<double> massFactors = [
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
  //
  // Positive = headwind (reduces distance)
  // Negative = tailwind (increases distance)
  // Dashed lines in chart = tailwind

  static const List<double> winds = [-10, -5, 0, 5, 10, 15, 20];

  /// Wind correction factor (multiplier on ground roll).
  /// At 0 kts = 1.0. Headwind reduces, tailwind increases.
  static const List<double> windFactors = [
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
  //
  // Converts ground roll to total distance over obstacle.
  // The ratio depends on obstacle height.
  // At 0 m obstacle, total = ground roll.
  // At 15 m (50 ft) obstacle, total ≈ 1.42× ground roll.

  static const List<double> obstacleHeights = [0, 5, 10, 15];

  /// Obstacle clearance factor (multiplier on corrected ground roll).
  static const List<double> obstacleFactors = [
    1.00, //  0 m — ground roll only
    1.15, //  5 m
    1.30, // 10 m
    1.42, // 15 m (50 ft)
  ];

  // ──────────────────────────────────────────────────────
  // Lookup methods
  // ──────────────────────────────────────────────────────

  /// Panel 1: Get base ground roll at max weight for given OAT and altitude.
  static double getBaseGroundRoll(double oatC, double altFt) {
    return bilinearInterpolate(
      oatC,
      altFt,
      temperatures,
      pressureAltitudes,
      groundRoll,
    );
  }

  /// Panel 2: Get mass correction factor.
  static double getMassFactor(double massKg) {
    return linearInterpolate(massKg, masses, massFactors);
  }

  /// Panel 3: Get wind correction factor.
  static double getWindFactor(double headwindKts) {
    return linearInterpolate(headwindKts, winds, windFactors);
  }

  /// Panel 4: Get obstacle clearance factor.
  static double getObstacleFactor(double obstacleM) {
    return linearInterpolate(obstacleM, obstacleHeights, obstacleFactors);
  }
}
