import 'package:flightstate/core/models/aircraft_type.dart';
import 'package:flightstate/data/aircraft/aircraft_performance_data.dart';
import 'package:flightstate/data/aircraft/c172p/c172p_takeoff_data.dart';
import 'package:flightstate/data/aircraft/dv20/dv20_takeoff_data.dart';

class AircraftRegistry {
  static const List<AircraftType> supportedAircraft = AircraftType.values;

  static const Map<AircraftType, AircraftPerformanceData> _data = {
    AircraftType.dv20: Dv20TakeoffData(),
    AircraftType.c172p: C172pTakeoffData(),
  };

  static AircraftPerformanceData getPerformanceData(AircraftType type) {
    return _data[type]!;
  }
}
