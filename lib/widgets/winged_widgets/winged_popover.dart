import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/focus_grab/widget.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/motion_widgets/motion_opacity.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";

typedef WingedPopoverHostContentBuilder =
    Widget Function(
      BuildContext context,
      WingedPopoverController popover,
      Widget? child,
    );

typedef WingedPopoverBuilder =
    Widget Function(
      BuildContext context,
      WingedPopoverController popover,
      PositioningNotifierController childPositioningController,
      ValueNotifier<Positioning?> targetChildContainerPositioning,
    );

typedef WingedPopoverChildBuilder =
    Widget Function(
      BuildContext context,
      Widget child,
      WingedPopoverController popover,
      PositioningNotifierController childPositioningController,
      ValueNotifier<Positioning?> targetChildContainerPositioning,
    );

typedef ExtraClippersBuilder =
    Widget Function(
      BuildContext context, {
      required Widget child,
    });

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
  final bool enableIntrinsicSizeAnimation;
  final bool ignorePointer;

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
    this.enableIntrinsicSizeAnimation = false,
    this.ignorePointer = false,
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
    super.enableIntrinsicSizeAnimation = false,
    super.ignorePointer = false,
    this.showDelay = const Duration(milliseconds: 300), // TODO: 1 add tooltip delay to config
    this.hideDelay = Duration.zero, // TODO: 1 add tooltip delay to config
  });
}

class WingedPopover extends StatefulWidget {
  final WingedPopoverHostContentBuilder builder;
  final Widget? child;
  final PopoverParams? popoverParams;
  final TooltipParams? tooltipParams;
  final ExtraClippersBuilder? extraClientClipperBuilder;

  const WingedPopover({
    required this.builder,
    this.popoverParams,
    this.tooltipParams,
    this.extraClientClipperBuilder,
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

  bool _isPopoverShown = false;
  @override
  bool get isPopoverShown => _isPopoverShown;
  set isPopoverShown(bool value) {
    if (value == false && _isPopoverShown) {
      focusGrabController.ungrabFocus();
    } else if (value == true && !_isPopoverShown) {
      if (mainConfig.focusGrab) {
        focusGrabController.grabFocus();
      }
    }
    _isPopoverShown = value;
  }

  @override
  bool isTooltipShown = false;
  @override
  bool get isPopoverEnabled => widget.popoverParams?.enabled ?? false;
  @override
  bool get isTooltipEnabled => widget.tooltipParams?.enabled ?? false;
  @override
  WingedPopoverState get hostState => this;

  WingedPopoverClientState? clientState;

  late final FocusGrabController focusGrabController = FocusGrabController(onCleared: hidePopover);

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

  /// override getPositioning to further constraint positioning/size to that of the parent
  /// if the parent is being removed
  @override
  Positioning getPositioning({BuildContext? parentContext}) {
    final positioning = super.getPositioning(parentContext: parentContext);
    final parent = this.parent;
    if (parent == null || !parent.widget.isRemoved) return positioning;
    final parentPositioning = parent.childContainerPositioningController.positioningNotifier.value;
    if (parentPositioning == null) return positioning;
    final rect = positioning.toRect();
    final parentRect = parentPositioning.toRect();
    var intersection = rect.intersect(parentRect);
    if (intersection.height < 0) {
      if ((parentRect.top - rect.top).abs() < (parentRect.bottom - rect.top).abs()) {
        intersection = Rect.fromLTWH(intersection.left, parentRect.top, intersection.width, 0);
      } else {
        intersection = Rect.fromLTWH(intersection.left, parentRect.bottom, intersection.width, 0);
      }
    }
    if (intersection.width < 0) {
      if ((parentRect.left - rect.left).abs() < (parentRect.right - rect.left).abs()) {
        intersection = Rect.fromLTWH(parentRect.left, intersection.top, 0, intersection.height);
      } else {
        intersection = Rect.fromLTWH(parentRect.right, intersection.top, 0, intersection.height);
      }
    }
    return Positioning.fromRect(intersection);
  }

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
    return FocusGrab(
      controller: focusGrabController,
      child: result,
    );
  }
}

class WingedTooltip extends StatelessWidget {
  final Widget child;
  final WidgetBuilder tooltipBuilder;
  final Motion? motion;
  final Alignment alignment;
  final EdgeInsets padding;
  final Duration? showDelay;
  final bool ignorePointer;

  const WingedTooltip({
    required this.child,
    required this.tooltipBuilder,
    this.motion,
    this.alignment = Alignment.bottomCenter,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.showDelay,
    this.ignorePointer = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final motion = this.motion ?? mainConfig.motions.standard.spatial.fast;
    return WingedPopover(
      tooltipParams: TooltipParams(
        motion: motion,
        anchorAlignment: alignment,
        popupAlignment: alignment,
        zIndex: 999999,
        ignorePointer: ignorePointer,
        builder: (context, controller, _, _) {
          return Padding(
            padding: padding,
            child: tooltipBuilder(context),
          );
        },
        closedContainerBuilder: (context, child, _, _, _) {
          return MotionOpacity(
            motion: motion,
            opacity: 0,
            child: WingedContainer(
              motion: motion,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              // activeBorder: GradientBorderSide.none,
              // inactiveBorder: GradientBorderSide.none,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              shape: ExternalRoundedCornersBorder(
                borderRadius: BorderRadius.all(Radius.circular(mainConfig.theme.containerRounding)),
              ),
              child: child,
            ),
          );
        },
        containerBuilder: (context, child, _, _, _) {
          return MotionOpacity(
            motion: motion,
            opacity: 1,
            child: WingedContainer(
              motion: motion,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              // activeBorder: GradientBorderSide.none,
              // inactiveBorder: GradientBorderSide.none,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              shape: ExternalRoundedCornersBorder(
                borderRadius: BorderRadius.all(Radius.circular(mainConfig.theme.containerRounding)),
              ),
              child: child,
            ),
          );
        },
      ),
      child: child,
      builder: (_, _, child) => child!,
    );
  }
}
