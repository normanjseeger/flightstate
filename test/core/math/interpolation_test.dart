import 'package:flutter_test/flutter_test.dart';
import 'package:flightstate/core/math/interpolation.dart';

void main() {
  group('linearInterpolate', () {
    final xs = [0.0, 10.0, 20.0, 30.0];
    final ys = [100.0, 200.0, 400.0, 500.0];

    test('exact breakpoints', () {
      expect(linearInterpolate(0, xs, ys), 100.0);
      expect(linearInterpolate(10, xs, ys), 200.0);
      expect(linearInterpolate(20, xs, ys), 400.0);
      expect(linearInterpolate(30, xs, ys), 500.0);
    });

    test('between breakpoints', () {
      expect(linearInterpolate(5, xs, ys), 150.0);
      expect(linearInterpolate(15, xs, ys), 300.0);
      expect(linearInterpolate(25, xs, ys), 450.0);
    });

    test('clamps below range', () {
      expect(linearInterpolate(-10, xs, ys), 100.0);
    });

    test('clamps above range', () {
      expect(linearInterpolate(40, xs, ys), 500.0);
    });

    test('at 25%', () {
      // Between 0→10: 100→200 at x=2.5
      expect(linearInterpolate(2.5, xs, ys), 125.0);
    });
  });

  group('bilinearInterpolate', () {
    final xs = [0.0, 10.0];
    final ys = [0.0, 10.0];
    final values = [
      [100.0, 200.0], // x=0: y=0→100, y=10→200
      [300.0, 400.0], // x=10: y=0→300, y=10→400
    ];

    test('corners', () {
      expect(bilinearInterpolate(0, 0, xs, ys, values), 100.0);
      expect(bilinearInterpolate(10, 0, xs, ys, values), 300.0);
      expect(bilinearInterpolate(0, 10, xs, ys, values), 200.0);
      expect(bilinearInterpolate(10, 10, xs, ys, values), 400.0);
    });

    test('center', () {
      expect(bilinearInterpolate(5, 5, xs, ys, values), 250.0);
    });

    test('edge midpoints', () {
      expect(bilinearInterpolate(5, 0, xs, ys, values), 200.0);
      expect(bilinearInterpolate(0, 5, xs, ys, values), 150.0);
    });

    test('clamping', () {
      expect(bilinearInterpolate(-5, -5, xs, ys, values), 100.0);
      expect(bilinearInterpolate(15, 15, xs, ys, values), 400.0);
    });
  });
}
