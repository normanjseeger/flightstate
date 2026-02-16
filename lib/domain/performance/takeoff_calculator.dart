import 'package:flightstate/core/math/unit_conversion.dart';
import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/data/aircraft/c172p/c172p_takeoff_data.dart';
import 'package:flightstate/domain/models/takeoff_input.dart';
import 'package:flightstate/domain/models/takeoff_result.dart';

class TakeoffCalculator {
  /// Calculates takeoff distances using the aircraft's performance data.
  ///
  /// For most aircraft (DV-20): 4-panel nomogram method with factors.
  /// For C172P: direct table interpolation across 3 weight tables.
  static TakeoffResult calculate(
    TakeoffInput input,
    AircraftPerformanceData data,
  ) {
    // C172P has direct weight-interpolated tables — use them for accuracy
    if (data is C172pTakeoffData) {
      return _calculateC172p(input, data);
    }

    return _calculateGeneric(input, data);
  }

  /// Generic factor-chain calculation (DV-20 nomogram style).
  static TakeoffResult _calculateGeneric(
    TakeoffInput input,
    AircraftPerformanceData data,
  ) {
    // Panel 1: Base ground roll at max weight
    final baseRoll = data.getBaseGroundRoll(input.oat, input.pressureAltitude);

    // Panel 2: Mass correction
    final massFactor = data.getMassFactor(input.mass);
    final massAdjusted = baseRoll * massFactor;

    // Panel 3: Wind correction
    final windFactor = data.getWindFactor(input.headwind);
    final windAdjusted = massAdjusted * windFactor;

    // Surface correction
    final groundRoll = windAdjusted * input.surfaceType.correctionFactor;

    // Panel 4: Obstacle clearance
    final obstacleFactor = data.getObstacleFactor(input.obstacleHeight);
    final totalDistance = groundRoll * obstacleFactor;

    return TakeoffResult(
      groundRollM: groundRoll,
      totalDistanceM: totalDistance,
    );
  }

  /// C172P-specific: interpolate directly across 3 weight tables.
  static TakeoffResult _calculateC172p(
    TakeoffInput input,
    C172pTakeoffData data,
  ) {
    final massLbs = kgToLbs(input.mass);

    // Direct table lookup with weight interpolation
    final grFt = data.getGroundRollFt(
      input.oat,
      input.pressureAltitude,
      massLbs,
    );
    final tdFt = data.getTotalDistanceFt(
      input.oat,
      input.pressureAltitude,
      massLbs,
    );

    // Wind correction
    final windFactor = data.getWindFactor(input.headwind);

    // Surface correction
    final surfaceFactor = input.surfaceType.correctionFactor;

    final groundRollM = ftToM(grFt) * windFactor * surfaceFactor;

    // For total distance, interpolate based on obstacle height
    final maxObstM = ftToM(50);
    if (input.obstacleHeight <= 0) {
      return TakeoffResult(
        groundRollM: groundRollM,
        totalDistanceM: groundRollM,
      );
    }

    final totalOverObstacleM = ftToM(tdFt) * windFactor * surfaceFactor;
    final t = (input.obstacleHeight / maxObstM).clamp(0.0, 1.0);
    final totalDistanceM =
        groundRollM + t * (totalOverObstacleM - groundRollM);

    return TakeoffResult(
      groundRollM: groundRollM,
      totalDistanceM: totalDistanceM,
    );
  }
}
