import "package:flutter/material.dart";
import "package:upower/upower.dart";
import "package:waywing/modules/battery/battery_service.dart";
import "package:waywing/util/derived_value_notifier.dart";

class BatteryIndicator extends StatefulWidget {
  final BatteryValues battery;

  const BatteryIndicator({super.key, required this.battery});

  @override
  State<BatteryIndicator> createState() => BatteryIndicatorState();
}

class BatteryIndicatorState extends State<BatteryIndicator> {
  BatteryValues get values => widget.battery;

  @override
  Widget build(BuildContext context) {
    if (!values.isPresent.value) {
      return SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constrains) {
        final width = 35.0.clamp(constrains.minWidth, constrains.maxWidth);
        final height = (15.0 * width/35).clamp(constrains.minHeight, constrains.maxHeight);
        return ValueListenableBuilder(
          valueListenable: DerivedValueNotifier(
            dependencies: [values.energy, values.energyFull, values.state],
            derive: () => (values.energy.value / values.energyFull.value) * 100,
          ),
          builder: (context, energy, _) {
            return _BatteryIndicator(
              size: Size(width, height),
              batteryLevel: 100,
              isCharging:
                  values.state.value == UPowerDeviceState.charging ||
                  values.state.value == UPowerDeviceState.fullyCharged,
              outlineColor: theme.colorScheme.primaryFixedDim,
              chargingColor: theme.colorScheme.primary,
              dischargingColor: theme.brightness == Brightness.light
                  ? theme.colorScheme.surfaceDim
                  : theme.colorScheme.surfaceBright,
              warningColor: theme.colorScheme.tertiary,
              criticalColor: theme.colorScheme.error,
            );
          },
        );
      }
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
  final Size size;

  const _BatteryIndicator({
    required this.outlineColor,
    required this.batteryLevel,
    required this.isCharging,
    required this.chargingColor,
    required this.dischargingColor,
    required this.warningColor,
    required this.criticalColor,
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
    return CustomPaint(
      size: size,
      painter: _BatteryPainter(
        batteryLevel: batteryLevel,
        fillColor: fillColor,
        outlineColor: outlineColor,
      ),
    );
  }
}

class _BatteryPainter extends CustomPainter {
  final double batteryLevel;
  final Color fillColor;
  final Color outlineColor;

  const _BatteryPainter({
    required this.outlineColor,
    required this.batteryLevel,
    required this.fillColor,
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
    final double bodyWidth = size.width * 0.9;
    final double bodyHeight = size.height;
    final double bodyCornerRadius = size.height * 0.2;
    final Rect bodyRect = Rect.fromLTWH(0, 0, bodyWidth, bodyHeight);
    final RRect bodyRRect = RRect.fromRectAndRadius(bodyRect, Radius.circular(bodyCornerRadius));

    // Draw battery tip
    final double tipWidth = size.width * 0.1;
    final double tipHeight = size.height * 0.4;
    final Rect tipRect = Rect.fromLTWH(bodyWidth, (bodyHeight - tipHeight) / 2, tipWidth, tipHeight);
    final RRect tipRRect = RRect.fromRectAndRadius(tipRect, Radius.circular(2));

    // Draw battery fill
    final double fillPadding = size.height * 0.1;
    final double fillWidth = (bodyWidth - fillPadding * 2) * (batteryLevel / 100).clamp(0.0, 1.0);
    final double fillHeight = bodyHeight - fillPadding * 2;
    final Rect fillRect = Rect.fromLTWH(fillPadding, fillPadding, fillWidth, fillHeight);
    final RRect fillRRect = RRect.fromRectAndRadius(fillRect, Radius.circular(bodyCornerRadius * 0.7));

    // Draw the battery
    canvas.drawRRect(bodyRRect, outlinePaint);
    canvas.drawRRect(tipRRect, tipPaint);
    canvas.drawRRect(fillRRect, fillPaint);

    final TextSpan span = TextSpan(
      text: "${batteryLevel.floor()}",
      style: TextStyle(fontSize: size.height * 0.8, color: Colors.white, height: 1),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset((bodyWidth - tp.width) / 2, (bodyHeight - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant _BatteryPainter oldDelegate) {
    return batteryLevel != oldDelegate.batteryLevel ||
        outlineColor != oldDelegate.outlineColor ||
        fillColor != oldDelegate.fillColor;
  }
}
