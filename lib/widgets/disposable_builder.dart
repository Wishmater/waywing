import "package:flutter/material.dart";

abstract class DisposableListener extends Listenable {
  bool get isDisposed;
}

class DisposableAnimatedBuilder extends StatelessWidget {
  final DisposableListener animation;
  final TransitionBuilder builder;
  final Widget? child;

  const DisposableAnimatedBuilder({
    required this.animation,
    required this.builder,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation.isDisposed ? const _DummyListenable() : animation,
      builder: builder,
      child: child,
    );
  }
}

class _DummyListenable extends Listenable {
  const _DummyListenable();
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
}
