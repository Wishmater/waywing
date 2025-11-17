import "dart:math";

import "package:flutter/material.dart";
import "package:upower/upower.dart";
import "package:waywing/modules/battery/battery_config.dart";
import "package:waywing/modules/battery/battery_service.dart";
import "package:waywing/util/derived_value_notifier.dart";

class BatteryIndicator extends StatelessWidget {
  final BatteryValues battery;
  final BatteryConfig config;

  const BatteryIndicator({super.key, required this.battery, required this.config});

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
            dependencies: [battery.energy, battery.energyFull, battery.state],
            derive: () => (battery.energy.value / battery.energyFull.value) * 100,
          ),
          builder: (context, energy, _) {
            return _BatteryIndicator(
              size: Size(width, height),
              batteryLevel: energy,
              isCharging:
                  battery.state.value == UPowerDeviceState.charging ||
                  battery.state.value == UPowerDeviceState.fullyCharged,
              chargingColor: config.chargingColor,
              dischargingColor: config.dischargingColor,
              warningColor: config.warningColor,
              criticalColor: config.criticalColor,
              lightningColor: config.lightningColor,
              outlineColor: config.outlineColor,
              textColor: config.textColor,
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
  final Color outlineColor;
  final Color chargingColor;
  final Color dischargingColor;
  final Color warningColor;
  final Color criticalColor;
  final Color lightningColor;
  final Color textColor;
  final Size size;

  const _BatteryIndicator({
    required this.outlineColor,
    required this.batteryLevel,
    required this.isCharging,
    required this.chargingColor,
    required this.dischargingColor,
    required this.warningColor,
    required this.criticalColor,
    required this.lightningColor,
    required this.textColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    Color fillColor;
    if (isCharging) {
      fillColor = chargingColor;
    } else if (batteryLevel > 50) {
      fillColor = dischargingColor;
    } else if (batteryLevel > 20) {
      fillColor = warningColor;
    } else {
      fillColor = criticalColor;
    }
    final theme = Theme.of(context);
    return CustomPaint(
      size: size,
      painter: _BatteryPainter(
        batteryLevel: batteryLevel,
        fillColor: fillColor,
        outlineColor: outlineColor,
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
