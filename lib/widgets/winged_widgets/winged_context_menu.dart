import "dart:async";

import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/motion_widgets/motion_opacity.dart";
import "package:waywing/widgets/opacity_gradient.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";

enum ContextMenuType {
  manual,
  tooltip,
}

class WingedContextMenu extends StatelessWidget {
  final WingedPopoverHostContentBuilder builder;
  final Widget? child;
  final List<Widget> Function(BuildContext context) itemsBuilder;
  final bool enabled;
  final EdgeInsets padding;
  final BoxConstraints constraints;
  final ContextMenuType type;
  final bool animateOpacity;

  // popover params
  final int zIndex;
  final String? containerId;
  final Alignment anchorAlignment;
  final Alignment popupAlignment;
  final Alignment overflowAlignment;
  final WingedPopoverChildBuilder? containerBuilder;
  final WingedPopoverChildBuilder? closedContainerBuilder;
  final ExtraClippersBuilder? extraClientClipperBuilder;
  final bool fallbackToOppositeAlignmentOnOverflowX;
  final bool fallbackToOppositeAlignmentOnOverflowY;
  final Offset extraOffset;
  final EdgeInsets extraPadding;

  const WingedContextMenu({
    required this.builder,
    required this.itemsBuilder,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.constraints = const BoxConstraints(maxWidth: 256, maxHeight: 512),
    this.zIndex = 20,
    this.containerId = "ContextMenu",
    this.anchorAlignment = Alignment.bottomLeft,
    this.popupAlignment = Alignment.bottomRight,
    this.overflowAlignment = Alignment.topLeft,
    this.containerBuilder,
    this.closedContainerBuilder,
    this.extraClientClipperBuilder,
    this.fallbackToOppositeAlignmentOnOverflowX = true,
    this.fallbackToOppositeAlignmentOnOverflowY = false,
    this.type = ContextMenuType.manual,
    this.extraOffset = Offset.zero,
    this.animateOpacity = true,
    this.extraPadding = EdgeInsets.zero,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final popoverParams = TooltipParams(
      motion: mainConfig.motions.standard.spatial.normal,
      enabled: enabled,
      zIndex: zIndex,
      anchorAlignment: anchorAlignment,
      popupAlignment: popupAlignment,
      overflowAlignment: overflowAlignment,
      containerId: containerId,
      fallbackToOppositeAlignmentOnOverflowX: fallbackToOppositeAlignmentOnOverflowX,
      fallbackToOppositeAlignmentOnOverflowY: fallbackToOppositeAlignmentOnOverflowY,
      extraOffset: extraOffset,
      extraPadding: extraPadding,
      stickToHost: true,
      hideDelay: Duration(milliseconds: 300), // TODO: 3 add tooltip delay to config
      builder: (context, _, _, _) {
        return WingedContextMenuContent(
          padding: padding,
          constraints: constraints,
          children: itemsBuilder(context),
        );
      },
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
      extraClientClipperBuilder: extraClientClipperBuilder,
      tooltipParams: type == ContextMenuType.tooltip ? popoverParams : null,
      popoverParams: type == ContextMenuType.manual ? popoverParams : null,
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
      child: child,
    );
    if (animateOpacity) {
      result = MotionOpacity(
        motion: mainConfig.motions.standard.effects.normal,
        opacity: isClosed ? 0 : 1,
        child: result,
      );
    }
    return result;
  }
}

class WingedContextMenuContent extends StatefulWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final BoxConstraints constraints;
  final Widget Function(BuildContext context, List<Widget> children)? layoutBuilder;

  const WingedContextMenuContent({
    required this.children,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.constraints = const BoxConstraints(maxWidth: 256, maxHeight: 512),
    this.layoutBuilder,
    super.key,
  });

  @override
  State<WingedContextMenuContent> createState() => WingedContextMenuContentState();
}

