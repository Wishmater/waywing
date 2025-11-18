import "dart:async";

import "package:flutter/material.dart";
import "package:waywing/core/config.dart";

class SplashPulse extends StatefulWidget {
  final Duration interval;
  final Color? color;
  final bool pulseInitially;
  late final bool pulsing;
  final Widget child;

  SplashPulse({
    this.interval = const Duration(milliseconds: 1000),
    this.color, // defaults to theme splashColor
    this.pulseInitially = true,
    bool pulsing = true,
    required this.child,
    super.key,
  }) : pulsing = !mainConfig.animationEnable ? false : pulsing;

  @override
  State<SplashPulse> createState() => _SplashPulseState();
}

class _SplashPulseState extends State<SplashPulse> {
  late final List<InteractiveInkFeature> _splashes = [];
  Timer? splashTimer;

  @override
  void initState() {
    super.initState();
    if (widget.pulsing) {
      _init();
    }
  }

  @override
  void didUpdateWidget(covariant SplashPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulsing != widget.pulsing) {
      if (widget.pulsing) {
        _init();
      } else {
        splashTimer?.cancel();
        for (final splash in _splashes) {
          splash.cancel();
        }
      }
    }
    // TODO: 3 update the rest of the arguments if they change: color, interval
  }

  void _init() {
    if (widget.pulseInitially) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startNewSplash();
        _initTimer();
      });
    } else {
      _initTimer();
    }
  }

  void _initTimer() {
    // TODO: 2 synchronize pulses across all active widgets (what if they have different duration?)
    splashTimer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      _startNewSplash();
    });
  }

  @override
  void deactivate() {
    _disposeSplashes();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    if (widget.pulsing) {
      _initTimer();
    }
  }

  @override
  void dispose() {
    _disposeSplashes();
    super.dispose();
  }

  void _disposeSplashes() {
    splashTimer?.cancel();
    for (var splash in List<InteractiveInkFeature>.from(_splashes)) {
      splash.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _startNewSplash() {
    // mostly copied from InkResponse code
    InkResponse;
    final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
    final globalPosition = referenceBox.localToGlobal(referenceBox.paintBounds.center);

    final MaterialInkController inkController = Material.of(context);
    final Offset position = referenceBox.globalToLocal(globalPosition);
    final Color color = widget.color ?? Theme.of(context).splashColor;
    final radius = referenceBox.size.longestSide * 0.5;

    InteractiveInkFeature? splash;
    splash = Theme.of(context).splashFactory.create(
      textDirection: Directionality.of(context),
      controller: inkController,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: false,
      radius: radius,
      onRemoved: () {
        _splashes.remove(splash);
      },
    );
    _splashes.add(splash);
  }
}
