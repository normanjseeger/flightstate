// Linear and bilinear interpolation utilities with clamping.

/// Linearly interpolates a value [x] within [xs] → [ys].
///
/// If [x] is outside the range of [xs], it is clamped to the nearest endpoint.
/// [xs] must be sorted in ascending order and have the same length as [ys].
double linearInterpolate(double x, List<double> xs, List<double> ys) {
  assert(xs.length == ys.length);
  assert(xs.length >= 2);

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
double bilinearInterpolate(
  double x,
  double y,
  List<double> xs,
  List<double> ys,
  List<List<double>> values,
) {
  assert(values.length == xs.length);
  assert(values.every((row) => row.length == ys.length));

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
