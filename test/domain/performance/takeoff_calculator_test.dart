import 'package:flutter_test/flutter_test.dart';
import 'package:flightstate/domain/models/takeoff_input.dart';
import 'package:flightstate/domain/models/surface_type.dart';
import 'package:flightstate/domain/performance/takeoff_calculator.dart';

void main() {
  group('TakeoffCalculator - POH validation', () {
    test('POH example: 3000ft, 15°C, 675kg, 10kts HW → 330m / 470m', () {
      final input = TakeoffInput(
        oat: 15,
        pressureAltitude: 3000,
        mass: 675,
        headwind: 10,
        obstacleHeight: 15,
      );

      final result = TakeoffCalculator.calculate(input);

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

      final result = TakeoffCalculator.calculate(input);

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

      final result = TakeoffCalculator.calculate(input);

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

      final noWindResult = TakeoffCalculator.calculate(noWind);
      final withWindResult = TakeoffCalculator.calculate(withWind);

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

      final noWindResult = TakeoffCalculator.calculate(noWind);
      final tailWindResult = TakeoffCalculator.calculate(tailWind);

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

      final heavyResult = TakeoffCalculator.calculate(heavy);
      final lightResult = TakeoffCalculator.calculate(light);

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

      final pavedResult = TakeoffCalculator.calculate(paved);
      final grassResult = TakeoffCalculator.calculate(grass);

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

      final pavedResult = TakeoffCalculator.calculate(paved);
      final softResult = TakeoffCalculator.calculate(soft);

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

      final noObsResult = TakeoffCalculator.calculate(noObstacle);
      final obsResult = TakeoffCalculator.calculate(withObstacle);

      expect(obsResult.totalDistanceM, greaterThan(noObsResult.totalDistanceM));
      // Ground roll should be the same
      expect(obsResult.groundRollM, noObsResult.groundRollM);
    });
  });
}
