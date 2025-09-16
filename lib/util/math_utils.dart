import "dart:math";

T minAbs<T extends num>(T a, T b) => min(a.abs() as T, b.abs() as T);

T maxAbs<T extends num>(T a, T b) => max(a.abs() as T, b.abs() as T);

extension ClampNullable<T extends num> on T {
  T clampNullable(T? a, [T? b]) => clamp(a ?? -double.maxFinite, b ?? double.maxFinite) as T;
}
