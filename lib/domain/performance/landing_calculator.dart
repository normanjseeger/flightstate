// Landing performance calculator
// Based on typical GA aircraft POH data

import 'package:flightstate/core/math/unit_conversion.dart';
import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/data/aircraft/c172p/c172p_takeoff_data.dart';
import 'package:flightstate/data/aircraft/dv20/dv20_takeoff_data.dart';
import 'package:flightstate/data/aircraft/f172n/f172n_takeoff_data.dart';
import 'package:flightstate/domain/models/landing_input.dart';
import 'package:flightstate/domain/models/landing_result.dart';
import 'package:flightstate/domain/models/landing_surface_type.dart';

class LandingCalculator {
  final AircraftPerformanceData data;

  const LandingCalculator(this.data);

  LandingResult calculate(LandingInput input, {double safetyMargin = 1.0}) {
    // C172P has direct weight-interpolated landing tables — use them for accuracy
    if (data is C172pTakeoffData) {
      return _calculateC172p(input, data as C172pTakeoffData, safetyMargin);
    }

    // DV20 has limited AFM data — use exact values at baseline, approximations elsewhere
    if (data is Dv20TakeoffData) {
      return _calculateDv20(input, data as Dv20TakeoffData, safetyMargin);
    }

    // F172N has direct weight-interpolated landing tables
    if (data is F172nTakeoffData) {
      return _calculateF172n(input, data as F172nTakeoffData, safetyMargin);
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

  /// DV20-specific: Return exact AFM values at baseline, use approximations elsewhere.
  ///
  /// AFM Section 5.3.12 provides ONE data point:
  /// - Conditions: MSL (0 ft), 15°C (ISA), 730 kg, 0 kts wind, paved
  /// - Ground roll: 228 m
  /// - Over 50 ft: 454 m
  ///
  /// When user sets EXACT AFM conditions, return EXACT AFM values.
  /// Otherwise, use conservative approximations.
  LandingResult _calculateDv20(
    LandingInput input,
    Dv20TakeoffData data,
    double safetyMargin,
  ) {
    // Check if we're at the exact AFM baseline conditions
    final isAfmBaseline = (input.oatC - 15.0).abs() < 0.5 && // 15°C ± 0.5
        (input.pressureAltitudeFt - 0.0).abs() < 50 && // MSL ± 50 ft
        (input.massKg - 730.0).abs() < 2 && // 730 kg ± 2 kg
        (input.headwindKts - 0.0).abs() < 0.5 && // 0 kts ± 0.5
        input.surfaceType == LandingSurfaceType.dryPaved; // Paved

    if (isAfmBaseline) {
      // Return EXACT AFM values for user confidence
      const afmGroundRollM = 228.0; // Exact from AFM
      const afmTotalDistanceM = 454.0; // Exact from AFM
      const afmObstacleFactor = afmTotalDistanceM / afmGroundRollM; // 1.991

      return LandingResult(
        groundRollM: afmGroundRollM,
        totalDistanceM: afmTotalDistanceM,
        baseGroundRollM: afmGroundRollM,
        massFactor: 1.0,
        windFactor: 1.0,
        surfaceFactor: 1.0,
        obstacleFactor: afmObstacleFactor,
        safetyMargin: safetyMargin,
      );
    }

    // Not at baseline — use generic approximation with conservative factors
    return _calculateGeneric(input, safetyMargin);
  }

  /// F172N-specific: interpolate directly from landing tables.
  LandingResult _calculateF172n(
    LandingInput input,
    F172nTakeoffData data,
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
