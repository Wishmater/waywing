import "package:dartx/dartx.dart";
import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/util/popup_utils.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/shape_clipper.dart";
import "package:waywing/widgets/winged_popover.dart";

final _logger = mainLogger.clone(properties: [LogType("PopoverProvider")]);

class WingedPopoverProvider extends StatefulWidget {
  final Widget child;

  const WingedPopoverProvider({
    required this.child,
    super.key,
  });

  @override
  State<WingedPopoverProvider> createState() => WingedPopoverProviderState();
}

class WingedPopoverProviderState extends State<WingedPopoverProvider> {
  final GlobalKey childGlobalKey = GlobalKey(); // to prevent child being rebuilt when adding/removing elements on stack
  final Map<String, GlobalKey<WingedPopoverClientState>> containerGlobalKeys = {};
  final Set<WingedPopoverState> activeHosts = {};
  final Map<WingedPopoverState, TooltipHoverStatus> tooltipHosts = {};
  final Map<WingedPopoverState, bool> removedHosts = {};

  void showHost(WingedPopoverState host) {
    assert(host.widget.popoverParams != null, "Trying to show popover for a host that doesn't specify popoverParams");
    if (activeHosts.contains(host)) {
      _logger.log(Level.error, "Trying to register a host that already exists to PopoverProvider.");
      return;
    }
    if (tooltipHosts.containsKey(host) || removedHosts.containsKey(host)) {
      _removeHost(host);
    }
    if (host.widget.popoverParams!.containerId case final containerId?) {
      _removeAllWithContainerId(containerId);
    }
    activeHosts.add(host);
    host.isPopoverShown = true;
    setState(() {});
  }

  void hideHost(WingedPopoverState host) {
    final isActive = activeHosts.remove(host);
    final isTooltip = tooltipHosts.remove(host) != null;
    if (!isActive && !isTooltip) {
      _logger.log(Level.error, "Trying to hide a host that doesn't exist in PopoverProvider.");
      return;
    }
    if (host.clientState?.passedMeaningfulPaint ?? false) {
      // don't bother initializing exit animation if it hasn't reached meaningful paint (which is usually 2 frames)
      removedHosts[host] = isTooltip;
    }
    host.isPopoverShown = false;
    host.isTooltipShown = false;
    setState(() {});
  }

  void onMouseEnterHost(WingedPopoverState host) {
    if (!tooltipHosts.containsKey(host)) {
      _showTooltip(host);
    } else {
      tooltipHosts[host]!.host = true;
    }
  }

  void onMouseExitHost(WingedPopoverState host) {
    if (!tooltipHosts.containsKey(host)) {
      return; // this shouldn't happen, but whatever...
    }
    tooltipHosts[host]!.host = false;
    _scheduleCheckHideTooltip(host);
  }

  void onMouseEnterClient(WingedPopoverClientState client) {
    if (!tooltipHosts.containsKey(client.widget.host)) {
      return; // the tooltip client is in animation of being removed
    }
    tooltipHosts[client.widget.host]!.client = true;
  }

  void onMouseExitClient(WingedPopoverClientState client) {
    if (!tooltipHosts.containsKey(client.widget.host)) {
      return; // the tooltip client is in animation of being removed
    }
    tooltipHosts[client.widget.host]!.client = false;
    _scheduleCheckHideTooltip(client.widget.host);
  }

  void _showTooltip(WingedPopoverState host) {
    if (tooltipHosts.containsKey(host)) {
      _logger.log(Level.error, "Trying to register a tooltip host that already exists to PopoverProvider.");
      return;
    }
    if (activeHosts.contains(host)) {
      return; // ignore tooltip calls if it's already manually shown
    }
    if (removedHosts.containsKey(host)) {
      _removeHost(host);
    }
    // TODO: 2 add delay to showing tooltip after entering host (param passed to the host)
    if (host.widget.tooltipParams!.containerId case final containerId?) {
      _removeAllWithContainerId(containerId);
    }
    tooltipHosts[host] = TooltipHoverStatus(host: true);
    host.isTooltipShown = true;
    setState(() {});
  }

  void _removeAllWithContainerId(String containerId) {
    final toRemove = activeHosts.where((e) {
      return e.widget.popoverParams!.containerId == containerId;
    }).toList();
    toRemove.addAll(
      tooltipHosts.keys.where((e) {
        return e.widget.tooltipParams!.containerId == containerId;
      }),
    );
    toRemove.addAll(
      removedHosts.keys.where((e) {
        final removedContainerId = removedHosts[e]!
            ? e.widget.tooltipParams!.containerId
            : e.widget.popoverParams!.containerId;
        return removedContainerId == containerId;
      }),
    );
    for (final e in toRemove) {
      _removeHost(e);
    }
  }

