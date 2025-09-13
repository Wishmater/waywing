import "package:flutter/widgets.dart";
import "package:motor/motor.dart";
// ignore: implementation_imports
import 'package:motor/src/simulations/no_motion_simulation.dart';

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

class MaterialSpringMotionValues {
  final MaterialSpringMotionExpressionValues expressive;
  final MaterialSpringMotionExpressionValues standard;

  MaterialSpringMotionValues({
    bool enableAnimations = true,
    double stiffness = 1,
    double damping = 1,
  }) : standard = MaterialSpringMotionExpressionValues(
         spatial: MaterialSpringMotionSpeedValues(
           fast: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.standardSpatialFast(snapToEnd: true).multiply(
                   stiffness: stiffness,
                   damping: damping,
                 ),
           normal: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.standardSpatialDefault(snapToEnd: true).multiply(
                   stiffness: stiffness,
                   damping: damping,
                 ),
           slow: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.standardSpatialSlow(snapToEnd: true).multiply(
                   stiffness: stiffness,
                   damping: damping,
                 ),
         ),
         effects: MaterialSpringMotionSpeedValues(
           fast: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.standardEffectsFast(snapToEnd: true).multiply(
                   stiffness: stiffness,
                   damping: damping,
                 ),
           normal: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.standardEffectsDefault(snapToEnd: true).multiply(
                   stiffness: stiffness,
                   damping: damping,
                 ),
           slow: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.standardEffectsSlow(snapToEnd: true).multiply(
                   stiffness: stiffness,
                   damping: damping,
                 ),
         ),
       ),
       expressive = MaterialSpringMotionExpressionValues(
         spatial: MaterialSpringMotionSpeedValues(
           fast: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.expressiveSpatialFast(snapToEnd: true).multiply(
                   stiffness: stiffness,
                   damping: damping,
                 ),
           normal: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.expressiveSpatialDefault(snapToEnd: true).multiply(
                   stiffness: stiffness,
                   damping: damping,
                 ),
           slow: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.expressiveSpatialSlow(snapToEnd: true).multiply(
                   stiffness: stiffness,
                   damping: damping,
                 ),
         ),
         effects: MaterialSpringMotionSpeedValues(
           fast: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.expressiveEffectsFast(snapToEnd: true).multiply(
                   stiffness: stiffness,
                   damping: damping,
                 ),
           normal: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.expressiveEffectsDefault(snapToEnd: true).multiply(
                   stiffness: stiffness,
                   damping: damping,
                 ),
           slow: !enableAnimations
               ? InstantMotion()
               : MaterialSpringMotion.expressiveEffectsSlow(snapToEnd: true).multiply(
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
  final Motion fast;
  final Motion normal; // it cant be named default :)))))
  final Motion slow;

  MaterialSpringMotionSpeedValues({
    required this.fast,
    required this.normal,
    required this.slow,
  });
}

extension MotionMultiplyable on Motion {
  Motion multiplySpeed([double speed = 1]) {
    return switch (this) {
      MaterialSpringMotion motion => motion.multiply(stiffness: speed),
      InstantMotion motion => motion,
      _ => throw UnimplementedError("multiplySpeed not implemented for Motion implementation class: $runtimeType"),
    };
  }
}

extension MaterialSpringMotionMultiplyable on MaterialSpringMotion {
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

class InstantMotion extends NoMotion {
  const InstantMotion([super.duration = Duration.zero]);

  @override
  String toString() => "InstantMotion($duration)";

  @override
  Simulation createSimulation({
    double start = 0,
    double end = 1,
    double velocity = 0,
  }) {
    return NoMotionSimulation(
      duration: duration,
      value: end,
      tolerance: tolerance,
    );
  }
}
