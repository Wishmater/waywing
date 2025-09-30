import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/motion_widgets/motion_opacity.dart";
import "package:waywing/widgets/motion_widgets/motion_positioned.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";
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
    final passedStyle = widget.textSpan.style;
    final contextStyle = DefaultTextStyle.of(context).style;
    final style = passedStyle != null ? contextStyle.merge(passedStyle) : contextStyle;
    final textSpan = TextSpan(
      style: style,
      text: widget.textSpan.text,
      children: widget.textSpan.children,
      semanticsLabel: widget.textSpan.semanticsLabel,
      semanticsIdentifier: widget.textSpan.semanticsIdentifier,
      onExit: widget.textSpan.onExit,
      locale: widget.textSpan.locale,
      onEnter: widget.textSpan.onEnter,
      spellOut: widget.textSpan.spellOut,
      recognizer: widget.textSpan.recognizer,
      mouseCursor: widget.textSpan.mouseCursor,
    );
    return ValueListenableBuilder(
      valueListenable: sizeNotifier,
      child: widget.child,
      builder: (context, size, child) {
        Widget result = child!;
        if (size != null) {
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
            // maxLines: 1,
          )..layout(maxWidth: 200);
          // final isOverflowing = textPainter.didExceedMaxLines;
          final isOverflowing = textPainter.size.width > size.width || textPainter.size.height > size.height;
          if (isOverflowing) {
            // result = Tooltip(
            //   message: widget.textSpan.text,
            //   waitDuration: const Duration(milliseconds: 250),
            //   child: result,
            // );
            final motion = mainConfig.motions.standard.spatial.fast;
            result = WingedPopover(
              // TODO: 2 add wait duration, potentially more that the one the Bar indicators have
              tooltipParams: TooltipParams(
                showDelay: Duration(seconds: 1), // TODO: 3 maybe use a percentage of declared config showDelay
                motion: motion,
                overflowAlignment: Alignment.centerLeft,
                extraOffset: Offset(-12, 0),
                anchorAlignment: Alignment.centerLeft,
                popupAlignment: Alignment.centerRight,
                zIndex: 999999,
                builder: (context, controller, _, _) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text.rich(widget.textSpan),
                  );
                },
                closedContainerBuilder: (context, child, _, _, _) {
                  return MotionOpacity(
                    motion: motion,
                    opacity: 0,
                    child: WingedContainer(
                      motion: motion,
                      clipBehavior: Clip.hardEdge,
                      shape: ExternalRoundedCornersBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      child: Stack(
                        children: [
                          MotionPositioned(
                            motion: motion,
                            left: -12,
                            top: 0,
                            bottom: 0,
                            child: child,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                containerBuilder: (context, child, _, _, _) {
                  return MotionOpacity(
                    motion: motion,
                    opacity: 1,
                    child: WingedContainer(
                      motion: motion,
                      clipBehavior: Clip.hardEdge,
                      shape: ExternalRoundedCornersBorder(
                        borderRadius: BorderRadius.all(Radius.circular(mainConfig.theme.containerRounding)),
                      ),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Stack(
                        children: [
                          MotionPositioned(
                            motion: motion,
                            left: -0,
                            top: 0,
                            bottom: 0,
                            child: child,
                          ),
                        ],
                      ),
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
