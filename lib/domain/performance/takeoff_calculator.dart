import 'package:flightstate/core/math/unit_conversion.dart';
import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/data/aircraft/c172p/c172p_takeoff_data.dart';
import 'package:flightstate/data/aircraft/f172n/f172n_takeoff_data.dart';
import 'package:flightstate/domain/models/takeoff_input.dart';
import 'package:flightstate/domain/models/takeoff_result.dart';

class TakeoffCalculator {
  /// Calculates takeoff distances using the aircraft's performance data.
  ///
  /// For most aircraft (DV-20): 4-panel nomogram method with factors.
  /// For C172P: direct table interpolation across 3 weight tables.
  static TakeoffResult calculate(
    TakeoffInput input,
    AircraftPerformanceData data, {
    double safetyMargin = 1.0,
  }) {
    // C172P has direct weight-interpolated tables — use them for accuracy
    if (data is C172pTakeoffData) {
      return _calculateC172p(input, data, safetyMargin);
    }

    // F172N also has direct weight-interpolated tables
    if (data is F172nTakeoffData) {
      return _calculateF172n(input, data, safetyMargin);
    }

    return _calculateGeneric(input, data, safetyMargin);
  }

  /// Generic factor-chain calculation (DV-20 nomogram style).
  static TakeoffResult _calculateGeneric(
    TakeoffInput input,
    AircraftPerformanceData data,
    double safetyMargin,
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
    final surfaceFactor = input.surfaceType.correctionFactor;
    final groundRoll = windAdjusted * surfaceFactor;

    // Panel 4: Obstacle clearance
    final obstacleFactor = data.getObstacleFactor(input.obstacleHeight);
    final totalDistance = groundRoll * obstacleFactor;

    return TakeoffResult(
      groundRollM: groundRoll,
      totalDistanceM: totalDistance,
      baseGroundRollM: baseRoll,
      massFactor: massFactor,
      windFactor: windFactor,
      surfaceFactor: surfaceFactor,
      obstacleFactor: obstacleFactor,
      safetyMargin: safetyMargin,
    );
  }

  /// C172P-specific: interpolate directly across 3 weight tables.
  static TakeoffResult _calculateC172p(
    TakeoffInput input,
    C172pTakeoffData data,
    double safetyMargin,
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

    final baseGroundRollM = ftToM(grFt);
    final groundRollM = baseGroundRollM * windFactor * surfaceFactor;

    // For total distance, interpolate based on obstacle height
    final maxObstM = ftToM(50);

    // Snap obstacle height to 0 or 50 ft if very close (within 0.3 m / ~1 ft)
    var obstHeight = input.obstacleHeight;
    if ((obstHeight - 0).abs() < 0.3) obstHeight = 0;
    if ((obstHeight - maxObstM).abs() < 0.3) obstHeight = maxObstM;

    if (obstHeight <= 0) {
      return TakeoffResult(
        groundRollM: groundRollM,
        totalDistanceM: groundRollM,
        baseGroundRollM: baseGroundRollM,
        massFactor: 1.0, // built into table lookup
        windFactor: windFactor,
        surfaceFactor: surfaceFactor,
        obstacleFactor: 1.0,
        safetyMargin: safetyMargin,
      );
    }

    final baseTotalOverObstacleM = ftToM(tdFt);
    final totalOverObstacleM = baseTotalOverObstacleM * windFactor * surfaceFactor;
    final t = (obstHeight / maxObstM).clamp(0.0, 1.0);
    final totalDistanceM =
        groundRollM + t * (totalOverObstacleM - groundRollM);

    // Effective obstacle factor for display
    final obstacleFactor = groundRollM > 0 ? totalDistanceM / groundRollM : 1.0;

    return TakeoffResult(
      groundRollM: groundRollM,
      totalDistanceM: totalDistanceM,
      baseGroundRollM: baseGroundRollM,
      massFactor: 1.0, // built into table lookup
      windFactor: windFactor,
      surfaceFactor: surfaceFactor,
      obstacleFactor: obstacleFactor,
      safetyMargin: safetyMargin,
    );
  }

  /// F172N-specific: interpolate directly across 3 weight tables.
  static TakeoffResult _calculateF172n(
    TakeoffInput input,
    F172nTakeoffData data,
    double safetyMargin,
  ) {
    final massLbs = kgToLbs(input.mass);

    // Direct table lookup with weight interpolation (F172N tables are in meters)
    final grM = data.getGroundRollM(
      input.oat,
      input.pressureAltitude,
      massLbs,
    );
    final tdM = data.getTotalDistanceM(
      input.oat,
      input.pressureAltitude,
      massLbs,
    );

    // Wind correction
    final windFactor = data.getWindFactor(input.headwind);

    // Surface correction
    final surfaceFactor = input.surfaceType.correctionFactor;

    final baseGroundRollM = grM;
    final groundRollM = baseGroundRollM * windFactor * surfaceFactor;

    // For total distance, interpolate based on obstacle height
    final maxObstM = ftToM(50);

    // Snap obstacle height to 0 or 50 ft if very close
    var obstHeight = input.obstacleHeight;
    if ((obstHeight - 0).abs() < 0.3) obstHeight = 0;
    if ((obstHeight - maxObstM).abs() < 0.3) obstHeight = maxObstM;

    if (obstHeight <= 0) {
      return TakeoffResult(
        groundRollM: groundRollM,
        totalDistanceM: groundRollM,
        baseGroundRollM: baseGroundRollM,
        massFactor: 1.0, // built into table lookup
        windFactor: windFactor,
        surfaceFactor: surfaceFactor,
        obstacleFactor: 1.0,
        safetyMargin: safetyMargin,
      );
    }

    final baseTotalOverObstacleM = tdM;
    final totalOverObstacleM = baseTotalOverObstacleM * windFactor * surfaceFactor;
    final t = (obstHeight / maxObstM).clamp(0.0, 1.0);
    final totalDistanceM =
        groundRollM + t * (totalOverObstacleM - groundRollM);

    // Effective obstacle factor for display
    final obstacleFactor = groundRollM > 0 ? totalDistanceM / groundRollM : 1.0;

    return TakeoffResult(
      groundRollM: groundRollM,
      totalDistanceM: totalDistanceM,
      baseGroundRollM: baseGroundRollM,
      massFactor: 1.0, // built into table lookup
      windFactor: windFactor,
      surfaceFactor: surfaceFactor,
      obstacleFactor: obstacleFactor,
      safetyMargin: safetyMargin,
    );
  }
}
