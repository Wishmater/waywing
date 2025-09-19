// ignore_for_file: invalid_use_of_visible_for_testing_member

import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";

typedef WingedPopoverBuilder =
    Widget Function(
      BuildContext context,
      WingedPopoverController popover,
      PositioningNotifierController childPositioningController,
    );

typedef WingedPopoverChildBuilder =
    Widget Function(
      BuildContext context,
      WingedPopoverController popover,
      Widget child,
    );

typedef WingedPopoverChildNullableBuilder =
    Widget Function(
      BuildContext context,
      WingedPopoverController popover,
      Widget? child,
    );

abstract class WingedPopoverController {
  bool get isPopoverEnabled;
  bool get isTooltipEnabled;
  bool get isPopoverShown;
  bool get isTooltipShown;
  void showPopover();
  void hidePopover();
  void togglePopover();
  Future<void> showTooltip({Duration? showDelay});
  Future<void> hideTooltip({Duration? hideDelay});
  Future<void> toggleTooltip({Duration? showDelay, Duration? hideDelay});
  StatePositioningNotifierMixin get hostState;
}

@immutable
class PopoverParams {
  final WingedPopoverBuilder builder;
  final EdgeInsets screenPadding;
  final Alignment anchorAlignment;
  final Alignment popupAlignment;
  final Alignment overflowAlignment;
  final String? containerId;
  final int zIndex;
  final bool enabled;
  final Offset extraOffset;
  final EdgeInsets extraPadding;
  final Motion? motion;

  /// Make sure the container doesn't add any padding, or modifies
  /// the size of the child in any way, or the it can cause positioning bugs.
  final WingedPopoverChildBuilder containerBuilder;

  /// Useful to trigger implicit animations in container (borders, etc.)
  final WingedPopoverChildBuilder? closedContainerBuilder;

  /// If this is true, when position or size animations overshoot, the side of the
  /// popover that touches the host will not be separated from it.
  final bool stickToHost;

  const PopoverParams({
    required this.builder,
    required this.containerBuilder,
    this.screenPadding = EdgeInsets.zero,
    this.anchorAlignment = Alignment.center,
    this.popupAlignment = Alignment.center,
    this.overflowAlignment = Alignment.center,
    this.containerId,
    this.closedContainerBuilder,
    this.zIndex = 10,
    this.enabled = true,
    this.extraOffset = Offset.zero,
    this.extraPadding = EdgeInsets.zero,
    this.motion,
    this.stickToHost = false,
  });
}

class TooltipParams extends PopoverParams {
  final Duration showDelay;
  final Duration hideDelay;

  const TooltipParams({
    required super.builder,
    required super.containerBuilder,
    super.screenPadding = EdgeInsets.zero,
    super.anchorAlignment = Alignment.center,
    super.popupAlignment = Alignment.center,
    super.overflowAlignment = Alignment.center,
    super.containerId,
    super.closedContainerBuilder,
    super.zIndex = 10,
    super.enabled = true,
    super.extraOffset = Offset.zero,
    super.extraPadding = EdgeInsets.zero,
    super.motion,
    super.stickToHost = false,
    this.showDelay = const Duration(milliseconds: 300), // TODO: 3 add tooltip delay to config
    this.hideDelay = Duration.zero, // TODO: 3 add tooltip delay to config
  });
}

class WingedPopover extends StatefulWidget {
  final WingedPopoverChildNullableBuilder builder;
  final Widget? child;
  final PopoverParams? popoverParams;
  final TooltipParams? tooltipParams;
  final List<(ShapeBorder, ValueNotifier<Positioning?>)> extraClientClippers;

  const WingedPopover({
    required this.builder,
    this.popoverParams,
    this.tooltipParams,
    this.extraClientClippers = const [],
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

  bool isHovered = false;

  late final clientKey = GlobalKey<WingedPopoverClientState>();

  late WingedPopoverClientState? parent;

  @override
  bool isPopoverShown = false;
  @override
  bool isTooltipShown = false;
  @override
  bool get isPopoverEnabled => widget.popoverParams?.enabled ?? false;
  @override
  bool get isTooltipEnabled => widget.tooltipParams?.enabled ?? false;
  @override
  WingedPopoverState get hostState => this;

  WingedPopoverClientState? clientState;

  @override
  void initState() {
    super.initState();
    // this fails to detect changes upstream in the tree to register a new provider,
    // but this shouldn't happen in our use case
    _provider = context.findAncestorStateOfType<WingedPopoverProviderState>()!;
    parent = context.findAncestorStateOfType<WingedPopoverClientState>();
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && isPopoverShown && (clientState?.mounted ?? false)) {
          hidePopover();
        }
      });
    }
    if (isTooltipShown && (widget.tooltipParams == null || !widget.tooltipParams!.enabled)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && isTooltipShown && (clientState?.mounted ?? false)) {
          hideTooltip();
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (clientState?.mounted ?? false)) {
        clientState?.setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    parent = context.findAncestorStateOfType<WingedPopoverClientState>();
  }

  @override
  void showPopover() => _provider.showHost(this);

  @override
  void hidePopover() => _provider.hideHost(this);

  @override
  void togglePopover() => _provider.toggleHost(this);

  @override
  Future<void> showTooltip({Duration? showDelay}) => _provider.showTooltip(this, showDelay: showDelay);

  @override
  Future<void> hideTooltip({Duration? hideDelay}) => _provider.hideTooltip(this, hideDelay: hideDelay);

  @override
  Future<void> toggleTooltip({Duration? showDelay, Duration? hideDelay}) =>
      _provider.toggleTooltip(this, showDelay: showDelay, hideDelay: hideDelay);

  @override
  Widget build(BuildContext context) {
    Widget result = widget.builder(context, this, widget.child);
    // TODO: 3 changes to .showAsTooltip value while the state is alive are not handled properly
    // like it is right now the tree will change, so the children will be rebuilt, and there is
    // also a chance the tooltip will be stuck show (because onExit will never be called).
    // I can't think of a situation where you would change the value of .showAsTooltip, so whatever...
    if (widget.tooltipParams?.enabled ?? false) {
      result = MouseRegion(
        onEnter: (_) {
          isHovered = true;
          _provider.onMouseEnterHost(this);
        },
        onExit: (_) {
          isHovered = false;
          _provider.onMouseExitHost(this);
        },
        child: result,
      );
    }
    return result;
  }
}
