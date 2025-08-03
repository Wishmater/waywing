// ignore_for_file: invalid_use_of_visible_for_testing_member

import "package:flutter/material.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/winged_popover_provider.dart";

typedef WidgetBuilderWithChild =
    Widget Function(
      BuildContext context,
      Widget child,
    );

typedef WingedPopoverChildBuilder =
    Widget Function(
      BuildContext context,
      WingedPopoverController popover,
      Widget? child,
    );

abstract class WingedPopoverController {
  bool get isPopoverShown;
  bool get isTooltipShown;
  void showPopover();
  void hidePopover();
  void togglePopover();
  void hideTooltip();
}

@immutable
class PopoverParams {
  final WidgetBuilder builder;
  final EdgeInsets screenPadding;
  final Alignment anchorAlignment;
  final Alignment popupAlignment;
  final String? containerId;
  final int zIndex;
  final bool enabled;
  final Offset extraOffset;
  final EdgeInsets extraPadding;

  /// Make sure the container doesn't add any padding, or modifies
  /// the size of the child in any way, or the it can cause positioning bugs.
  final WidgetBuilderWithChild containerBuilder;

  /// Useful to trigger implicit animations in container (borders, etc.)
  final WidgetBuilderWithChild? closedContainerBuilder;

  const PopoverParams({
    required this.builder,
    required this.containerBuilder,
    this.screenPadding = EdgeInsets.zero,
    this.anchorAlignment = Alignment.center,
    this.popupAlignment = Alignment.center,
    this.containerId,
    this.closedContainerBuilder,
    this.zIndex = 10,
    this.enabled = true,
    this.extraOffset = Offset.zero,
    this.extraPadding = EdgeInsets.zero,
  });
}

class WingedPopover extends StatefulWidget {
  final WingedPopoverChildBuilder builder;
  final Widget? child;
  final PopoverParams? popoverParams;
  final PopoverParams? tooltipParams;

  const WingedPopover({
    required this.builder,
    this.popoverParams,
    this.tooltipParams,
    this.child,
    super.key,
  }) : assert(popoverParams != null || tooltipParams != null);

  @override
  State<WingedPopover> createState() => WingedPopoverState();
}

class WingedPopoverState extends State<WingedPopover>
    with StatePositioningMixin, StatePositioningNotifierMixin
    implements WingedPopoverController {
  late final WingedPopoverProviderState _provider;

  late final clientKey = GlobalKey<WingedPopoverClientState>();

  @override
  bool isPopoverShown = false;
  @override
  bool isTooltipShown = false;
  WingedPopoverClientState? clientState;

  @override
  void initState() {
    super.initState();
    // this fails to detect changes upstream in the tree to register a new provider,
    // but this shouldn't happen in our use case
    _provider = context.findAncestorStateOfType<WingedPopoverProviderState>()!;
    scheduleCheckPositioningChange();
  }

  @override
  void dispose() {
    super.dispose();
    if (isPopoverShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        hidePopover();
      });
    }
  }

  @override
  void didUpdateWidget(covariant WingedPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isPopoverShown && (widget.popoverParams == null || !widget.popoverParams!.enabled)) {
      hidePopover();
    }
    if (isTooltipShown && (widget.tooltipParams == null || !widget.tooltipParams!.enabled)) {
      hideTooltip();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (clientState?.mounted ?? false) {
        clientState?.setState(() {});
      }
    });
  }

  @override
  void showPopover() => _provider.showHost(this);

  @override
  void hidePopover() => _provider.hideHost(this);

  @override
  void togglePopover() => _provider.toggleHost(this);

  @override
  void hideTooltip() => _provider.hideHost(this);

  @override
  Widget build(BuildContext context) {
    Widget result = widget.builder(context, this, widget.child);
    // TODO: 3 changes to .showAsTooltip value while the state is alive are not handled properly
    // like it is right now the tree will change, so the children will be rebuilt, and there is
    // also a chance the tooltip will be stuck show (because onExit will never be called).
    // I can't think of a situation where you would change the value of .showAsTooltip, so whatever...
    if (widget.tooltipParams != null) {
      result = MouseRegion(
        onEnter: (_) => _provider.onMouseEnterHost(this),
        onExit: (_) => _provider.onMouseExitHost(this),
        child: result,
      );
    }
    return result;
  }
}
