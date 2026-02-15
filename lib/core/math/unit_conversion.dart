// Unit conversion utilities for aviation calculations.

double ftToM(double ft) => ft * 0.3048;
double mToFt(double m) => m / 0.3048;

double kgToLbs(double kg) => kg * 2.20462;
double lbsToKg(double lbs) => lbs / 2.20462;

double celsiusToFahrenheit(double c) => c * 9.0 / 5.0 + 32.0;
double fahrenheitToCelsius(double f) => (f - 32.0) * 5.0 / 9.0;

double ktsToKmh(double kts) => kts * 1.852;
double kmhToKts(double kmh) => kmh / 1.852;
