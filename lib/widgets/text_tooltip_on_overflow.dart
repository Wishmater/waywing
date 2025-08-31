import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/motion_widgets/motion_positioned.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

class TextTooltipOnOverflow extends StatefulWidget {
  final Widget child;
  final TextSpan textSpan;

  const TextTooltipOnOverflow({
    required this.child,
    required this.textSpan,
    super.key,
  });

  @override
  State<TextTooltipOnOverflow> createState() => _TextTooltipOnOverflowState();
}

class _TextTooltipOnOverflowState extends State<TextTooltipOnOverflow>
    with StatePositioningMixin, StatePositioningNotifierMixin {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: sizeNotifier,
      child: widget.child,
      builder: (context, size, child) {
        Widget result = child!;
        if (size != null) {
          final textPainter = TextPainter(
            text: widget.textSpan,
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: size.width);
          final isOverflowing = textPainter.didExceedMaxLines;
          if (isOverflowing) {
            // result = Tooltip(
            //   message: widget.textSpan.text,
            //   waitDuration: const Duration(milliseconds: 250),
            //   child: result,
            // );
            result = WingedPopover(
              // TODO: 2 add wait duration, potentially more that the one the Bar indicators have
              tooltipParams: PopoverParams(
                overflowAlignment: Alignment.centerLeft,
                extraOffset: Offset(-12, 0),
                anchorAlignment: Alignment.centerLeft,
                popupAlignment: Alignment.centerRight,
                zIndex: 999999,
                builder: (context, controller, positioning) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text.rich(widget.textSpan),
                  );
                },
                closedContainerBuilder: (context, controller, child) {
                  return WingedContainer(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.all(Radius.circular(0))),
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        MotionPositioned(
                          motion: mainConfig.motions.standard.spatial.fast,
                          left: -12,
                          top: 0,
                          bottom: 0,
                          child: child,
                        ),
                      ],
                    ),
                  );
                },
                containerBuilder: (context, controller, child) {
                  return WingedContainer(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.all(Radius.circular(12))),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Stack(
                      children: [
                        MotionPositioned(
                          motion: mainConfig.motions.standard.spatial.fast,
                          left: -0,
                          top: 0,
                          bottom: 0,
                          child: child,
                        ),
                      ],
                    ),
                  );
                },
              ),
              child: result,
              builder: (context, controller, child) {
                return child!;
              },
            );
          }
        }
        return result;
      },
    );
  }
}
