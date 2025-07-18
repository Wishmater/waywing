import 'package:flutter/material.dart';
import 'package:waywing/core/config.dart';
import 'package:waywing/util/popup_utils.dart';
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
    final popoverWidgets = <Widget>[];
    for (final host in activeHosts) {
      final Key key;
      if (host.widget.containerId != null) {
        containerGlobalKeys[host.widget.containerId!] ??= GlobalKey();
        key = containerGlobalKeys[host.widget.containerId!]!;
      } else {
        key = ValueKey(host);
      }
      popoverWidgets.add(
        _WingedPopoverClient(
          host: host,
          key: key,
        ),
      );
    }
    return Stack(
      children: [
        widget.child,
        ...popoverWidgets,
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
  State<_WingedPopoverClient> createState() => __WingedPopoverClientState();
}

class __WingedPopoverClientState extends State<_WingedPopoverClient> {
  // @override
  // void didUpdateWidget(covariant _WingedPopoverClient oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.host != widget.host) {}
  // }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final (hostPosition, hostSize) = widget.host.getPositioning();
    print('-----------------------------------');
    print('hostSize: $hostSize');
    print('hostPosition: $hostPosition');
    final childConstraints = widget.host.widget.popoverConstraints;
    // TODO: 1 get actual child size
    // this is of course only possible after 1st frame, until then use this default
    final childSize = Size(childConstraints.maxWidth, childConstraints.maxHeight);
    print('childSize: $childSize');
    final padding = widget.host.widget.screenPadding;
    final childPosition = getPopoverPosition(
      anchorAlignment: Alignment.centerLeft,
      popupAlignment: Alignment.centerLeft,
      hostPosition: hostPosition,
      hostSize: hostSize,
      childSize: childSize,
      screenSize: screenSize,
      padding: padding,
    );
    print('childPosition: $childPosition');
    return AnimatedPositioned(
      duration: config.animationDuration,
      curve: config.animationCurve,
      left: childPosition.dx,
      top: childPosition.dy,
      width: childSize.width,
      height: childSize.height,
      child: OverflowBox(
        minWidth: childConstraints.minWidth,
        maxWidth: childConstraints.maxWidth,
        minHeight: childConstraints.minHeight,
        maxHeight: childConstraints.maxHeight,
        // TODO: 3 maybe allow the host to decide this
        alignment: Alignment.center,
        // TODO: 2 add animation transition to the child (for cases with containerId)
        // maybe allow host to decide the transitionBuilder, so the bar can animate up/down
        child: widget.host.widget.popoverBuilder(context),
      ),
    );
  }
}
