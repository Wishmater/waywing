import "package:flutter/material.dart";
import "package:upower/upower.dart";
import "package:waywing/modules/battery/battery_service.dart";
import "package:waywing/util/derived_value_notifier.dart";

class BatteryWidget extends StatefulWidget {
  final BatteryValues values;

  const BatteryWidget({super.key, required this.values});

  @override
  State<BatteryWidget> createState() => BatteryWidgetState();
}

class BatteryWidgetState extends State<BatteryWidget> {
  BatteryValues get values => widget.values;

  @override
  Widget build(BuildContext context) {
    if (!values.isPresent.value) {
      return SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 2, right: 2, top: 10, bottom: 10),
      child: ValueListenableBuilder(
        valueListenable: DerivedValueNotifier(
          dependencies: [values.energy, values.energyFull, values.state],
          derive: () => (values.energy.value / values.energyFull.value) * 100,
        ),
        builder: (context, energy, _) {
          return BatteryIndicator(
            batteryLevel: energy,
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
      ),
    );
  }
}

class BatteryIndicator extends StatelessWidget {
  final double batteryLevel; // Value from 0 to 100
  final bool isCharging;
  final Color outlineColor;
  final Color chargingColor;
  final Color dischargingColor;
  final Color warningColor;
  final Color criticalColor;

  const BatteryIndicator({
    super.key,
    required this.outlineColor,
    required this.batteryLevel,
    required this.isCharging,
    required this.chargingColor,
    required this.dischargingColor,
    required this.warningColor,
    required this.criticalColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BatteryPainter(
        batteryLevel: batteryLevel,
        isCharging: isCharging,
        outlineColor: outlineColor,
        chargingColor: chargingColor,
        dischargingColor: dischargingColor,
        warningColor: warningColor,
        criticalColor: criticalColor,
      ),
    );
  }
}

class _BatteryPainter extends CustomPainter {
  final double batteryLevel;
  final bool isCharging;
  final Color outlineColor;
  final Color chargingColor;
  final Color dischargingColor;
  final Color warningColor;
  final Color criticalColor;

  const _BatteryPainter({
    required this.outlineColor,
    required this.batteryLevel,
    required this.isCharging,
    required this.chargingColor,
    required this.dischargingColor,
    required this.warningColor,
    required this.criticalColor,
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

    // Determine battery color based on level
    if (isCharging) {
      fillPaint.color = chargingColor;
    } else if (batteryLevel > 50) {
      fillPaint.color = dischargingColor;
    } else if (batteryLevel > 20) {
      fillPaint.color = warningColor;
    } else {
      fillPaint.color = criticalColor;
    }

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
        isCharging != oldDelegate.isCharging ||
        outlineColor != oldDelegate.outlineColor ||
        chargingColor != oldDelegate.chargingColor ||
        dischargingColor != oldDelegate.dischargingColor ||
        warningColor != oldDelegate.warningColor ||
        criticalColor != oldDelegate.criticalColor;
  }
}
