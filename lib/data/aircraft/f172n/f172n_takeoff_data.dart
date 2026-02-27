// Reims Cessna F172N performance data
// Source: Flight Manual - Takeoff Distance (Short Field) & Landing Distance

import 'package:flightstate/core/math/interpolation.dart';
import 'package:flightstate/core/math/unit_conversion.dart';
import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/domain/models/surface_type.dart';

class F172nTakeoffData extends AircraftPerformanceData {
  const F172nTakeoffData();

  @override
  String get name => 'Reims Cessna F172N';

  @override
  double get oatMinC => 0;
  @override
  double get oatMaxC => 40;
  @override
  double get altMinFt => 0;
  @override
  double get altMaxFt => 8000;
  @override
  double get massMinKg => 862;
  @override
  double get massMaxKg => 1043;
  @override
  double get windMinKts => -10;
  @override
  double get windMaxKts => 20;
  @override
  double get obstMinM => 0;
  @override
  double get obstMaxM => ftToM(50);

  @override
  List<SurfaceType> get supportedSurfaces => [
        SurfaceType.paved,
        SurfaceType.dryShortGrass,
      ];

  static const List<double> _temperatures = [0, 10, 20, 30, 40];
  static const List<double> _altitudes = [0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000];
  static const List<double> _weights = [1900, 2100, 2300];

  // Takeoff tables - max weight 1043 kg
  static const List<List<double>> _gr2300 = [
    [219, 241, 264, 290, 319, 351, 386, 427, 472],
    [236, 259, 283, 312, 343, 378, 416, 460, 511],
    [255, 279, 305, 335, 369, 407, 450, 497, 550],
    [273, 299, 328, 361, 396, 437, 483, 535, 593],
    [293, 320, 352, 387, 427, 469, 520, 576, 639],
  ];

  static const List<List<double>> _td2300 = [
    [396, 433, 474, 521, 573, 632, 703, 782, 875],
    [424, 465, 509, 559, 617, 683, 757, 844, 948],
    [454, 497, 546, 600, 663, 735, 817, 914, 1029],
    [485, 532, 584, 645, 712, 791, 882, 989, 1119],
    [518, 568, 626, 690, 765, 852, 953, 1071, 1216],
  ];

  static const List<List<double>> _gr2100 = [
    [178, 195, 213, 235, 258, 283, 312, 344, 379],
    [192, 210, 230, 253, 277, 305, 335, 370, 410],
    [207, 226, 247, 271, 299, 328, 361, 399, 442],
    [221, 242, 265, 291, 320, 352, 389, 430, 475],
    [238, 259, 285, 312, 344, 378, 418, 462, 512],
  ];

  static const List<List<double>> _td2100 = [
    [326, 355, 381, 424, 465, 512, 564, 625, 693],
    [347, 379, 415, 454, 500, 550, 607, 674, 750],
    [372, 405, 443, 486, 535, 590, 652, 725, 809],
    [396, 433, 474, 521, 573, 632, 701, 780, 873],
    [424, 463, 507, 558, 614, 680, 754, 840, 942],
  ];

  static const List<List<double>> _gr1900 = [
    [143, 157, 171, 187, 204, 226, 247, 273, 300],
    [154, 168, 184, 201, 221, 242, 263, 294, 325],
    [165, 180, 197, 216, 238, 261, 287, 315, 349],
    [177, 194, 212, 232, 255, 281, 308, 340, 375],
    [189, 207, 227, 248, 273, 300, 331, 364, 402],
  ];

  static const List<List<double>> _td1900 = [
    [264, 287, 312, 340, 372, 408, 448, 494, 546],
    [280, 306, 334, 364, 398, 437, 480, 530, 587],
    [300, 326, 357, 389, 427, 468, 515, 568, 629],
    [319, 347, 379, 416, 456, 500, 552, 610, 677],
    [340, 370, 405, 443, 486, 535, 591, 654, 727],
  ];

  // Landing tables
  static const List<List<double>> _landingGr1043 = [
    [151, 155, 162, 168, 174, 180, 187, 195, 203],
    [155, 162, 168, 174, 180, 187, 195, 201, 210],
    [162, 168, 174, 180, 187, 194, 201, 209, 216],
    [166, 172, 180, 186, 194, 200, 209, 216, 224],
    [172, 178, 186, 192, 200, 207, 215, 223, 232],
  ];

  static const List<List<double>> _landingTd1043 = [
    [367, 376, 386, 396, 407, 418, 431, 443, 457],
    [376, 386, 396, 407, 418, 431, 443, 456, 469],
    [386, 396, 407, 418, 430, 442, 454, 468, 482],
    [395, 405, 418, 428, 440, 453, 468, 480, 494],
    [405, 416, 428, 439, 451, 465, 479, 492, 507],
  ];

