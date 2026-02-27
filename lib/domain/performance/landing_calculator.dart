// Landing performance calculator
// Based on typical GA aircraft POH data

import 'package:flightstate/core/math/unit_conversion.dart';
import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/data/aircraft/c172p/c172p_takeoff_data.dart';
import 'package:flightstate/domain/models/landing_input.dart';
import 'package:flightstate/domain/models/landing_result.dart';

class LandingCalculator {
  final AircraftPerformanceData data;

  const LandingCalculator(this.data);

  LandingResult calculate(LandingInput input, {double safetyMargin = 1.0}) {
    // C172P has direct weight-interpolated landing tables — use them for accuracy
    if (data is C172pTakeoffData) {
      return _calculateC172p(input, data as C172pTakeoffData, safetyMargin);
    }

    return _calculateGeneric(input, safetyMargin);
  }

  /// Generic factor-chain calculation for aircraft without landing tables.
  LandingResult _calculateGeneric(LandingInput input, double safetyMargin) {
    // Get base ground roll from data
    double baseGroundRoll = data.getBaseLandingGroundRoll(
      input.oatC,
      input.pressureAltitudeFt,
    );

    // Apply mass correction
    double massFactor = data.getLandingMassFactor(input.massKg);

    // Apply wind correction
    double windFactor = data.getLandingWindFactor(input.headwindKts);

    // Apply surface correction (wet paved = +10%, dry grass = +45%)
    double surfaceFactor = input.surfaceType.correctionFactor;

    // Calculate ground roll (before safety margin)
    double groundRoll = baseGroundRoll * massFactor * windFactor * surfaceFactor;

    // Apply obstacle factor (fixed at 15m/50ft obstacle)
    double obstacleFactor = data.getLandingObstacleFactor(15.0); // Always 15m/50ft

    // Total distance over obstacle (before safety margin)
    double totalDistance = groundRoll * obstacleFactor;

    return LandingResult(
      groundRollM: groundRoll,
      totalDistanceM: totalDistance,
      baseGroundRollM: baseGroundRoll,
      massFactor: massFactor,
      windFactor: windFactor,
      surfaceFactor: surfaceFactor,
      obstacleFactor: obstacleFactor,
      safetyMargin: safetyMargin,
    );
  }

  /// C172P-specific: interpolate directly from landing tables.
  LandingResult _calculateC172p(
    LandingInput input,
    C172pTakeoffData data,
    double safetyMargin,
  ) {
    final massLbs = kgToLbs(input.massKg);

    // Direct table lookup with weight interpolation
    final grFt = data.getLandingGroundRollFt(
      input.oatC,
      input.pressureAltitudeFt,
      massLbs,
    );
    final tdFt = data.getLandingTotalDistanceFt(
      input.oatC,
      input.pressureAltitudeFt,
      massLbs,
    );

    // Wind correction
    final windFactor = data.getLandingWindFactor(input.headwindKts);

    // Surface correction
    final surfaceFactor = input.surfaceType.correctionFactor;

    final baseGroundRollM = ftToM(grFt);
    final groundRollM = baseGroundRollM * windFactor * surfaceFactor;

    final baseTotalDistanceM = ftToM(tdFt);
    final totalDistanceM = baseTotalDistanceM * windFactor * surfaceFactor;

    // Effective obstacle factor for display
    final obstacleFactor = baseGroundRollM > 0 ? baseTotalDistanceM / baseGroundRollM : 1.0;

    return LandingResult(
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
