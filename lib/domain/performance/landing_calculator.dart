// Landing performance calculator
// Based on typical GA aircraft POH data

import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/domain/models/landing_input.dart';
import 'package:flightstate/domain/models/landing_result.dart';

class LandingCalculator {
  final AircraftPerformanceData data;

  const LandingCalculator(this.data);

  LandingResult calculate(LandingInput input) {
    // Get base ground roll from data
    double baseGroundRoll = data.getBaseLandingGroundRoll(
      input.oatC,
      input.pressureAltitudeFt,
    );

    // Apply mass correction
    double massFactor = data.getMassFactor(input.massKg);

    // Apply wind correction
    double windFactor = data.getWindFactor(input.headwindKts);

    // Apply surface correction (wet = +10%)
    double surfaceFactor = input.isWetSurface ? 1.10 : 1.0;

    // Calculate ground roll
    double groundRoll = baseGroundRoll * massFactor * windFactor * surfaceFactor;

    // Apply obstacle factor (50ft / 15m obstacle)
    double obstacleFactor = data.getObstacleFactor(input.obstacleHeightM);

    // Total distance over obstacle
    double totalDistance = groundRoll * obstacleFactor;

    // Landing distance over 50ft obstacle (standard reference)
    double landingDistanceOver50ft = groundRoll * 1.42; // Typical 50ft factor

    return LandingResult(
      groundRollM: groundRoll,
      totalDistanceM: totalDistance,
      landingDistanceOver50ftM: landingDistanceOver50ft,
    );
  }
}
