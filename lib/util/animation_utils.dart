import "package:flutter/widgets.dart";
import "package:motor/motor.dart";

enum AnimationFitting { clip, stretch }

enum AnimationSwitching { fadeThrough, slide }

class MultipliedAnimation extends Animation<double> {
  final Animation<double> first;
  final Animation<double> second;

  MultipliedAnimation(this.first, this.second);

  @override
  double get value => first.value * second.value;

  @override
  AnimationStatus get status => first.status == second.status ? first.status : AnimationStatus.forward;

  @override
  void addListener(VoidCallback listener) {
    first.addListener(listener);
    second.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    first.removeListener(listener);
    second.removeListener(listener);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    first.addStatusListener(listener);
    second.addStatusListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    first.removeStatusListener(listener);
    second.removeStatusListener(listener);
  }
}

extension MaterialSpringMotionMultiply on MaterialSpringMotion {
  MaterialSpringMotion multiply({
    double stiffness = 1,
    double damping = 1,
  }) {
    return copyWith(
      stiffness: this.stiffness * stiffness,
      damping: this.damping * damping,
    );
  }
}

class MaterialSpringMotionValues {
  final MaterialSpringMotionExpressionValues expressive;
  final MaterialSpringMotionExpressionValues standard;

  MaterialSpringMotionValues({
    double stiffness = 1,
    double damping = 1,
  }) : standard = MaterialSpringMotionExpressionValues(
         spatial: MaterialSpringMotionSpeedValues(
           fast: MaterialSpringMotion.standardSpatialFast(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           normal: MaterialSpringMotion.standardSpatialDefault(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           slow: MaterialSpringMotion.standardSpatialSlow(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
         ),
         effects: MaterialSpringMotionSpeedValues(
           fast: MaterialSpringMotion.standardEffectsFast(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           normal: MaterialSpringMotion.standardEffectsDefault(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           slow: MaterialSpringMotion.standardEffectsSlow(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
         ),
       ),
       expressive = MaterialSpringMotionExpressionValues(
         spatial: MaterialSpringMotionSpeedValues(
           fast: MaterialSpringMotion.expressiveSpatialFast(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           normal: MaterialSpringMotion.expressiveSpatialDefault(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           slow: MaterialSpringMotion.expressiveSpatialSlow(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
         ),
         effects: MaterialSpringMotionSpeedValues(
           fast: MaterialSpringMotion.expressiveEffectsFast(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           normal: MaterialSpringMotion.expressiveEffectsDefault(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           slow: MaterialSpringMotion.expressiveEffectsSlow(snapToEnd: true).multiply(
             stiffness: stiffness,
             damping: damping,
           ),
         ),
       );
}

class MaterialSpringMotionExpressionValues {
  final MaterialSpringMotionSpeedValues spatial;
  final MaterialSpringMotionSpeedValues effects;

  MaterialSpringMotionExpressionValues({
    required this.spatial,
    required this.effects,
  });
}

class MaterialSpringMotionSpeedValues {
  final MaterialSpringMotion fast;
  final MaterialSpringMotion normal; // it cant be named default :)))))
  final MaterialSpringMotion slow;

  MaterialSpringMotionSpeedValues({
    required this.fast,
    required this.normal,
    required this.slow,
  });
}
