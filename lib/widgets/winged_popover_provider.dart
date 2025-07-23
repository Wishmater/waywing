import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:waywing/core/config.dart';
import 'package:waywing/util/popup_utils.dart';
import 'package:waywing/util/state_positioning.dart';
import 'package:waywing/widgets/winged_popover.dart';

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
  final Map<String, GlobalKey<WingedPopoverClientState>> containerGlobalKeys = {};
  final Set<WingedPopoverState> activeHosts = {};
  final Set<WingedPopoverState> removedHosts = {};

  void showHost(WingedPopoverState host) {
    assert(!activeHosts.contains(host), 'Trying to register a host that already exists to PopoverProvider.');
    // hide other popovers with the same containerId
    if (host.widget.containerId != null) {
      final toRemove = activeHosts.where((e) => e.widget.containerId == host.widget.containerId).toList();
      toRemove.addAll(removedHosts.where((e) => e.widget.containerId == host.widget.containerId));
      for (final e in toRemove) {
        _removeHost(e);
      }
      if (toRemove.isNotEmpty) {
        containerGlobalKeys[host.widget.containerId]!.currentState!.triggerContentAnimation();
      }
    }
    setState(() {
      activeHosts.add(host);
      host.isShown = true;
    });
  }

  void hideHost(WingedPopoverState host) {
    assert(activeHosts.contains(host), 'Trying to hide a host that doesn\'t exist in PopoverProvider.');
    setState(() {
      activeHosts.remove(host);
      removedHosts.add(host);
      host.isShown = false;
    });
  }

  void _removeHost(WingedPopoverState host) {
    assert(
      activeHosts.contains(host) || removedHosts.contains(host),
      'Trying to remove a host that doesn\'t exist in PopoverProvider.',
    );
    setState(() {
      activeHosts.remove(host);
      removedHosts.remove(host);
      host.isShown = false;
    });
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
    final widgetsBelowMap = <Widget, WingedPopoverState>{};
    final widgetsAboveMap = <Widget, WingedPopoverState>{};
    buildClientWidgets(context, activeHosts, widgetsBelowMap, widgetsAboveMap);
    buildClientWidgets(context, removedHosts, widgetsBelowMap, widgetsAboveMap, isRemoved: true);
    final widgetsBelow = widgetsBelowMap.keys.toList();
    widgetsBelow.sortedBy((e) => widgetsBelowMap[e]!.widget.zIndex);
    final widgetsAbove = widgetsAboveMap.keys.toList();
    widgetsAbove.sortedBy((e) => widgetsAboveMap[e]!.widget.zIndex);
    return Stack(
      children: [
        ...widgetsBelow,
        widget.child,
        ...widgetsAbove,
      ],
    );
  }

  void buildClientWidgets(
    BuildContext context,
    Iterable<WingedPopoverState> hosts,
    Map<Widget, WingedPopoverState> widgetsBelowMap,
    Map<Widget, WingedPopoverState> widgetsAboveMap, {
    bool isRemoved = false,
  }) {
    for (final host in hosts) {
      final Key key;
      if (host.widget.containerId != null) {
        containerGlobalKeys[host.widget.containerId!] ??= GlobalKey();
        key = containerGlobalKeys[host.widget.containerId!]!;
      } else {
        key = ValueKey(host);
      }
      final widget = WingedPopoverClient(
        host: host,
        key: key,
        isRemoved: isRemoved,
      );
      if (host.widget.zIndex < 0) {
        widgetsBelowMap[widget] = host;
      } else {
        widgetsAboveMap[widget] = host;
      }
    }
  }
}

class WingedPopoverClient extends StatefulWidget {
  final WingedPopoverState host;
  final bool isRemoved;

  const WingedPopoverClient({
    required this.host,
    this.isRemoved = false,
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<WingedPopoverClient> createState() => WingedPopoverClientState();
}

class WingedPopoverClientState extends State<WingedPopoverClient> with TickerProviderStateMixin {
  final childPositioningController = PositioningController();

  @override
  void initState() {
    super.initState();
    _buildContentAnimationController();
  }

  late AnimationController contentAnimationController;
  void _buildContentAnimationController() {
    contentAnimationController = AnimationController(
      vsync: this,
      duration: config.animationDuration,
      value: 1,
    );
  }

  void triggerContentAnimation() {
    _buildContentAnimationController();
    contentAnimationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
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
        alignment: widget.host.widget.popupAlignment,
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
              child: widget.host.widget.popoverBuilder(context),
            ),
          ),
        ),
      ),
    );
    final container = widget.host.widget.popoverContainerBuilder(context, content);

    return ValueListenableBuilder(
      valueListenable: widget.host.positioningNotifier,
      child: container,
      builder: (context, hostPositioning, container) {
        if (hostPositioning == null) {
          print('ERROR: Popover client built before host. This should never happen');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
          });
          return SizedBox.shrink();
        }
        final (hostPosition, hostSize) = hostPositioning;
        // print('-----------------------------------');
        // print('hostSize: $hostSize');
        // print('hostPosition: $hostPosition');
        Size childSize;
        Offset childPosition;
        if (widget.isRemoved) {
          childSize = hostSize;
          childPosition = hostPosition;
          if (widget.host.widget.popoverClosedContainerBuilder != null) {
            container = widget.host.widget.popoverClosedContainerBuilder!(context, content);
          }
        } else {
          try {
            childSize = childPositioningController.getPositioning().$2;
            childPosition = getPopoverPosition(
              anchorAlignment: widget.host.widget.anchorAlignment,
              popupAlignment: widget.host.widget.popupAlignment,
              hostPosition: hostPosition,
              hostSize: hostSize,
              childSize: childSize,
              screenSize: screenSize,
              padding: widget.host.widget.screenPadding,
            );
          } catch (_) {
            // assuming this happens the first time the widget builds
            // fall back to setting the size/position of the host,
            // which should have the added effect of animating entry
            childSize = hostSize;
            childPosition = hostPosition;
            if (widget.host.widget.popoverClosedContainerBuilder != null) {
              container = widget.host.widget.popoverClosedContainerBuilder!(context, content);
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {});
            });
          }
        }
        // print('childSize: $childSize');
        // print('childPosition: $childPosition');
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
    final provider = context.findAncestorStateOfType<WingedPopoverProviderState>()!;
    provider._removeHost(widget.host);
  }
}
