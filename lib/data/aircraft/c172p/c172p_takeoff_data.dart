// Digitized takeoff performance data for Cessna 172P (1981).
//
// Source: POH Figure 5-4 "Takeoff Distance"
// Conditions: full throttle, mixture leaned above 3000 ft,
//             flaps up, level paved runway, zero wind.
//
// Three weight tables (2400, 2200, 2000 lbs) each with
// ground roll and total distance to clear 50 ft obstacle.
// Bilinear interpolation for temp × altitude at each weight,
// then linear interpolation between weights.

import 'dart:math' as math;

import 'package:flightstate/core/math/interpolation.dart';
import 'package:flightstate/core/math/unit_conversion.dart';
import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/domain/models/surface_type.dart';

class C172pTakeoffData extends AircraftPerformanceData {
  const C172pTakeoffData();

  @override
  String get name => 'Cessna 172P';

  // ── Input ranges ──

  @override
  double get oatMinC => 0;
  @override
  double get oatMaxC => 40;
  @override
  double get altMinFt => 0;
  @override
  double get altMaxFt => 8000;
  @override
  double get massMinKg => lbsToKg(2000); // 907 kg
  @override
  double get massMaxKg => lbsToKg(2400); // 1089 kg
  @override
  double get windMinKts => -10;
  @override
  double get windMaxKts => 20;
  @override
  double get obstMinM => 0;
  @override
  double get obstMaxM => ftToM(50); // 15.24 m

  @override
  List<SurfaceType> get supportedSurfaces =>
      [SurfaceType.paved, SurfaceType.dryGrass];

  // ──────────────────────────────────────────────────────
  // POH Figure 5-4 tables
  // ──────────────────────────────────────────────────────

  static const List<double> _temperatures = [0, 10, 20, 30, 40];
  static const List<double> _altitudes = [
    0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000,
  ];
  static const List<double> _weights = [2000, 2200, 2400]; // lbs

  // ── 2400 lbs ──

  /// Ground roll (ft) at 2400 lbs. [tempIdx][altIdx]
  static const List<List<double>> _gr2400 = [
    // 0°C:   SL    1000  2000  3000  4000  5000  6000  7000  8000
    [795, 875, 960, 1055, 1165, 1285, 1425, 1580, 1755],
    // 10°C
    [860, 940, 1035, 1140, 1260, 1390, 1540, 1710, 1905],
    // 20°C
    [925, 1015, 1110, 1230, 1355, 1500, 1660, 1850, 2060],
    // 30°C
    [995, 1090, 1200, 1330, 1465, 1620, 1800, 2000, 2240],
    // 40°C
    [1065, 1170, 1290, 1425, 1575, 1745, 1940, 2220, 2520],
  ];

  /// Total distance to clear 50 ft (ft) at 2400 lbs. [tempIdx][altIdx]
  static const List<List<double>> _td2400 = [
    // 0°C
    [1460, 1615, 1790, 1975, 2185, 2420, 2690, 2990, 3340],
    // 10°C
    [1575, 1745, 1930, 2135, 2365, 2625, 2920, 3255, 3640],
    // 20°C
    [1695, 1880, 2085, 2310, 2560, 2845, 3170, 3545, 3975],
    // 30°C
    [1820, 2025, 2250, 2500, 2775, 3090, 3450, 3870, 4350],
    // 40°C
    [1955, 2180, 2425, 2710, 3015, 3365, 3770, 4240, 4800],
  ];

  // ── 2200 lbs ──

  static const List<List<double>> _gr2200 = [
    // 0°C
    [640, 705, 775, 855, 945, 1045, 1160, 1290, 1435],
    // 10°C
    [695, 765, 840, 930, 1025, 1135, 1260, 1400, 1560],
    // 20°C
    [750, 825, 910, 1005, 1110, 1230, 1365, 1520, 1695],
    // 30°C
    [810, 890, 985, 1085, 1200, 1330, 1480, 1645, 1840],
    // 40°C
    [870, 960, 1060, 1170, 1295, 1435, 1600, 1785, 2000],
  ];

  static const List<List<double>> _td2200 = [
    // 0°C
    [1195, 1325, 1470, 1625, 1800, 2000, 2225, 2480, 2775],
    // 10°C
    [1290, 1430, 1590, 1760, 1955, 2170, 2415, 2700, 3025],
    // 20°C
    [1390, 1545, 1715, 1905, 2115, 2355, 2625, 2935, 3295],
    // 30°C
    [1500, 1670, 1855, 2060, 2295, 2555, 2855, 3195, 3590],
    // 40°C
    [1615, 1800, 2005, 2230, 2485, 2775, 3105, 3485, 3920],
  ];

  // ── 2000 lbs ──

  static const List<List<double>> _gr2000 = [
    // 0°C
    [510, 565, 625, 690, 765, 850, 945, 1055, 1175],
    // 10°C
    [555, 615, 680, 750, 835, 925, 1030, 1150, 1285],
    // 20°C
    [605, 665, 740, 815, 905, 1005, 1120, 1250, 1395],
    // 30°C
    [655, 720, 800, 885, 980, 1090, 1215, 1355, 1515],
    // 40°C
    [705, 780, 865, 960, 1060, 1180, 1315, 1470, 1650],
  ];

