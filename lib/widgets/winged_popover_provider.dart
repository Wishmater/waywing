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
  final Map<String, GlobalKey> containerGlobalKeys = {};
  final Set<WingedPopoverState> activeHosts = {};

  void showHost(WingedPopoverState host) {
    assert(!activeHosts.contains(host), 'Trying to register host that already exists to PopoverProvider.');
    // hide other popovers with the same containerId
    if (host.widget.containerId != null) {
      final toRemove = activeHosts.where((e) => e.widget.containerId == host.widget.containerId).toList();
      for (final e in toRemove) {
        hideHost(e);
      }
    }
    setState(() {
      activeHosts.add(host);
      host.isShown = true;
    });
  }

  void hideHost(WingedPopoverState host) {
    assert(activeHosts.contains(host), 'Trying to unregister that doesn\'t exist in PopoverProvider.');
    setState(() {
      activeHosts.remove(host);
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

  @override
  Widget build(BuildContext context) {
    final widgetsBelowMap = <Widget, WingedPopoverState>{};
    final widgetsAboveMap = <Widget, WingedPopoverState>{};
    for (final host in activeHosts) {
      final Key key;
      if (host.widget.containerId != null) {
        containerGlobalKeys[host.widget.containerId!] ??= GlobalKey();
        key = containerGlobalKeys[host.widget.containerId!]!;
      } else {
        key = ValueKey(host);
      }
      final widget = _WingedPopoverClient(
        host: host,
        key: key,
      );
      if (host.widget.zIndex < 0) {
        widgetsBelowMap[widget] = host;
      } else {
        widgetsAboveMap[widget] = host;
      }
    }
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
}

class _WingedPopoverClient extends StatefulWidget {
  final WingedPopoverState host;

  const _WingedPopoverClient({
    required this.host,
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<_WingedPopoverClient> createState() => _WingedPopoverClientState();
}

class _WingedPopoverClientState extends State<_WingedPopoverClient> {
  final childPositioningController = PositioningController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final padding = widget.host.widget.screenPadding;
    // TODO: 1 somehow get notified to update when host positioning (offset or size) changes
    final (hostPosition, hostSize) = widget.host.getPositioning();
    // print('-----------------------------------');
    // print('hostSize: $hostSize');
    // print('hostPosition: $hostPosition');

    Size childSize;
    Offset childPosition;
    try {
      childSize = childPositioningController.getPositioning().$2;
      childPosition = getPopoverPosition(
        anchorAlignment: widget.host.widget.anchorAlignment,
        popupAlignment: widget.host.widget.popupAlignment,
        hostPosition: hostPosition,
        hostSize: hostSize,
        childSize: childSize,
        screenSize: screenSize,
        padding: padding,
      );
    } catch (_) {
      // assuming this happens the first time the widget builds
      // fall back to setting the size/position of the host,
      // which should have the added effect of animating entry
      childSize = hostSize;
      childPosition = hostPosition;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
    // print('childSize: $childSize');
    // print('childPosition: $childPosition');

    final content = OverflowBox(
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
    );
    final container = widget.host.widget.popoverContainerBuilder(
      context,
      content,
    );
    return AnimatedPositioned(
      duration: config.animationDuration,
      curve: config.animationCurve,
      left: childPosition.dx,
      top: childPosition.dy,
      width: childSize.width,
      height: childSize.height,
      child: container,
    );
  }
}
