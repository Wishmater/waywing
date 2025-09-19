import "dart:async";

import "package:dartx/dartx.dart";
import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:motor/motor.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/animation_utils.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/util/math_utils.dart";
import "package:waywing/util/popup_utils.dart";
import "package:waywing/util/state_positioning.dart";
import "package:waywing/widgets/overflow_or_fit.dart";
import "package:waywing/widgets/motion_widgets/motion_padding.dart";
import "package:waywing/widgets/motion_widgets/motion_positioned.dart";
import "package:waywing/widgets/shapes/shape_clipper.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

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
  final Map<WingedPopoverState, TooltipStatus> tooltipHosts = {};
  final Map<WingedPopoverState, bool> removedHosts = {};

  void showHost(WingedPopoverState host) {
    assert(
      host.widget.popoverParams != null,
      "Trying to show popover for a host that doesn't specify popoverParams",
    );
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
      // _logger.log(Level.warning, "Trying to hide a host that doesn't exist in PopoverProvider.");
      return;
    }
    if (host.clientState?.passedMeaningfulPaint ?? false) {
      // don't bother initializing exit animation if it hasn't reached meaningful paint (which is usually 2 frames)
      removedHosts[host] = isTooltip;
    }
    host.isPopoverShown = false;
    host.isTooltipShown = false;
    // hide all children
    for (final e in [...activeHosts, ...tooltipHosts.keys]) {
      if (e.parent?.widget.host == host) {
        hideHost(e);
      }
    }
    setState(() {});
  }

  void onMouseEnterHost(WingedPopoverState host) {
    showTooltip(host, initialStatus: TooltipStatus(host: true));
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

  Future<void> showTooltip(
    WingedPopoverState host, {
    TooltipStatus? initialStatus,
    Duration? showDelay,
  }) async {
    if (tooltipHosts.containsKey(host)) {
      // _logger.log(Level.warning, "Trying to register a tooltip host that already exists to PopoverProvider.");
      final status = tooltipHosts[host]!;
      status.hideTimer?.cancel();
      status.hideTimer = null;
      return;
    }
    if (activeHosts.contains(host)) {
      return; // ignore tooltip calls if it's already manually shown
    }
    showDelay ??= host.widget.tooltipParams!.showDelay;
    if (showDelay > Duration.zero) {
      final containerId = host.widget.tooltipParams!.containerId;
      final isContainerShown =
          containerId != null &&
          (tooltipHosts.keys.any((e) => e.widget.tooltipParams!.containerId == containerId) ||
              removedHosts.entries.any((e) => e.value && e.key.widget.tooltipParams!.containerId == containerId));
      if (!isContainerShown) {
        final completer = Completer<void>();
        Timer(showDelay, () async {
          if (!host.mounted || !host.isHovered) return;
          await showTooltip(host, showDelay: Duration.zero);
          completer.complete();
        });
        return completer.future;
      }
    }
    if (removedHosts.containsKey(host)) {
      _removeHost(host);
    }
    if (host.widget.tooltipParams!.containerId case final containerId?) {
      _removeAllWithContainerId(containerId);
    }
    final status = initialStatus ?? TooltipStatus();
    tooltipHosts[host] = status;
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
  final Set<WingedPopoverState> _checkHideTooltipScheduledled = {};
  void _scheduleCheckHideTooltip(WingedPopoverState host) {
    if (_checkHideTooltipScheduledled.contains(host)) return;
    _checkHideTooltipScheduledled.add(host);
    // this NEEDS to wait 2 frames for it to be consistent
    WidgetsBinding.instance.scheduleFrame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.scheduleFrame();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        hideTooltip(host);
        _checkHideTooltipScheduledled.remove(host);
      });
    });
  }

  void _checkHideTooltip(WingedPopoverState host) {
    final status = tooltipHosts[host];
    if (status != null && !_getEffectiveIsHovered(host, status)) {
      hideHost(host);
    }
  }

  bool _getEffectiveIsHovered(WingedPopoverState host, TooltipStatus? status) {
    if (status == null) return false;
    if (status.host || status.client) return true;
    for (final e in tooltipHosts.entries) {
      if (e.key.parent?.widget.host != host) continue;
      final isChildHovered = _getEffectiveIsHovered(e.key, e.value);
      if (isChildHovered) return true;
    }
    return false;
  }

  void _removeHost(WingedPopoverState host) {
    // assert(
    //   activeHosts.contains(host) || removedHosts.containsKey(host) || tooltipHosts.containsKey(host),
    //   "Trying to remove a host that doesn't exist in PopoverProvider.",
    // );
    var removed = activeHosts.remove(host);
    removed = removedHosts.remove(host) != null || removed;
    removed = tooltipHosts.remove(host) != null || removed;
    host.isPopoverShown = false;
    host.isTooltipShown = false;
    if (removed) {
      setState(() {});
    }
  }

  void toggleHost(WingedPopoverState host) {
    if (activeHosts.contains(host)) {
      hideHost(host);
    } else {
      showHost(host);
    }
  }

  Future<void> toggleTooltip(WingedPopoverState host, {Duration? showDelay, Duration? hideDelay}) {
    if (tooltipHosts.containsKey(host)) {
      return hideTooltip(host, hideDelay: hideDelay);
    } else {
      return showTooltip(host, showDelay: showDelay);
    }
  }

  Future<void> hideTooltip(WingedPopoverState host, {Duration? hideDelay}) async {
    if (activeHosts.contains(host)) {
      return; // if popover is shown, ignore hideTooltip call
    }
    hideDelay ??= host.widget.tooltipParams!.hideDelay;
    final status = tooltipHosts[host];
    if (status != null && hideDelay > Duration.zero) {
      status.hideTimer?.cancel();
      final completer = Completer<void>();
      status.hideTimer = Timer(hideDelay, () {
        _checkHideTooltip(host);
        completer.complete();
      });
      return completer.future;
    }
    hideHost(host);
  }

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
    final widgetsBelow = widgetsBelowMap.keys.sortedBy((e) => widgetsBelowMap[e]!);
    final widgetsAbove = widgetsAboveMap.keys.sortedBy((e) => widgetsAboveMap[e]!);
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

  late final focusNode = FocusScopeNode();

  late BoundedSingleMotionController contentOpacityMotionController;
  late MotionController<Offset> contentOffsetMotionController;
  final List<_OutgoingChild> _outgoingChildren = [];

  PopoverParams get popoverParams =>
      (widget.isTooltip ? widget.host.widget.tooltipParams : widget.host.widget.popoverParams)!;

  Motion get motion => popoverParams.motion ?? mainConfig.motions.expressive.spatial.slow;

  @override
  void initState() {
    super.initState();
    _initContentAnimations(initialOpacity: 1, initialOffset: Offset.zero);
    if (!widget.isTooltip) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        focusNode.requestFocus();
      });
    }
  }

  void _initContentAnimations({
    required double initialOpacity,
    required Offset initialOffset,
  }) {
    final motion = this.motion;
    contentOpacityMotionController = BoundedSingleMotionController(
      motion: motion,
      vsync: this,
      initialValue: initialOpacity,
      lowerBound: 0,
      upperBound: 1,
    );
    contentOffsetMotionController = MotionController(
      motion: motion,
      vsync: this,
      converter: OffsetMotionConverter(),
      initialValue: initialOffset,
    );
    if (!widget.isTooltip) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    contentOpacityMotionController.dispose();
    contentOffsetMotionController.dispose();
    for (final e in _outgoingChildren) {
      e.opacityMotionController.dispose();
      e.offsetMotionController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WingedPopoverClient oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.host != oldWidget.host || widget.isTooltip != oldWidget.isTooltip) {
      _triggerContentAnimation(oldWidget.host);
    }
  }

  late Widget _lastContent;
  void _triggerContentAnimation(WingedPopoverState oldHost) {
    Offset? targetContentOffset;
    final newHostPositioning = widget.host.positioningNotifier.value;
    final oldChildPositioning = childPositioningController.positioningNotifier.value;
    if (newHostPositioning != null && oldChildPositioning != null) {
      final popoverParams = this.popoverParams;
      final oldChildSize = oldChildPositioning.size;
      final oldChildOffset = oldChildPositioning.offset;
      final newChildSize = oldChildSize; // there is no way of getting the new size at this point
      var newChildOffset = getPopoverPosition(
        anchorAlignment: popoverParams.anchorAlignment,
        popupAlignment: popoverParams.popupAlignment,
        hostPosition: newHostPositioning.offset,
        hostSize: newHostPositioning.size,
        childSize: newChildSize,
        screenSize: MediaQuery.sizeOf(context),
        padding: popoverParams.screenPadding,
        extraOffset: popoverParams.extraOffset,
      );
      newChildOffset += Offset(
        popoverParams.extraPadding.horizontal,
        popoverParams.extraPadding.vertical,
      );
      final oldChildCenter = Offset(
        oldChildOffset.dx + oldChildSize.width / 2,
        oldChildOffset.dy + oldChildSize.height / 2,
      );
      final newChildCenter = Offset(
        newChildOffset.dx + newChildSize.width / 2,
        newChildOffset.dy + newChildSize.height / 2,
      );
      targetContentOffset = newChildCenter - oldChildCenter;
      targetContentOffset *= 0.75;
      final maxContentOffset = Offset(
        newChildSize.width * targetContentOffset.dx.sign * 0.75,
        newChildSize.height * targetContentOffset.dy.sign * 0.75,
      );
      targetContentOffset = Offset(
        minAbs(targetContentOffset.dx, maxContentOffset.dx),
        minAbs(targetContentOffset.dy, maxContentOffset.dy),
      );
      if (mainConfig.animationSwitching == AnimationSwitching.slide) {
        final minChildSize = oldChildSize > newChildSize ? newChildSize : oldChildSize;
        final horizontalDiffPerc = (targetContentOffset.dx / minChildSize.width).abs();
        final verticalDiffPerc = (targetContentOffset.dy / minChildSize.height).abs();
        if (horizontalDiffPerc < 1 && verticalDiffPerc < 1) {
          if (horizontalDiffPerc > verticalDiffPerc) {
            targetContentOffset = Offset(minChildSize.width * targetContentOffset.dx.sign, targetContentOffset.dy);
          } else {
            targetContentOffset = Offset(targetContentOffset.dx, minChildSize.height * targetContentOffset.dy.sign);
          }
        }
      }
    }

    // make the outgoing opacity animation faster, so it doesn't interfere with
    // user reading the incoming content
    final currentMotion = contentOpacityMotionController.motion;
    if (currentMotion is MaterialSpringMotion) {
      contentOpacityMotionController.motion = currentMotion.copyWith(stiffness: currentMotion.stiffness * 2);
    }
    final outgoingChild = _OutgoingChild(
      widget: _lastContent,
      opacityMotionController: contentOpacityMotionController,
      offsetMotionController: contentOffsetMotionController,
    );
    outgoingChild.opacityMotionController.reverse();
    if (targetContentOffset != null) {
      outgoingChild.offsetMotionController.animateTo(targetContentOffset * -1);
    }
    _initContentAnimations(
      initialOpacity: 0,
      initialOffset: targetContentOffset ?? Offset.zero,
    );
    contentOpacityMotionController.forward();
    if (targetContentOffset != null) {
      contentOffsetMotionController.animateTo(Offset.zero);
    }
    _outgoingChildren.add(outgoingChild);
    contentOpacityMotionController.addStatusListener((status) {
      if (!mounted) return;
      if (!status.isAnimating) {
        setState(() {
          outgoingChild.opacityMotionController.dispose();
          outgoingChild.offsetMotionController.dispose();
          _outgoingChildren.remove(outgoingChild);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRemoved && !passedMeaningfulPaint) {
      // this should never happen, because provider checks this and insta-removes if needed, but just in case...
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider._removeHost(widget.host);
      });
      return SizedBox.shrink();
    }
    final popoverParams = this.popoverParams;
    widget.host.clientState = this;
    final screenSize = MediaQuery.sizeOf(context);

    _lastContent = popoverParams.builder(context, widget.host, childPositioningController);
    final currentContent = OverflowOrFit(
      alignment: popoverParams.overflowAlignment,
      child: AnimatedBuilder(
        animation: Listenable.merge([contentOpacityMotionController, contentOffsetMotionController]),
        builder: (context, child) {
          return Opacity(
            opacity: contentOpacityMotionController.value.clamp(0, 1),
            child: Transform.translate(
              offset: contentOffsetMotionController.value,
              child: child!,
            ),
          );
        },
        child: FocusScope(
          node: focusNode,
          child: PositioningNotifierMonitor(
            controller: childPositioningController,
            child: _lastContent,
          ),
        ),
      ),
    );

    final content = Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        for (final e in _outgoingChildren)
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeFocus(
                child: OverflowOrFit(
                  alignment: popoverParams.overflowAlignment,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([e.opacityMotionController, e.offsetMotionController]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: e.opacityMotionController.value.clamp(0, 1),
                        child: Transform.translate(
                          offset: e.offsetMotionController.value,
                          transformHitTests: false,
                          child: child!,
                        ),
                      );
                    },
                    child: e.widget,
                  ),
                ),
              ),
            ),
          ),
        IgnorePointer(
          ignoring: widget.isRemoved,
          child: ExcludeFocus(
            excluding: widget.isRemoved,
            child: currentContent,
          ),
        ),
      ],
    );

    final container = popoverParams.containerBuilder(context, widget.host, content);

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
            final hostPosition = hostPositioning.offset;
            final hostSize = hostPositioning.size;
            // print("-----------------------------------");
            // print("hostSize: $hostSize");
            // print("hostPosition: $hostPosition");
            Offset childPosition;
            if (widget.isRemoved) {
              childSize = hostSize;
              childPosition = hostPosition;
              if (popoverParams.closedContainerBuilder != null) {
                container = popoverParams.closedContainerBuilder!(context, widget.host, content);
              }
            } else if (childSize == null) {
              // assuming this happens the first time the widget builds
              // fall back to setting the size/position of the host,
              // which should have the added effect of animating entry
              childSize = hostSize;
              childPosition = hostPosition;
              if (popoverParams.closedContainerBuilder != null) {
                container = popoverParams.closedContainerBuilder!(context, widget.host, content);
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
            final motion = this.motion;
            container = MotionPadding(
              motion: motion,
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

            Widget result = CallbackShortcuts(
              bindings: {
                SingleActivator(LogicalKeyboardKey.escape): () {
                  if (widget.isTooltip) {
                    if (widget.host.isTooltipShown) {
                      widget.host.hideTooltip();
                    }
                  } else {
                    if (widget.host.isPopoverShown) {
                      widget.host.hidePopover();
                    }
                  }
                },
              },
              child: container,
            );
            // print("childSize: $childSize");
            // print("childPosition: $childPosition");
            double? minLeft, maxLeft, minTop, maxTop, minRight, maxRight, minBottom, maxBottom;
            if (popoverParams.stickToHost) {
              if (popoverParams.popupAlignment.x < 0) {
                minRight = hostPosition.dx;
              } else if (popoverParams.popupAlignment.x > 0) {
                maxLeft = hostPosition.dx + hostSize.width;
              }
              if (popoverParams.popupAlignment.y < 0) {
                minBottom = hostPosition.dy;
              } else if (popoverParams.popupAlignment.y > 0) {
                maxTop = hostPosition.dy + hostSize.height;
              }
            }
            result = MotionPositioned(
              // TODO: 2 ANIMATIONS ideally, we separate animation for the container and the content,
              // so that the content doesn't "bounce around" like the container does.
              // This seems hard to do, because the motion controller doesn't expose when the animation
              // reached the target and is now "bouncing".
              // An alternative is to add container and content as separate MotionPositioned widgets,
              // but this is ugly and has risk of causing other bugs like desync and clipping issues.
              motion: motion,
              left: childPosition.dx,
              top: childPosition.dy,
              // TODO: 1 ANIMATIONS maybe we should stop animationg width/height changes when not animating
              // in/out and just leave that as the content's responsibility to implement. If implemented in
              // the content, animations can be more custom and exact, and if implemented both here and in
              // content, it can have weird interactions (which happens now). We should also stop animationg
              // position so it "sticks" to the host if the host moves
              // (maybe leave both of tjese as separate options)
              width: childSize.width,
              height: childSize.height,
              minLeft: minLeft,
              maxLeft: maxLeft,
              minTop: minTop,
              maxTop: maxTop,
              minRight: minRight,
              maxRight: maxRight,
              minBottom: minBottom,
              maxBottom: maxBottom,
              onAnimationStatusChanged: !widget.isRemoved
                  ? null
                  : (status) {
                      if (!status.isAnimating) {
                        provider._removeHost(widget.host);
                      }
                    },
              child: result,
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
                      final offset = positioning.offset;
                      final size = positioning.size;
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
}

class TooltipStatus {
  bool host;
  bool client;
  Timer? hideTimer;
  TooltipStatus({
    this.host = false,
    this.client = false,
    this.hideTimer,
  });
}

class _OutgoingChild {
  final BoundedSingleMotionController opacityMotionController;
  final MotionController<Offset> offsetMotionController;
  final Widget widget;
  _OutgoingChild({
    required this.opacityMotionController,
    required this.offsetMotionController,
    required this.widget,
  });
}
