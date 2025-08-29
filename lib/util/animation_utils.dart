import "package:motor/motor.dart";

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
           fast: MaterialSpringMotion.standardSpatialFast.multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           normal: MaterialSpringMotion.standardSpatialDefault.multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           slow: MaterialSpringMotion.standardSpatialSlow.multiply(
             stiffness: stiffness,
             damping: damping,
           ),
         ),
         effects: MaterialSpringMotionSpeedValues(
           fast: MaterialSpringMotion.standardEffectsFast.multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           normal: MaterialSpringMotion.standardEffectsDefault.multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           slow: MaterialSpringMotion.standardEffectsSlow.multiply(
             stiffness: stiffness,
             damping: damping,
           ),
         ),
       ),
       expressive = MaterialSpringMotionExpressionValues(
         spatial: MaterialSpringMotionSpeedValues(
           fast: MaterialSpringMotion.expressiveSpatialFast.multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           normal: MaterialSpringMotion.expressiveSpatialDefault.multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           slow: MaterialSpringMotion.expressiveSpatialSlow.multiply(
             stiffness: stiffness,
             damping: damping,
           ),
         ),
         effects: MaterialSpringMotionSpeedValues(
           fast: MaterialSpringMotion.expressiveEffectsFast.multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           normal: MaterialSpringMotion.expressiveEffectsDefault.multiply(
             stiffness: stiffness,
             damping: damping,
           ),
           slow: MaterialSpringMotion.expressiveEffectsSlow.multiply(
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
