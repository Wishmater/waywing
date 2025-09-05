import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/modules/kb_layout/kb_layout_service.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";

class CapsLockFeather extends Feather {
  late KeyboardLayoutService service;

  CapsLockFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "CapsLock",
      FeatherRegistration(
        constructor: CapsLockFeather._,
      ),
    );
  }

  @override
  String get name => "CapsLock";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<KeyboardLayoutService>(this);
  }

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([
    FeatherComponent(
      isIndicatorVisible: service.capsLockActive,
      buildIndicators: (context, popover) {
        return [
          ErrorStateIndicator(
            name: "caps lock",
            value: "ON",
          ),
        ];
      },
    ),
  ]);
}

// TODO: 1 move this to a separate file??
class ErrorStateIndicator extends StatefulWidget {
  final String name;
  final String value;

  const ErrorStateIndicator({
    required this.name,
    required this.value,
    super.key,
  });

  @override
  State<ErrorStateIndicator> createState() => _ErrorStateIndicatorState();
}

class _ErrorStateIndicatorState extends State<ErrorStateIndicator> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onErrorContainer;
    final shadowColor = theme.colorScheme.onError;
    return SplashPulse(
      color: theme.colorScheme.error.withValues(alpha: 0.5),
      child: WingedButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                widget.name,
                style: theme.textTheme.labelSmall!.copyWith(
                  height: 1,
                  color: textColor,
                  shadows: [
                    Shadow(offset: Offset(1, 1), color: shadowColor),
                    Shadow(offset: Offset(-1, -1), color: shadowColor),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 2),
            Text(
              widget.value,
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1,
                shadows: [
                  Shadow(offset: Offset(1, 1), color: shadowColor),
                  Shadow(offset: Offset(-1, -1), color: shadowColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: 1 move this to a separate file
class SplashPulse extends StatefulWidget {
  final Duration interval;
  final Color? color;
  final bool pulseInitially;
  final bool pulsing;
  final Widget child;

  const SplashPulse({
    this.interval = const Duration(milliseconds: 1000),
    this.color, // defaults to theme splashColor
    this.pulseInitially = true,
    this.pulsing = true,
    required this.child,
    super.key,
  });

  @override
  State<SplashPulse> createState() => _SplashPulseState();
}

class _SplashPulseState extends State<SplashPulse> {
  late final List<InteractiveInkFeature> _splashes = [];
  late Timer splashTimer;

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
        splashTimer.cancel();
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
    splashTimer.cancel();
    for (var splash in List.from(_splashes)) {
      splash.dispose();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
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