  double getGroundRollFt(double oatC, double altFt, double massLbs) {
    final gr2300 = bilinearInterpolate(oatC, altFt, _temperatures, _altitudes, _gr2300).toDouble();
    final gr2100 = bilinearInterpolate(oatC, altFt, _temperatures, _altitudes, _gr2100).toDouble();
    final gr1900 = bilinearInterpolate(oatC, altFt, _temperatures, _altitudes, _gr1900).toDouble();
    return linearInterpolate(massLbs, _weights, [gr1900, gr2100, gr2300], tolerance: 5.0);
  }

  double getTotalDistanceFt(double oatC, double altFt, double massLbs) {
    final td2300 = bilinearInterpolate(oatC, altFt, _temperatures, _altitudes, _td2300).toDouble();
    final td2100 = bilinearInterpolate(oatC, altFt, _temperatures, _altitudes, _td2100).toDouble();
    final td1900 = bilinearInterpolate(oatC, altFt, _temperatures, _altitudes, _td1900).toDouble();
    return linearInterpolate(massLbs, _weights, [td1900, td2100, td2300], tolerance: 5.0);
  }

  @override
  double getBaseGroundRoll(double oatC, double altFt) {
    return ftToM(getGroundRollFt(oatC, altFt, _weights.last));
  }

  @override
  double getMassFactor(double massKg) => 1.0;

  @override
  double getWindFactor(double headwindKts) {
    final clamped = headwindKts.clamp(-10.0, 20.0);
    return clamped >= 0 ? 1.0 - (clamped / 9.0) * 0.10 : 1.0 + (-clamped / 2.0) * 0.10;
  }

  @override
  double getObstacleFactor(double obstacleM) {
    if (obstacleM <= 0) return 1.0;
    final grRef = _gr2300[2][0].toDouble();
    final tdRef = _td2300[2][0].toDouble();
    final maxRatio = tdRef / grRef;
    final maxObstM = ftToM(50);
    final t = (obstacleM / maxObstM).clamp(0.0, 1.0);
    return 1.0 + t * (maxRatio - 1.0);
  }

  double getLandingGroundRollFt(double oatC, double altFt, double massLbs) {
    final grAtMax = bilinearInterpolate(oatC, altFt, _temperatures, _altitudes, _landingGr1043).toDouble();
    return grAtMax * (massLbs / _weights.last);
  }

  double getLandingTotalDistanceFt(double oatC, double altFt, double massLbs) {
    final tdAtMax = bilinearInterpolate(oatC, altFt, _temperatures, _altitudes, _landingTd1043).toDouble();
    return tdAtMax * (massLbs / _weights.last);
  }

  @override
  double getBaseLandingGroundRoll(double oatC, double altFt) {
    return ftToM(getLandingGroundRollFt(oatC, altFt, _weights.last));
  }

  @override
  double getLandingMassFactor(double massKg) => 1.0;

  @override
  double getLandingWindFactor(double headwindKts) => getWindFactor(headwindKts);

  @override
  double getLandingObstacleFactor(double obstacleM) {
    if (obstacleM <= 0) return 1.0;
    final grRef = _landingGr1043[2][0].toDouble();
    final tdRef = _landingTd1043[2][0].toDouble();
    final maxRatio = tdRef / grRef;
    final maxObstM = ftToM(50);
    final t = (obstacleM / maxObstM).clamp(0.0, 1.0);
    return 1.0 + t * (maxRatio - 1.0);
  }

  @override
  List<String> get takeoffConditions => [
        'Flaps up',
        'Full Throttle Prior to Brake Release',
        'Paved, Level, Dry Runway',
        'Zero Wind',
      ];

  @override
  List<String> get takeoffNotes => [
        'Short field technique as specified in Section 4.',
        'Prior to takeoff from fields above 3000 ft - 914 m elevation, the mixture should be leaned to give maximum RPM in a full throttle, static runup.',
        'Decrease distances 10% for each 9 knots headwind. For operation with tailwinds up to 10 knots, increase distances by 10% for each 2 knots.',
        'For operation on a dry, grass runway, increase distances by 15% of the "ground roll" figure.',
      ];

  @override
  List<String> get landingConditions => [
        'Flaps 40°',
        'Power Off',
        'Maximum Braking',
        'Paved, Level, Dry Runway',
        'Zero Wind',
      ];

  @override
  List<String> get landingNotes => [
        'Short field technique as specified in Section 4.',
        'Decrease distances 10% for each 9 knots headwind. For operation with tailwinds up to 10 knots, increase distances by 10% for each 2 knots.',
        'For operation on a dry, grass runway, increase distances by 45% of the "ground roll" figure.',
      ];
}