class WingedContextMenuContentState extends State<WingedContextMenuContent>
    with StatePositioningMixin, StatePositioningNotifierMixin {
  @override
  Widget build(BuildContext context) {
    Widget content;
    if (widget.layoutBuilder != null) {
      content = widget.layoutBuilder!(context, widget.children);
    } else {
      content = IntrinsicHeight(
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.children,
          ),
        ),
      );
    }
    final scrollController = ScrollController();
    return ConstrainedBox(
      constraints: widget.constraints,
      child: Scrollbar(
        controller: scrollController,
        child: ScrollOpacityGradient(
          scrollController: scrollController,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

typedef ContextMenuItemDefaultContentBuilder =
    Widget Function(
      BuildContext context, {
      WingedPopoverController? popover,
    });

typedef ContextMenuItemContentBuilder =
    Widget Function(
      BuildContext context,
      ContextMenuItemDefaultContentBuilder defaultContentBuilder, {
      WingedPopoverController? popover,
    });

typedef WingedContextMenuCallback<T> =
    FutureOr<T>? Function(
      WingedPopoverController? controller,
      TapDownDetails? tapDownDetails,
      TapUpDetails? tapUpDetails,
    );

class WingedContextMenuItem<T> extends StatelessWidget {
  final Widget? child;
  final Widget? icon;
  final WingedContextMenuCallback<T>? onTap;
  final WingedSubmenu? submenu;

  /// overrides default WingedButton, use if more customization is needed
  final ContextMenuItemContentBuilder? contentBuilder;

  const WingedContextMenuItem({
    this.child,
    this.icon,
    this.onTap,
    this.submenu,
    this.contentBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (submenu == null) {
      if (contentBuilder != null) {
        result = contentBuilder!(context, defaultContentBuilder);
      } else {
        result = defaultContentBuilder(context);
      }
    } else {
      final parentContainer = context.findAncestorWidgetOfExactType<WingedContainer>();
      final parentMenu = context.findAncestorWidgetOfExactType<WingedContextMenu>();
      final parentMenuContent = context.findAncestorStateOfType<WingedContextMenuContentState>();
      final padding = submenu!.padding ?? parentMenu?.padding ?? const EdgeInsets.symmetric(vertical: 8);
      result = WingedContextMenu(
        enabled: submenu!.enabled,
        itemsBuilder: submenu!.itemsBuilder,
        type: submenu!.type,
        containerId: submenu!.containerId,
        padding: padding,
        zIndex: submenu!.zIndex ?? (parentMenu == null ? 20 : parentMenu.zIndex - 1),
        anchorAlignment: submenu!.anchorAlignment ?? parentMenu?.anchorAlignment ?? Alignment.topRight,
        popupAlignment: submenu!.popupAlignment ?? parentMenu?.popupAlignment ?? Alignment.bottomRight,
        overflowAlignment: submenu!.overflowAlignment ?? parentMenu?.overflowAlignment ?? Alignment.topLeft,
        extraOffset: submenu!.extraOffset ?? Offset(-padding.left, -padding.top),
        extraPadding: submenu!.extraPadding ?? EdgeInsets.symmetric(horizontal: mainConfig.theme.activeBorderSize),
        fallbackToOppositeAlignmentOnOverflowX:
            submenu!.fallbackToOppositeAlignmentOnOverflowX ??
            parentMenu?.fallbackToOppositeAlignmentOnOverflowX ??
            true,
        fallbackToOppositeAlignmentOnOverflowY:
            submenu!.fallbackToOppositeAlignmentOnOverflowY ??
            parentMenu?.fallbackToOppositeAlignmentOnOverflowY ??
            false,
        containerBuilder: submenu!.containerBuilder ?? parentMenu?.containerBuilder,
        closedContainerBuilder: submenu!.closedContainerBuilder ?? parentMenu?.closedContainerBuilder,
        animateOpacity: submenu!.animateOpacity ?? false,
        constraints:
            submenu!.constraints ?? parentMenu?.constraints ?? const BoxConstraints(maxWidth: 256, maxHeight: 512),
        extraClientClipperBuilder: parentMenuContent == null
            ? null
            : (context, {required child}) {
                return buildDefaultContainerClipper(
                  context,
                  child: child,
                  containers: [
                    (
                      parentContainer?.shape ??
                          ExternalRoundedCornersBorder(
                            borderRadius: BorderRadius.circular(mainConfig.theme.containerRounding),
                          ),
                      parentMenuContent.positioningNotifier,
                    ),
                  ],
                );
              },

        // TODO: 2 the actual content of the button can/should be declared as child, so they are not rebuilt
        builder: (context, popover, child) {
          Widget result;
          if (contentBuilder != null) {
            result = contentBuilder!(context, defaultContentBuilder, popover: popover);
          } else {
            result = defaultContentBuilder(context, popover: popover);
          }
          return result;
        },
      );
    }
    return result;
  }

  Widget defaultContentBuilder(BuildContext context, {WingedPopoverController? popover}) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: onTap != null || submenu != null ? null : Theme.of(context).disabledColor,
        height: 1.33,
      ),
      child: WingedButton(
        // ignore: prefer_if_null_operators
        onTap: onTap != null
            ? (tapDown, tapUp) {
                final parentPopopver = context.findAncestorStateOfType<WingedPopoverClientState>();
                return onTap!(parentPopopver?.widget.host, tapDown, tapUp);
              }
            : submenu != null && popover != null
            ? (_, _) {
                popover.showTooltip(showDelay: Duration.zero);
              }
            : null,
        constraints: const BoxConstraints(minHeight: 30),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        containedInkWell: true,
        child: Row(
          children: [
            if (icon != null) icon!,
            if (icon != null) SizedBox(width: 8),
            Expanded(child: child == null ? SizedBox.shrink() : child!),
            // TODO: 3 allow customizing this?
            if (submenu != null && submenu!.enabled)
              Transform.translate(
                offset: Offset(4, 0),
                child: WingedIcon(
                  flutterIcon: SymbolsVaried.chevron_right,
                  iconNames: ["arrow-right"],
                  textIcon: "󰅂", // nf-md-chevron_right
                  size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.33,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WingedSubmenu {
  final List<Widget> Function(BuildContext context) itemsBuilder;
  final bool enabled;
  final ContextMenuType type;
  final String? containerId;
  final bool? animateOpacity;

  // default to parent
  final int? zIndex;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;
  final Alignment? anchorAlignment;
  final Alignment? popupAlignment;
  final Alignment? overflowAlignment;
  final WingedPopoverChildBuilder? containerBuilder;
  final WingedPopoverChildBuilder? closedContainerBuilder;
  final bool? fallbackToOppositeAlignmentOnOverflowX;
  final bool? fallbackToOppositeAlignmentOnOverflowY;
  final Offset? extraOffset;
  final EdgeInsets? extraPadding;

  WingedSubmenu({
    required this.itemsBuilder,
    this.enabled = true,
    this.containerId,
    this.padding,
    this.constraints,
    this.zIndex,
    this.anchorAlignment,
    this.popupAlignment,
    this.overflowAlignment,
    this.containerBuilder,
    this.closedContainerBuilder,
    this.fallbackToOppositeAlignmentOnOverflowX,
    this.fallbackToOppositeAlignmentOnOverflowY,
    this.type = ContextMenuType.tooltip,
    this.extraOffset,
    this.extraPadding,
    this.animateOpacity,
  });
}
