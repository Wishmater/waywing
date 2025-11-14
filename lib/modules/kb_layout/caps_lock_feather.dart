import "dart:async";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/services/compositors/compositor.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/motion_widgets/motion_opacity.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";

part "caps_lock_feather.config.dart";

class CapsLockFeather extends Feather<CapsLockConfig> {
  late CompositorService service;

  CapsLockFeather._();

  static void registerFeather(RegisterFeatherCallback<CapsLockFeather, CapsLockConfig> registerFeather) {
    registerFeather(
      "CapsLock",
      FeatherRegistration(
        constructor: CapsLockFeather._,
        configBuilder: CapsLockConfig.fromBlock,
        schemaBuilder: () => CapsLockConfig.schema,
      ),
    );
  }

  @override
  String get name => "CapsLock";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<CompositorService>(this);
    if (service.supportCapslock) throw Exception("Capslock not supported by ${service.runtimeType}");
  }

  late final isIndicatorEnabled = DerivedValueNotifier(
    dependencies: [service.isCapslockActive],
    derive: () => config.reserveSpace ? true : service.isCapslockActive.value,
  );
  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([
    FeatherComponent(
      isIndicatorEnabled: isIndicatorEnabled,
      buildIndicators: (context, popover) {
        return [
          ValueListenableBuilder(
            valueListenable: service.isCapslockActive,
            builder: (context, capsLockActive, child) {
              return ErrorStateIndicator(
                name: "caps lock",
                value: "ON",
                visible: !config.reserveSpace ? true : capsLockActive,
              );
            },
          ),
        ];
      },
    ),
  ]);

  @override
  void onConfigUpdated(CapsLockConfig oldConfig) {
    if (oldConfig.reserveSpace != config.reserveSpace) {
      isIndicatorEnabled.value = isIndicatorEnabled.derive();
    }
  }
}

@Config()
mixin CapsLockConfigBase on CapsLockConfigI {
  static const _reserveSpace = BooleanField(defaultTo: false);
}

// TODO: 1 move this to a separate file??
class ErrorStateIndicator extends StatefulWidget {
  final String name;
  final String value;
  final bool visible;

  /// for visibility, defautls to standard.effects.normal
  final Motion? motion;

  const ErrorStateIndicator({
    required this.name,
    required this.value,
    this.visible = true,
    this.motion,
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
    Widget result = WingedButton(
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
    );
    if (widget.visible) {
      result = SplashPulse(
        color: theme.colorScheme.error.withValues(alpha: 0.5),
        child: result,
      );
    } else {
      result = ExcludeFocusTraversal(
        child: IgnorePointer(
          child: result,
        ),
      );
    }
    return MotionOpacity(
      opacity: widget.visible ? 1 : 0,
      motion: widget.motion ?? mainConfig.motions.standard.effects.normal,
      child: result,
    );
  }
}

// TODO: 1 move this to a separate file
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
