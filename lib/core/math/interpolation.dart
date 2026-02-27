// Linear and bilinear interpolation utilities with clamping.

/// Snaps a value to the nearest breakpoint if within tolerance.
/// Returns the snapped value or the original value if not close enough.
double _snapToBreakpoint(double value, List<double> breakpoints, double tolerance) {
  for (final bp in breakpoints) {
    if ((value - bp).abs() <= tolerance) {
      return bp;
    }
  }
  return value;
}

/// Linearly interpolates a value [x] within [xs] → [ys].
///
/// If [x] is outside the range of [xs], it is clamped to the nearest endpoint.
/// [xs] must be sorted in ascending order and have the same length as [ys].
/// Snaps to exact breakpoints when very close to return exact table values.
/// [tolerance] defaults to 0.1 for most values (temp, wind, obstacle height).
double linearInterpolate(double x, List<double> xs, List<double> ys, {double tolerance = 0.1}) {
  assert(xs.length == ys.length);
  assert(xs.length >= 2);

  // Snap to exact breakpoints if very close
  x = _snapToBreakpoint(x, xs, tolerance);

  // Clamp to range
  if (x <= xs.first) return ys.first;
  if (x >= xs.last) return ys.last;

  // Find the bracketing interval
  for (int i = 0; i < xs.length - 1; i++) {
    if (x >= xs[i] && x <= xs[i + 1]) {
      final t = (x - xs[i]) / (xs[i + 1] - xs[i]);
      return ys[i] + t * (ys[i + 1] - ys[i]);
    }
  }

  // Should never reach here
  return ys.last;
}

/// Bilinear interpolation over a 2D grid.
///
/// [x] and [y] are the query coordinates.
/// [xs] and [ys] are the grid breakpoints (sorted ascending).
/// [values] is a 2D array where values[i][j] corresponds to xs[i], ys[j].
///
/// Snaps to exact breakpoints when within tolerance to avoid interpolation
/// errors when values are very close to table values.
/// [xTolerance] defaults to 0.1 (for temperature), [yTolerance] defaults to 10.0 (for altitude).
double bilinearInterpolate(
  double x,
  double y,
  List<double> xs,
  List<double> ys,
  List<List<double>> values, {
  double xTolerance = 0.1,
  double yTolerance = 10.0,
}) {
  assert(values.length == xs.length);
  assert(values.every((row) => row.length == ys.length));

  // Snap to exact breakpoints if very close
  x = _snapToBreakpoint(x, xs, xTolerance);
  y = _snapToBreakpoint(y, ys, yTolerance);

  // Clamp x and y
  x = x.clamp(xs.first, xs.last);
  y = y.clamp(ys.first, ys.last);

  // Find x interval
  int xi = 0;
  for (int i = 0; i < xs.length - 1; i++) {
    if (x >= xs[i] && x <= xs[i + 1]) {
      xi = i;
      break;
    }
  }

  // Find y interval
  int yi = 0;
  for (int i = 0; i < ys.length - 1; i++) {
    if (y >= ys[i] && y <= ys[i + 1]) {
      yi = i;
      break;
    }
  }

  // Interpolation fractions
  final tx = (xs[xi + 1] == xs[xi])
      ? 0.0
      : (x - xs[xi]) / (xs[xi + 1] - xs[xi]);
  final ty = (ys[yi + 1] == ys[yi])
      ? 0.0
      : (y - ys[yi]) / (ys[yi + 1] - ys[yi]);

  // Four corners
  final c00 = values[xi][yi];
  final c10 = values[xi + 1][yi];
  final c01 = values[xi][yi + 1];
  final c11 = values[xi + 1][yi + 1];

  // Bilinear formula
  return c00 * (1 - tx) * (1 - ty) +
      c10 * tx * (1 - ty) +
      c01 * (1 - tx) * ty +
      c11 * tx * ty;
}