  // necessary because when mouse goes from host to client, if we check immediately
  // it will be removed because it goes out of the host before going into the client
  void _scheduleCheckHideTooltip(WingedPopoverState host) {
    if (_isCheckHideTooltipScheduled) return;
    _isCheckHideTooltipScheduled = true;
    // this NEEDS to wait 2 frames for it to be consistent
    WidgetsBinding.instance.scheduleFrame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.scheduleFrame();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkHideTooltip(host);
        _isCheckHideTooltipScheduled = false;
      });
    });
  }

  bool _isCheckHideTooltipScheduled = false;
  void _checkHideTooltip(WingedPopoverState host) {
    final status = tooltipHosts[host];
    if (status != null && !status.client && !status.host) {
      hideHost(host);
    }
  }

  void _removeHost(WingedPopoverState host) {
    assert(
      activeHosts.contains(host) || removedHosts.containsKey(host) || tooltipHosts.containsKey(host),
      "Trying to remove a host that doesn't exist in PopoverProvider.",
    );
    activeHosts.remove(host);
    removedHosts.remove(host);
    tooltipHosts.remove(host);
    host.isPopoverShown = false;
    host.isTooltipShown = false;
    setState(() {});
  }

  void toggleHost(WingedPopoverState host) {
    if (activeHosts.contains(host)) {
      hideHost(host);
    } else {
      showHost(host);
    }
  }

  void onHostDidUpdateWidget(WingedPopoverState host) {}

  @override
  Widget build(BuildContext context) {
    final widgetsBelowMap = <Widget, int>{};
    final widgetsAboveMap = <Widget, int>{};
    buildClientWidgets(
      context,
      activeHosts,
      widgetsBelowMap,
      widgetsAboveMap,
    );
    buildClientWidgets(
      context,
      tooltipHosts.keys,
      widgetsBelowMap,
      widgetsAboveMap,
      isTooltip: (_) => true,
    );
    buildClientWidgets(
      context,
      removedHosts.keys,
      widgetsBelowMap,
      widgetsAboveMap,
      isRemoved: true,
      isTooltip: (host) => removedHosts[host]!,
    );
    final widgetsBelow = widgetsBelowMap.keys.toList();
    widgetsBelow.sortedBy((e) => widgetsBelowMap[e]!);
    final widgetsAbove = widgetsAboveMap.keys.toList();
    widgetsAbove.sortedBy((e) => widgetsAboveMap[e]!);
    return Stack(
      children: [
        ...widgetsBelow,
        KeyedSubtree(key: childGlobalKey, child: widget.child),
        ...widgetsAbove,
      ],
    );
  }

  void buildClientWidgets(
    BuildContext context,
    Iterable<WingedPopoverState> hosts,
    Map<Widget, int> widgetsBelowMap,
    Map<Widget, int> widgetsAboveMap, {
    bool isRemoved = false,
    bool Function(WingedPopoverState host)? isTooltip,
  }) {
    for (final host in hosts) {
      final isTooltipValue = isTooltip?.call(host) ?? false;
      final widget = WingedPopoverClient(
        host: host,
        key: getClientKey(host, isTooltip: isTooltipValue),
        isRemoved: isRemoved,
        isTooltip: isTooltipValue,
      );
      final popoverParams = isTooltipValue ? host.widget.tooltipParams : host.widget.popoverParams;
      if (popoverParams!.zIndex < 0) {
        widgetsBelowMap[widget] = popoverParams.zIndex;
      } else {
        widgetsAboveMap[widget] = popoverParams.zIndex;
      }
    }
  }

  GlobalKey<WingedPopoverClientState> getClientKey(
    WingedPopoverState host, {
    required bool isTooltip,
  }) {
    final popoverParams = isTooltip ? host.widget.tooltipParams : host.widget.popoverParams;
    if (popoverParams!.containerId != null) {
      containerGlobalKeys[popoverParams.containerId!] ??= GlobalKey();
      return containerGlobalKeys[popoverParams.containerId!]!;
    } else {
      return host.clientKey;
    }
  }
}

class WingedPopoverClient extends StatefulWidget {
  final WingedPopoverState host;
  final bool isRemoved;
  final bool isTooltip;

  const WingedPopoverClient({
    required this.host,
    required this.isRemoved,
    required this.isTooltip,
    super.key,
  });

  @override
  State<WingedPopoverClient> createState() => WingedPopoverClientState();
}

class WingedPopoverClientState extends State<WingedPopoverClient> with TickerProviderStateMixin {
  final childPositioningController = PositioningNotifierController();

  // this means it passed the 2nd frame, where we can actually get child sizing
  bool passedMeaningfulPaint = false;

  late final provider = context.findAncestorStateOfType<WingedPopoverProviderState>()!;

  @override
  void initState() {
    super.initState();
    _buildContentAnimationController(isFirst: true);
  }

