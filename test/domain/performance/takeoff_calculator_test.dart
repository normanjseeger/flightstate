import 'package:flutter_test/flutter_test.dart';
import 'package:flightstate/core/math/unit_conversion.dart';
import 'package:flightstate/data/aircraft/c172p/c172p_takeoff_data.dart';
import 'package:flightstate/data/aircraft/dv20/dv20_takeoff_data.dart';
import 'package:flightstate/domain/models/takeoff_input.dart';
import 'package:flightstate/domain/models/surface_type.dart';
import 'package:flightstate/domain/performance/takeoff_calculator.dart';

void main() {
  const dv20 = Dv20TakeoffData();
  const c172p = C172pTakeoffData();

  group('TakeoffCalculator - DV-20 POH validation', () {
    test('POH example: 3000ft, 15°C, 675kg, 10kts HW → 330m / 470m', () {
      final input = TakeoffInput(
        oat: 15,
        pressureAltitude: 3000,
        mass: 675,
        headwind: 10,
        obstacleHeight: 15,
      );

      final result = TakeoffCalculator.calculate(input, dv20);

      // POH states: 330 m ground roll, 470 m over 15m obstacle
      // Accept ±5% tolerance
      expect(result.groundRollM, closeTo(330, 330 * 0.05));
      expect(result.totalDistanceM, closeTo(470, 470 * 0.05));
    });

    test('sea level, ISA, max weight, no wind → base reference', () {
      final input = TakeoffInput(
        oat: 15,
        pressureAltitude: 0,
        mass: 730,
        headwind: 0,
        obstacleHeight: 0,
      );

      final result = TakeoffCalculator.calculate(input, dv20);

      // At sea level, 15°C, max weight, no wind: ~391 m
      expect(result.groundRollM, closeTo(391, 40));
      expect(result.totalDistanceM, result.groundRollM); // 0m obstacle
    });

    test('hot and high: 8000ft, 40°C, max weight, no wind', () {
      final input = TakeoffInput(
        oat: 40,
        pressureAltitude: 8000,
        mass: 730,
        headwind: 0,
        obstacleHeight: 15,
      );

      final result = TakeoffCalculator.calculate(input, dv20);

      // Worst case: should be very long
      expect(result.groundRollM, greaterThan(550));
      expect(result.totalDistanceM, greaterThan(result.groundRollM));
    });

    test('headwind reduces distance', () {
      final noWind = TakeoffInput(
        oat: 15,
        pressureAltitude: 2000,
        mass: 700,
        headwind: 0,
        obstacleHeight: 0,
      );
      final withWind = noWind.copyWith(headwind: 10);

      final noWindResult = TakeoffCalculator.calculate(noWind, dv20);
      final withWindResult = TakeoffCalculator.calculate(withWind, dv20);

      expect(withWindResult.groundRollM, lessThan(noWindResult.groundRollM));
    });

    test('tailwind increases distance', () {
      final noWind = TakeoffInput(
        oat: 15,
        pressureAltitude: 2000,
        mass: 700,
        headwind: 0,
        obstacleHeight: 0,
      );
      final tailWind = noWind.copyWith(headwind: -10);

      final noWindResult = TakeoffCalculator.calculate(noWind, dv20);
      final tailWindResult = TakeoffCalculator.calculate(tailWind, dv20);

      expect(tailWindResult.groundRollM, greaterThan(noWindResult.groundRollM));
    });

    test('lighter weight reduces distance', () {
      final heavy = TakeoffInput(
        oat: 15,
        pressureAltitude: 2000,
        mass: 730,
        headwind: 0,
        obstacleHeight: 0,
      );
      final light = heavy.copyWith(mass: 600);

      final heavyResult = TakeoffCalculator.calculate(heavy, dv20);
      final lightResult = TakeoffCalculator.calculate(light, dv20);

      expect(lightResult.groundRollM, lessThan(heavyResult.groundRollM));
    });

    test('surface correction: dry short grass +25%', () {
      final paved = TakeoffInput(
        oat: 15,
        pressureAltitude: 2000,
        mass: 700,
        headwind: 0,
        obstacleHeight: 0,
      );
      final grass = paved.copyWith(surfaceType: SurfaceType.dryShortGrass);

      final pavedResult = TakeoffCalculator.calculate(paved, dv20);
      final grassResult = TakeoffCalculator.calculate(grass, dv20);

      expect(
        grassResult.groundRollM / pavedResult.groundRollM,
        closeTo(1.25, 0.01),
      );
    });

    test('surface correction: soft grass +40%', () {
      final paved = TakeoffInput(
        oat: 15,
        pressureAltitude: 2000,
        mass: 700,
        headwind: 0,
        obstacleHeight: 0,
      );
      final soft = paved.copyWith(surfaceType: SurfaceType.softGrass);

      final pavedResult = TakeoffCalculator.calculate(paved, dv20);
      final softResult = TakeoffCalculator.calculate(soft, dv20);

      expect(
        softResult.groundRollM / pavedResult.groundRollM,
        closeTo(1.40, 0.01),
      );
    });

    test('obstacle height increases total distance', () {
      final noObstacle = TakeoffInput(
        oat: 15,
        pressureAltitude: 2000,
        mass: 700,
        headwind: 0,
        obstacleHeight: 0,
      );
      final withObstacle = noObstacle.copyWith(obstacleHeight: 15);

      final noObsResult = TakeoffCalculator.calculate(noObstacle, dv20);
      final obsResult = TakeoffCalculator.calculate(withObstacle, dv20);

      expect(obsResult.totalDistanceM, greaterThan(noObsResult.totalDistanceM));
      // Ground roll should be the same
      expect(obsResult.groundRollM, noObsResult.groundRollM);
    });
  });

  group('TakeoffCalculator - C172P validation', () {
    test('SL, 20°C, 2400 lbs, no wind → ground roll matches POH', () {
      final input = TakeoffInput(
        oat: 20,
        pressureAltitude: 0,
        mass: lbsToKg(2400),
        headwind: 0,
        obstacleHeight: 0,
      );

      final result = TakeoffCalculator.calculate(input, c172p);

      // POH: 925 ft ground roll at SL, 20°C, 2400 lbs
      final expectedM = ftToM(925);
      expect(result.groundRollM, closeTo(expectedM, expectedM * 0.02));
    });

    test('SL, 20°C, 2400 lbs → total over 50ft matches POH', () {
      final input = TakeoffInput(
        oat: 20,
        pressureAltitude: 0,
        mass: lbsToKg(2400),
        headwind: 0,
        obstacleHeight: ftToM(50),
      );

      final result = TakeoffCalculator.calculate(input, c172p);

      // POH: 1695 ft total to clear 50 ft at SL, 20°C, 2400 lbs
      final expectedM = ftToM(1695);
      expect(result.totalDistanceM, closeTo(expectedM, expectedM * 0.02));
    });

    test('lighter weight reduces distance (2000 lbs vs 2400 lbs)', () {
      final heavy = TakeoffInput(
        oat: 20,
        pressureAltitude: 0,
        mass: lbsToKg(2400),
        headwind: 0,
        obstacleHeight: 0,
      );
      final light = heavy.copyWith(mass: lbsToKg(2000));

      final heavyResult = TakeoffCalculator.calculate(heavy, c172p);
      final lightResult = TakeoffCalculator.calculate(light, c172p);

      // POH: 605 ft at 2000 lbs vs 925 ft at 2400 lbs
      expect(lightResult.groundRollM, lessThan(heavyResult.groundRollM));
      expect(
        lightResult.groundRollM,
        closeTo(ftToM(605), ftToM(605) * 0.02),
      );
    });

    test('headwind reduces distance per POH formula', () {
      final noWind = TakeoffInput(
        oat: 20,
        pressureAltitude: 0,
        mass: lbsToKg(2400),
        headwind: 0,
        obstacleHeight: 0,
      );
      final withWind = noWind.copyWith(headwind: 9);

      final noWindResult = TakeoffCalculator.calculate(noWind, c172p);
      final withWindResult = TakeoffCalculator.calculate(withWind, c172p);

      // 9 kts headwind → -10% reduction
      expect(
        withWindResult.groundRollM / noWindResult.groundRollM,
        closeTo(0.90, 0.01),
      );
    });

    test('dry grass adds 15% to ground roll', () {
      final paved = TakeoffInput(
        oat: 20,
        pressureAltitude: 0,
        mass: lbsToKg(2400),
        headwind: 0,
        obstacleHeight: 0,
      );
      final grass = paved.copyWith(surfaceType: SurfaceType.dryGrass);

      final pavedResult = TakeoffCalculator.calculate(paved, c172p);
      final grassResult = TakeoffCalculator.calculate(grass, c172p);

      expect(
        grassResult.groundRollM / pavedResult.groundRollM,
        closeTo(1.15, 0.01),
      );
    });

    test('hot and high: 4000ft, 30°C, 2400 lbs', () {
      final input = TakeoffInput(
        oat: 30,
        pressureAltitude: 4000,
        mass: lbsToKg(2400),
        headwind: 0,
        obstacleHeight: 0,
      );

      final result = TakeoffCalculator.calculate(input, c172p);

      // POH: 1465 ft ground roll
      final expectedM = ftToM(1465);
      expect(result.groundRollM, closeTo(expectedM, expectedM * 0.02));
    });

    test('mid-weight interpolation (2200 lbs)', () {
      final input = TakeoffInput(
        oat: 20,
        pressureAltitude: 0,
        mass: lbsToKg(2200),
        headwind: 0,
        obstacleHeight: 0,
      );

      final result = TakeoffCalculator.calculate(input, c172p);

      // POH: 750 ft at 2200 lbs, SL, 20°C
      final expectedM = ftToM(750);
      expect(result.groundRollM, closeTo(expectedM, expectedM * 0.02));
    });
  });
}
