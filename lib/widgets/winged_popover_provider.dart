import "package:dartx/dartx.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/popup_utils.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/winged_popover.dart";

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
      print("ERROR: Trying to register a host that already exists to PopoverProvider.");
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
      print(
        "ERROR: Trying to hide a host that doesn't exist in PopoverProvider.",
      );
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
      print("ERROR: Trying to register a tooltip host that already exists to PopoverProvider.");
      return;
    }
    if (activeHosts.contains(host)) {
      return; // ignore tooltip calls if it's already manually shown
    }
    if (removedHosts.containsKey(host)) {
      _removeHost(host);
    }
    // TODO: 1 implement containerIds for tooltips
    // TODO: 1 add delay to showint tooltip after entering host (param passed to the host)
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
    if (toRemove.isNotEmpty) {
      containerGlobalKeys[containerId]!.currentState!.triggerContentAnimation();
    }
  }

  // necessary because when mouse goes from host to client, if we check immediately
  // it will be removed because it goes out of the host before going into the client
  void _scheduleCheckHideTooltip(WingedPopoverState host) {
    if (_isCheckHideTooltipScheduled) return;
    _isCheckHideTooltipScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkHideTooltip(host);
      _isCheckHideTooltipScheduled = false;
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
  final childPositioningController = PositioningController();

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
    super.dispose();
    contentAnimationController.dispose();
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

  // TODO: 1 make this trigget in didUpdateWidget when host or isTooltip changes,
  // instead of being manually triggered by provider
  void triggerContentAnimation() {
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
        child: PositioningMonitor(
          controller: childPositioningController,
          child: NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (_) {
              // rebuild when the child size changes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {});
              });
              return true;
            },
            child: SizeChangedLayoutNotifier(
              child: popoverParams.builder(context),
            ),
          ),
        ),
      ),
    );
    final container = popoverParams.containerBuilder(context, content);

    return ValueListenableBuilder(
      valueListenable: widget.host.positioningNotifier,
      child: container,
      builder: (context, hostPositioning, container) {
        if (hostPositioning == null) {
          print("ERROR: Popover client built before host. This should never happen");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
          });
          return SizedBox.shrink();
        }
        final (hostPosition, hostSize) = hostPositioning;
        // print("-----------------------------------");
        // print("hostSize: $hostSize");
        // print("hostPosition: $hostPosition");
        Size childSize;
        Offset childPosition;
        if (widget.isRemoved) {
          childSize = hostSize;
          childPosition = hostPosition;
          if (popoverParams.closedContainerBuilder != null) {
            container = popoverParams.closedContainerBuilder!(context, content);
          }
        } else {
          try {
            childSize = childPositioningController.getPositioning().$2;
            childPosition = getPopoverPosition(
              anchorAlignment: popoverParams.anchorAlignment,
              popupAlignment: popoverParams.popupAlignment,
              hostPosition: hostPosition,
              hostSize: hostSize,
              childSize: childSize,
              screenSize: screenSize,
              padding: popoverParams.screenPadding,
            );
            passedMeaningfulPaint = true;
          } catch (_) {
            // assuming this happens the first time the widget builds
            // fall back to setting the size/position of the host,
            // which should have the added effect of animating entry
            childSize = hostSize;
            childPosition = hostPosition;
            if (popoverParams.closedContainerBuilder != null) {
              container = popoverParams.closedContainerBuilder!(context, content);
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {});
            });
          }
        }
        if (widget.isTooltip) {
          container = MouseRegion(
            onEnter: (_) => provider.onMouseEnterClient(this),
            onExit: (_) => provider.onMouseExitClient(this),
            child: container,
          );
        }
        // print("childSize: $childSize");
        // print("childPosition: $childPosition");
        return AnimatedPositioned(
          duration: config.animationDuration,
          curve: config.animationCurve,
          left: childPosition.dx,
          top: childPosition.dy,
          width: childSize.width,
          height: childSize.height,
          onEnd: !widget.isRemoved ? null : onRemoveAnimationEnd,
          child: container!,
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
