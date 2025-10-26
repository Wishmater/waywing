import "package:flutter/material.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

class IconAndTextIndicator extends StatelessWidget {
  final Widget? icon;
  final String text;
  final String? tooltip;
  final EdgeInsets padding;

  /// pass this in so this widget doesn't need its own LayoutBuilder
  final IconAndTextLayout? layout;

  const IconAndTextIndicator({
    required this.icon,
    required this.text,
    this.tooltip,
    this.padding = EdgeInsets.zero,
    this.layout,
    super.key,
  });

  IconAndTextIndicator.withConstraints({
    required this.icon,
    required this.text,
    this.tooltip,
    this.padding = EdgeInsets.zero,
    required BoxConstraints constraints,
    super.key,
  }) : layout = IconAndTextLayout.fromConstraints(constraints);

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (layout != null) {
      result = buildLayout(context, layout!);
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          return buildLayout(context, IconAndTextLayout.fromConstraints(constraints));
        },
      );
    }
    if (tooltip != null) {
      result = WingedTooltip(
        tooltipBuilder: (context) => Text(tooltip!),
        ignorePointer: true,
        child: result,
      );
    }
    return Padding(
      padding: padding,
      child: result,
    );
  }

  Widget buildLayout(BuildContext context, IconAndTextLayout layout) {
    return switch (layout) {
      IconAndTextLayout.horizontal => Text.rich(
        maxLines: 1,
        softWrap: false,
        TextSpan(
          children: [
            if (icon != null) WidgetSpan(child: icon!),
            if (icon != null) WidgetSpan(child: SizedBox(width: 2)),
            TextSpan(text: text),
          ],
        ),
      ),
      IconAndTextLayout.vertical => IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) icon!,
            SizedBox(width: 1),
            Expanded(
              child: Text(
                text,
                textAlign: icon == null ? TextAlign.center : TextAlign.start,
                style: TextStyle(height: 1),
              ),
            ),
          ],
        ),
      ),
      IconAndTextLayout.verticalSmall => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) icon!,
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(height: 1),
          ),
        ],
      ),
    };
  }
}

enum IconAndTextLayout {
  horizontal,
  vertical,
  verticalSmall;

  static IconAndTextLayout fromConstraints(BoxConstraints constraints) {
    if (constraints.maxWidth < 56) {
      return IconAndTextLayout.verticalSmall;
    }
    if (constraints.maxWidth < constraints.maxHeight) {
      return IconAndTextLayout.vertical;
    }
    return IconAndTextLayout.horizontal;
  }
}