  @override
  void dispose() {
    contentAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WingedPopoverClient oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.host != oldWidget.host || widget.isTooltip != oldWidget.isTooltip) {
      _triggerContentAnimation();
    }
  }

  late AnimationController contentAnimationController;
  void _buildContentAnimationController({
    bool isFirst = false,
  }) {
    if (!isFirst) {
      contentAnimationController.dispose();
    }
    contentAnimationController = AnimationController(
      vsync: this,
      duration: config.animationDuration,
      value: 1,
    );
  }

  void _triggerContentAnimation() {
    _buildContentAnimationController();
    contentAnimationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRemoved && !passedMeaningfulPaint) {
      // this should never happen, because provider checks this and insta-removed if needed, but just in case...
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onRemoveAnimationEnd();
      });
      return SizedBox.shrink();
    }
    final popoverParams = (widget.isTooltip ? widget.host.widget.tooltipParams : widget.host.widget.popoverParams)!;
    widget.host.clientState = this;
    final screenSize = MediaQuery.sizeOf(context);
    final content = AnimatedBuilder(
      animation: CurvedAnimation(parent: contentAnimationController, curve: config.animationCurve),
      builder: (context, child) {
        return Opacity(
          opacity: contentAnimationController.value,
          child: child!,
        );
      },
      child: OverflowBox(
        alignment: popoverParams.popupAlignment,
        fit: OverflowBoxFit.deferToChild,
        minWidth: 0,
        minHeight: 0,
        maxWidth: screenSize.width,
        maxHeight: screenSize.height,
        // TODO: 2 add animation transition to the child (for cases with containerId)
        // maybe allow host to decide the transitionBuilder, so the bar can animate up/down
        child: PositioningNotifierMonitor(
          controller: childPositioningController,
          child: popoverParams.builder(context),
        ),
      ),
    );
    final container = popoverParams.containerBuilder(context, content);

    return ValueListenableBuilder(
      valueListenable: widget.host.positioningNotifier,
      child: container,
      builder: (context, hostPositioning, container) {
        return ValueListenableBuilder(
          valueListenable: childPositioningController.sizeNotifier,
          child: container,
          builder: (context, childSize, container) {
            if (hostPositioning == null) {
              mainLogger.log(Level.error, "Popover client built before host. This should never happen");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {});
              });
              return SizedBox.shrink();
            }
            final (hostPosition, hostSize) = hostPositioning;
            // print("-----------------------------------");
            // print("hostSize: $hostSize");
            // print("hostPosition: $hostPosition");
            Offset childPosition;
            if (widget.isRemoved) {
              childSize = hostSize;
              childPosition = hostPosition;
              if (popoverParams.closedContainerBuilder != null) {
                container = popoverParams.closedContainerBuilder!(context, content);
              }
            } else if (childSize == null) {
              // assuming this happens the first time the widget builds
              // fall back to setting the size/position of the host,
              // which should have the added effect of animating entry
              childSize = hostSize;
              childPosition = hostPosition;
              if (popoverParams.closedContainerBuilder != null) {
                container = popoverParams.closedContainerBuilder!(context, content);
              }
            } else {
              childSize += Offset(popoverParams.extraPadding.horizontal, popoverParams.extraPadding.vertical);
              childPosition = getPopoverPosition(
                anchorAlignment: popoverParams.anchorAlignment,
                popupAlignment: popoverParams.popupAlignment,
                hostPosition: hostPosition,
                hostSize: hostSize,
                childSize: childSize,
                screenSize: screenSize,
                padding: popoverParams.screenPadding,
                extraOffset: popoverParams.extraOffset,
              );
              passedMeaningfulPaint = true;
            }
            container = AnimatedPadding(
              duration: config.animationDuration,
              curve: config.animationCurve,
              padding: passedMeaningfulPaint ? popoverParams.extraPadding : EdgeInsets.zero,
              child: container,
            );
            if (widget.isTooltip) {
              // TODO: 2 this InputRegion is necessary only when extraPadding is declared (like on bar tooltip)
              // this solution is not ideal because it may conflict with the better declared InputRegion on the
              // Popover container, which might include detailed border radius, etc.
              container = InputRegion(
                child: MouseRegion(
                  onEnter: (_) => provider.onMouseEnterClient(this),
                  onExit: (_) => provider.onMouseExitClient(this),
                  child: container,
                ),
              );
            }
            // print("childSize: $childSize");
            // print("childPosition: $childPosition");
            Widget result = AnimatedPositioned(
              duration: config.animationDuration,
              curve: config.animationCurve,
              left: childPosition.dx,
              top: childPosition.dy,
              width: childSize.width,
              height: childSize.height,
              onEnd: !widget.isRemoved ? null : onRemoveAnimationEnd,
              child: container,
            );

            // add extra client clippers
            if (widget.host.widget.extraClientClippers.isNotEmpty) {
              result = Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [result],
              );
              for (final e in widget.host.widget.extraClientClippers) {
                result = ValueListenableBuilder(
                  valueListenable: e.$2,
                  child: result,
                  builder: (context, positioning, child) {
                    Rect? rect;
                    if (positioning != null) {
                      final (offset, size) = positioning;
                      rect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
                    }
                    return ClipPath(
                      clipper: ShapeClipper(shape: e.$1, rectOverride: rect),
                      child: child,
                    );
                  },
                );
              }
              result = Positioned.fill(child: result);
            }

            return result;
          },
        );
      },
    );
  }

  void onRemoveAnimationEnd() {
    provider._removeHost(widget.host);
  }
}

class TooltipHoverStatus {
  bool host;
  bool client;
  TooltipHoverStatus({
    this.host = false,
    this.client = false,
  });
}
