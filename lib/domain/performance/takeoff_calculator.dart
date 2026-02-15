import 'package:flightstate/data/aircraft/dv20/dv20_takeoff_data.dart';
import 'package:flightstate/domain/models/takeoff_input.dart';
import 'package:flightstate/domain/models/takeoff_result.dart';

class TakeoffCalculator {
  /// Calculates takeoff distances using the 4-panel nomogram method.
  ///
  /// Panel 1: OAT + Pressure Altitude → base ground roll (at max weight)
  /// Panel 2: Apply mass correction factor
  /// Panel 3: Apply headwind/tailwind correction factor
  /// Panel 4: Calculate total distance over obstacle
  /// Finally: Apply surface type correction
  static TakeoffResult calculate(TakeoffInput input) {
    // Panel 1: Base ground roll at max weight
    final baseRoll = Dv20TakeoffData.getBaseGroundRoll(
      input.oat,
      input.pressureAltitude,
    );

    // Panel 2: Mass correction
    final massFactor = Dv20TakeoffData.getMassFactor(input.mass);
    final massAdjusted = baseRoll * massFactor;

    // Panel 3: Wind correction
    final windFactor = Dv20TakeoffData.getWindFactor(input.headwind);
    final windAdjusted = massAdjusted * windFactor;

    // Surface correction (applied to ground roll)
    final groundRoll = windAdjusted * input.surfaceType.correctionFactor;

    // Panel 4: Obstacle clearance
    final obstacleFactor = Dv20TakeoffData.getObstacleFactor(
      input.obstacleHeight,
    );
    final totalDistance = groundRoll * obstacleFactor;

    return TakeoffResult(
      groundRollM: groundRoll,
      totalDistanceM: totalDistance,
    );
  }
}
