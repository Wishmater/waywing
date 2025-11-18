import "dart:math";

import "package:flutter/material.dart";
import "package:upower/upower.dart";
import "package:waywing/modules/battery/battery_config.dart";
import "package:waywing/modules/battery/interfaces/battery_service_interfaces.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/splash_pulse.dart";

class BatteryIndicator extends StatelessWidget {
  final BatteryValues battery;
  final BatteryConfig config;
  final ValueNotifier<bool> pulse;

  const BatteryIndicator({super.key, required this.battery, required this.config, required this.pulse});

  @override
  Widget build(BuildContext context) {
    if (!battery.isPresent.value) {
      return SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constrains) {
        final width = 35.0.clamp(constrains.minWidth, constrains.maxWidth);
        final height = (15.0 * width / 35).clamp(constrains.minHeight, constrains.maxHeight);
        return ValueListenableBuilder(
          valueListenable: DerivedValueNotifier(
            dependencies: [battery.energy, battery.energyFull, battery.state, pulse],
            derive: () => (battery.energy.value / battery.energyFull.value) * 100,
          ),
          builder: (context, energy, _) {
            final theme = Theme.of(context);
            return SplashPulse(
              color: theme.colorScheme.error.withValues(alpha: 0.5),
              pulsing: pulse.value,
              child: _BatteryIndicator(
                size: Size(width, height),
                batteryLevel: energy,
                lightningColor: config.lightningColor,
                isCharging:
                    battery.state.value == UPowerDeviceState.charging ||
                    battery.state.value == UPowerDeviceState.fullyCharged,
              ),
            );
          },
        );
      },
    );
  }
}

class _BatteryIndicator extends StatelessWidget {
  final double batteryLevel; // Value from 0 to 100
  final bool isCharging;
  final Color lightningColor;
  final Size size;

  const _BatteryIndicator({
    required this.batteryLevel,
    required this.isCharging,
    required this.lightningColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color fillColor;
    if (isCharging) {
      fillColor = theme.dividerTheme.color ?? theme.dividerColor;
    } else if (batteryLevel > 50) {
      fillColor = theme.dividerTheme.color ?? theme.dividerColor;
    } else if (batteryLevel > 20) {
      fillColor = theme.colorScheme.error.withAlpha((theme.colorScheme.error.a * 255).round());
    } else {
      fillColor = theme.colorScheme.error;
    }
    final textColor =
        theme.textTheme.bodyMedium!.color ?? (theme.brightness == Brightness.dark ? Colors.white : Colors.black);
    return CustomPaint(
      size: size,
      painter: _BatteryPainter(
        batteryLevel: batteryLevel,
        fillColor: fillColor,
        outlineColor: textColor,
        lightningColor: lightningColor,
        textStyle: theme.textTheme.bodyMedium!.copyWith(color: textColor),
        isCharging: isCharging,
      ),
    );
  }
}

class _BatteryPainter extends CustomPainter {
  final double batteryLevel;
  final Color fillColor;
  final Color outlineColor;
  final Color lightningColor;
  final TextStyle textStyle;
  final bool isCharging;

  const _BatteryPainter({
    required this.outlineColor,
    required this.batteryLevel,
    required this.fillColor,
    required this.lightningColor,
    required this.textStyle,
    required this.isCharging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final Paint tipPaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.fill;

    final Paint fillPaint = Paint()..style = PaintingStyle.fill;

    fillPaint.color = fillColor;

    // Draw battery body
    final double bodyWidth = size.width * 0.7;
    final double bodyHeight = min(size.height, bodyWidth * 0.5);
    final double bodyCornerRadius = bodyHeight * 0.2;
    final double topPosition = (size.height - bodyHeight) / 2;

    final Rect bodyRect = Rect.fromLTWH(0, topPosition, bodyWidth, bodyHeight);
    final RRect bodyRRect = RRect.fromRectAndRadius(bodyRect, Radius.circular(bodyCornerRadius));

    // Draw battery tip
    final double tipWidth = size.width * 0.1;
    final double tipHeight = bodyHeight * 0.4;
    final Rect tipRect = Rect.fromLTWH(bodyWidth, topPosition + (bodyHeight - tipHeight) / 2, tipWidth, tipHeight);
    final RRect tipRRect = RRect.fromRectAndRadius(tipRect, Radius.circular(2));

    // Draw battery fill
    final double fillPadding = size.height * 0.1;
    final double fillWidth = (bodyWidth - fillPadding * 2) * (batteryLevel / 100).clamp(0.0, 1.0);
    final double fillHeight = bodyHeight - fillPadding * 2;
    final Rect fillRect = Rect.fromLTWH(fillPadding, topPosition + fillPadding, fillWidth, fillHeight);
    final RRect fillRRect = RRect.fromRectAndRadius(fillRect, Radius.circular(bodyCornerRadius * 0.7));

    // Draw the battery
    canvas.drawRRect(bodyRRect, outlinePaint);
    canvas.drawRRect(tipRRect, tipPaint);
    canvas.drawRRect(fillRRect, fillPaint);

    final TextSpan span = TextSpan(
      text: "${batteryLevel.floor()}",
      style: textStyle.copyWith(fontSize: min(textStyle.fontSize ?? double.infinity, bodyHeight * 0.75)),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(0, topPosition) + Offset((bodyWidth - tp.width) / 2, (bodyHeight - tp.height) / 2));

    final fontSizeLightning = min(textStyle.fontSize ?? double.infinity, bodyHeight * 0.7);
    final TextSpan spanLightning = TextSpan(
      text: "🗲",
      style: textStyle.copyWith(
        fontSize: fontSizeLightning,
        color: lightningColor,
      ),
    );
    if (isCharging) {
      final TextPainter tpLightning = TextPainter(
        text: spanLightning,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tpLightning.layout();
      tpLightning.paint(
        canvas,
        Offset(
          size.width * 0.9,
          topPosition + (bodyHeight - fontSizeLightning) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BatteryPainter oldDelegate) {
    return batteryLevel != oldDelegate.batteryLevel ||
        outlineColor != oldDelegate.outlineColor ||
        fillColor != oldDelegate.fillColor ||
        textStyle != oldDelegate.textStyle ||
        isCharging != oldDelegate.isCharging;
  }
}
