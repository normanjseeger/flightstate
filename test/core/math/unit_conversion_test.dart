import 'package:flutter_test/flutter_test.dart';
import 'package:flightstate/core/math/unit_conversion.dart';

void main() {
  group('ft ↔ m', () {
    test('ftToM', () {
      expect(ftToM(1000), closeTo(304.8, 0.1));
      expect(ftToM(0), 0.0);
    });
    test('mToFt', () {
      expect(mToFt(304.8), closeTo(1000, 0.1));
    });
    test('roundtrip', () {
      expect(mToFt(ftToM(5000)), closeTo(5000, 0.01));
    });
  });

  group('kg ↔ lbs', () {
    test('kgToLbs', () {
      expect(kgToLbs(675), closeTo(1488.1, 0.5));
    });
    test('lbsToKg', () {
      expect(lbsToKg(1488), closeTo(675, 0.5));
    });
  });

  group('°C ↔ °F', () {
    test('celsiusToFahrenheit', () {
      expect(celsiusToFahrenheit(0), 32.0);
      expect(celsiusToFahrenheit(15), closeTo(59, 0.1));
      expect(celsiusToFahrenheit(-20), closeTo(-4, 0.1));
    });
    test('fahrenheitToCelsius', () {
      expect(fahrenheitToCelsius(59), closeTo(15, 0.1));
    });
  });

  group('kts ↔ km/h', () {
    test('ktsToKmh', () {
      expect(ktsToKmh(57), closeTo(105.6, 0.1));
    });
    test('kmhToKts', () {
      expect(kmhToKts(105), closeTo(56.7, 0.1));
    });
  });
}
