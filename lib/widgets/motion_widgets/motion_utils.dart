import "package:flutter/widgets.dart";

AnimationStatus consolidateAnimationStatus(List<AnimationStatus?> statuses) {
  AnimationStatus? result;
  for (final e in statuses) {
    if (e == null) continue;
    if (result == null || e.priority > result.priority) {
      result = e;
    }
  }
  assert(
    result != null,
    "No animation status passed to consolidateAnimationStatus (or all null). This should never happen,",
  );
  return result!;
}

extension AnimationStatusPriorities on AnimationStatus {
  int get priority => switch (this) {
    AnimationStatus.dismissed => 1,
    AnimationStatus.completed => 2,
    AnimationStatus.reverse => 3,
    AnimationStatus.forward => 4,
  };
}

extension Pipe<T extends Object> on T {
  T pipe(Function(T) function) {
    function(this);
    return this;
  }
}
