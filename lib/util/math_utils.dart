T minAbs<T extends num>(T a, T b) {
  if (a.abs() < b.abs()) {
    return a;
  } else {
    return b;
  }
}

T maxAbs<T extends num>(T a, T b) {
  if (a.abs() > b.abs()) {
    return a;
  } else {
    return b;
  }
}

extension ClampNullable<T extends num> on T {
  T clampNullable(T? a, [T? b]) {
    if (a != null && a > this) {
      return a;
    }
    if (b != null && b < this) {
      return b;
    }
    return this;
  }
}
