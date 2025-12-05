import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/widgets/motion_widgets/motion_opacity.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";

class WingedModal extends StatelessWidget {
  // TODO: 1 make a different DialogController that exposes "showDialog" and maps it to "showPopover", maybe do the same for ContextMenu as well
  final WingedPopoverHostContentBuilder builder;
  final WingedPopoverBuilder dialogBuilder;
  final Widget? child;
  final FixedAnchor fixedAnchor;
  final Color barrierColor;
  final bool barrierDismissable;

  // popover params
  final int zIndex;
  final Alignment anchorAlignment;
  final Alignment popupAlignment;
  final Alignment overflowAlignment;
  final WingedPopoverChildBuilder? containerBuilder;
  final WingedPopoverChildBuilder? closedContainerBuilder;
  final FixedAnchor? fixedOriginAnchor;

  const WingedModal({
    required this.builder,
    required this.dialogBuilder,
    // TODO: 3 maybe default to golden ratio ?
    this.fixedAnchor = const AlignmentFixedAnchor(alignment: defaultAlignment),
    this.barrierColor = Colors.black54,
    this.barrierDismissable = true,
    this.zIndex = 50,
    this.anchorAlignment = Alignment.center,
    this.popupAlignment = Alignment.center,
    this.overflowAlignment = Alignment.topCenter,
    this.containerBuilder,
    this.closedContainerBuilder,
    this.fixedOriginAnchor,
    this.child,
    super.key,
  });

  static const defaultAlignment = Alignment(0, -0.2360679775);

  @override
  Widget build(BuildContext context) {
    final popoverParams = PopoverParams(
      motion: mainConfig.motions.standard.spatial.normal,
      zIndex: zIndex,
      anchorAlignment: anchorAlignment,
      popupAlignment: popupAlignment,
      overflowAlignment: overflowAlignment,
      stickToHost: true,
      builder: dialogBuilder,
      fixedDestinationAnchor: fixedAnchor,
      fixedOriginAnchor: fixedOriginAnchor,
      barrier: BarrierParams(
        color: barrierColor,
        dismissable: barrierDismissable,
      ),
      containerBuilder:
          containerBuilder ??
          (context, child, _, _, _) {
            return buildContainer(context, child, isClosed: false);
          },
      closedContainerBuilder:
          closedContainerBuilder ??
          (containerBuilder != null
              ? null
              : (context, child, _, _, _) {
                  return buildContainer(context, child, isClosed: true);
                }),
    );
    return WingedPopover(
      popoverParams: popoverParams,
      builder: builder,
      child: child,
    );
  }

  Widget buildContainer(BuildContext context, Widget child, {required bool isClosed}) {
    Widget result = WingedContainer(
      clipBehavior: Clip.hardEdge,
      shape: ExternalRoundedCornersBorder(
        borderRadius: BorderRadius.circular(mainConfig.theme.containerRounding),
      ),
      unfocusContainerOnMouseExit: false,
      child: child,
    );
    result = MotionOpacity(
      motion: mainConfig.motions.standard.effects.normal,
      opacity: isClosed ? 0 : 1,
      child: result,
    );
    return result;
  }
}
