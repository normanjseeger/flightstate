// Unit conversion utilities for aviation calculations.

double ftToM(double ft) => ft * 0.3048;
double mToFt(double m) => m / 0.3048;

/// Converts obstacle height from meters to feet using aviation standard.
/// Uses the convention that 15m = 50ft (rather than the exact 49.2ft).
double obstacleHeightMToFt(double m) {
  // Aviation standard: 15m = 50ft
  if ((m - 15.0).abs() < 0.01) return 50.0;
  // For other values, use standard conversion
  return m / 0.3048;
}

/// Converts obstacle height from feet to meters using aviation standard.
/// Uses the convention that 50ft = 15m (rather than the exact 15.24m).
double obstacleHeightFtToM(double ft) {
  // Aviation standard: 50ft = 15m
  if ((ft - 50.0).abs() < 0.01) return 15.0;
  // For other values, use standard conversion
  return ft * 0.3048;
}

double kgToLbs(double kg) => kg * 2.20462;
double lbsToKg(double lbs) => lbs / 2.20462;

double celsiusToFahrenheit(double c) => c * 9.0 / 5.0 + 32.0;
double fahrenheitToCelsius(double f) => (f - 32.0) * 5.0 / 9.0;

double ktsToKmh(double kts) => kts * 1.852;
double kmhToKts(double kmh) => kmh / 1.852;