  static const List<List<double>> _td2000 = [
    // 0°C
    [960, 1070, 1190, 1320, 1470, 1635, 1825, 2040, 2285],
    // 10°C
    [1040, 1160, 1290, 1435, 1595, 1775, 1985, 2225, 2495],
    // 20°C
    [1125, 1255, 1395, 1555, 1730, 1930, 2160, 2420, 2720],
    // 30°C
    [1215, 1355, 1510, 1685, 1875, 2095, 2345, 2635, 2965],
    // 40°C
    [1310, 1465, 1635, 1825, 2035, 2275, 2555, 2870, 3235],
  ];

  // ──────────────────────────────────────────────────────
  // Lookup methods
  // ──────────────────────────────────────────────────────

  /// Ground roll at max weight (2400 lbs) in meters.
  @override
  double getBaseGroundRoll(double oatC, double altFt) {
    final grFt = bilinearInterpolate(
      oatC,
      altFt,
      _temperatures,
      _altitudes,
      _gr2400,
    );
    return ftToM(grFt);
  }

  /// Mass correction factor. 1.0 at 2400 lbs (max weight).
  /// Interpolates between the three weight tables.
  @override
  double getMassFactor(double massKg) {
    final massLbs = kgToLbs(massKg).clamp(2000.0, 2400.0);

    // Get a reference ground roll at a mid-range condition to compute ratios
    // Use SL, 20°C as reference point
    const refTempIdx = 2; // 20°C
    const refAltIdx = 0; // SL

    final gr2400 = _gr2400[refTempIdx][refAltIdx].toDouble();
    final gr2200 = _gr2200[refTempIdx][refAltIdx].toDouble();
    final gr2000 = _gr2000[refTempIdx][refAltIdx].toDouble();

    final factor2400 = 1.0;
    final factor2200 = gr2200 / gr2400;
    final factor2000 = gr2000 / gr2400;

    return linearInterpolate(
      massLbs,
      _weights,
      [factor2000, factor2200, factor2400],
    );
  }

  /// Wind correction per POH notes:
  /// Decrease distance 10% for each 9 knots headwind.
  /// Increase distance 10% for each 2 knots tailwind.
  @override
  double getWindFactor(double headwindKts) {
    final clamped = headwindKts.clamp(-10.0, 20.0);
    if (clamped >= 0) {
      // Headwind: -10% per 9 kts
      return math.max(0.3, 1.0 - (clamped / 9.0) * 0.10);
    } else {
      // Tailwind: +10% per 2 kts
      return 1.0 + (-clamped / 2.0) * 0.10;
    }
  }

  /// Obstacle factor. The POH provides both ground roll and total distance
  /// to clear 50 ft. We interpolate between 0 m (ground roll only) and
  /// 15.24 m (50 ft, full obstacle clearance).
  @override
  double getObstacleFactor(double obstacleM) {
    if (obstacleM <= 0) return 1.0;

    // Compute ratio from 2400 lbs reference at SL, 20°C
    const refTempIdx = 2; // 20°C
    const refAltIdx = 0; // SL
    final grRef = _gr2400[refTempIdx][refAltIdx].toDouble();
    final tdRef = _td2400[refTempIdx][refAltIdx].toDouble();
    final maxRatio = tdRef / grRef;

    // Linear interpolation from 1.0 at 0m to maxRatio at 15.24m (50ft)
    final maxObstM = ftToM(50);
    final t = (obstacleM / maxObstM).clamp(0.0, 1.0);
    return 1.0 + t * (maxRatio - 1.0);
  }

  /// Calculate total distance over 50 ft obstacle directly from the table,
  /// accounting for weight interpolation. This gives more accurate results
  /// than applying a single obstacle factor.
  double getTotalDistanceFt(double oatC, double altFt, double massLbs) {
    final clampedMass = massLbs.clamp(2000.0, 2400.0);

    final td2400 = bilinearInterpolate(
      oatC, altFt, _temperatures, _altitudes, _td2400,
    );
    final td2200 = bilinearInterpolate(
      oatC, altFt, _temperatures, _altitudes, _td2200,
    );
    final td2000 = bilinearInterpolate(
      oatC, altFt, _temperatures, _altitudes, _td2000,
    );

    return linearInterpolate(
      clampedMass,
      _weights,
      [td2000, td2200, td2400],
    );
  }

  /// Calculate ground roll directly from the tables with weight interpolation.
  double getGroundRollFt(double oatC, double altFt, double massLbs) {
    final clampedMass = massLbs.clamp(2000.0, 2400.0);

    final gr2400 = bilinearInterpolate(
      oatC, altFt, _temperatures, _altitudes, _gr2400,
    );
    final gr2200 = bilinearInterpolate(
      oatC, altFt, _temperatures, _altitudes, _gr2200,
    );
    final gr2000 = bilinearInterpolate(
      oatC, altFt, _temperatures, _altitudes, _gr2000,
    );

    return linearInterpolate(
      clampedMass,
      _weights,
      [gr2000, gr2200, gr2400],
    );
  }
}
