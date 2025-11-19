import "dart:math";

import "package:dartx/dartx.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:motor/motor.dart";
// import "package:waywing/core/config.dart";
import "package:waywing/widgets/motion_widgets/motion_positioned.dart";
import "../searchopts.dart";

// TODO: 2 migrate this to use Motion, hard because some logic depends on duration
const animationDuration = Duration(milliseconds: 250);

class StackOptionsListWidget<T extends Object> extends StatefulWidget {
  final List<Option<T>> options;
  final RenderOption<T> renderOption;
  final double itemHeight;
  final List<Option<T>> filtered;
  final Widget? prototypeItem;
  final ValueNotifier<int> highlighted;
  final double availableHeight;
  final bool showScrollBar;
  // TODO 3: do we need more motions?
  final Motion motion;

  const StackOptionsListWidget({
    required this.options,
    required this.renderOption,
    required this.itemHeight,
    required this.filtered,
    required this.prototypeItem,
    required this.highlighted,
    required this.availableHeight,
    required this.showScrollBar,
    required this.motion,
    super.key,
  });

  @override
  State<StackOptionsListWidget<T>> createState() => _StackOptionsListWidgetState<T>();
}

class _StackOptionsListWidgetState<T extends Object> extends State<StackOptionsListWidget<T>>
    implements OptionsListRenderer {
  late int focusableItemCount = (widget.availableHeight / widget.itemHeight).floor();
  late int visibleItemCount = focusableItemCount + 1;

  int startingIndex = 0;
  final items = <_Item<T>>{};

  @override
  Widget build(BuildContext context) {
    final visibleItems = getVisibleItems();
    final toRemove = <_Item<T>>[];
    for (final e in items) {
      if (e.timeRemoved != null) {
        if (DateTime.now().difference(e.timeRemoved!) > animationDuration) {
          toRemove.add(e);
        }
      } else if (!visibleItems.any((i) => e.option.identifier == i.identifier)) {
        e.timeRemoved = DateTime.now();
      }
    }
    items.removeAll(toRemove);
    for (int i = getRenderStart(); i < getRenderEnd(); i++) {
      final e = widget.filtered[i];
      final item = items.firstOrNullWhere((item) => item.option == e);
      if (item != null) {
        item.index = i;
        item.timeRemoved = null;
      } else {
        items.add(
          _Item(
            index: i,
            option: e,
          ),
        );
      }
    }

    final sortedItems = items.toList()
      ..sort((a, b) {
        if (a.timeRemoved == null && b.timeRemoved != null) return 1;
        if (a.timeRemoved != null && b.timeRemoved == null) return -1;
        return a.index.compareTo(b.index);
      });
    final stackChildren = <Widget>[];
    int visibleAndNotRemovedItemCount = 0;
    for (final item in sortedItems) {
      final isVisible = item.timeRemoved == null && isItemAtLeastPartiallyVisible(item.index);
      if (isVisible && item.timeRemoved == null) {
        visibleAndNotRemovedItemCount++;
      }
      stackChildren.add(
        ValueListenableBuilder(
          key: item.globalKey,
          valueListenable: widget.highlighted,
          builder: (context, value, child) {
            return MotionPositioned(
              motion: widget.motion,
              left: 0,
              right: 0,
              top: widget.itemHeight * (item.index - startingIndex),
              child: _ItemAnimation(
                isItemVisible: isVisible,
                isItemRemoved: item.timeRemoved != null,
                motion: widget.motion,
                child: widget.renderOption(
                  context,
                  item.option.object,
                  SearchOptionsRenderConfig(isHighlighted: value == item.index),
                ),
              ),
            );
          },
        ),
      );
    }

    final highlightedChildBackground = ValueListenableBuilder(
      valueListenable: widget.highlighted,
      builder: (context, value, child) {
        return AnimatedPositioned(
          duration: animationDuration * 0.66,
          curve: Curves.easeOutCubic,
          top: widget.itemHeight * (value - startingIndex),
          height: widget.itemHeight,
          left: 0,
          right: 0,
          child: child!,
        );
      },
      child: ColoredBox(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)),
    );

    final focusableHeight = focusableItemCount * widget.itemHeight;
    double visiplePerc = focusableItemCount / widget.filtered.length;
    if (visiplePerc > 1) {
      visiplePerc = 1;
    }
    double startingPerc = startingIndex / widget.filtered.length;
    if (startingPerc.isNaN) {
      startingPerc = 0;
    }
    final areAllItemsVisible = widget.filtered.length <= focusableItemCount;
    const scrollbarWidth = 3.0;
    final scrollbar = switch (widget.showScrollBar) {
      true => MotionPositioned(
        motion: widget.motion,
        top: focusableHeight * startingPerc,
        height: focusableHeight * visiplePerc,
        right: 0,
        width: scrollbarWidth,
        child: AnimatedOpacity(
          duration: animationDuration,
          curve: Curves.easeOutCubic,
          opacity: areAllItemsVisible ? 0 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(scrollbarWidth)),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
      false => null,
    };

    final children = [
      highlightedChildBackground,
      ...stackChildren,
    ];
    if (scrollbar != null) {
      children.add(scrollbar);
    }
    return Listener(
      onPointerSignal: onPointerSignal,
      onPointerPanZoomUpdate: onPanUpdate,
      // TODO 2: use MotionContainer
      child: AnimatedContainer(
        height: min(widget.availableHeight, widget.itemHeight * visibleAndNotRemovedItemCount),
        duration: animationDuration,
        curve: Curves.easeOutCubic,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: children,
        ),
      ),
    );
  }

  int getRenderStart() => max(0, startingIndex - 1);
  int getRenderEnd() => min((startingIndex + focusableItemCount + 2), widget.filtered.length);
  List<Option<T>> getVisibleItems() => widget.filtered.sublist(
    getRenderStart(),
    getRenderEnd(),
  );

  @override
  bool isItemVisible(int index) {
    final lastVisibleItem = startingIndex + focusableItemCount;
    return index >= startingIndex && index < lastVisibleItem;
  }

  bool isItemAtLeastPartiallyVisible(int index) {
    final lastVisibleItem = startingIndex + visibleItemCount;
    return index >= startingIndex && index < lastVisibleItem;
  }

  @override
  void scrollTo(int index, ScrollDirection direction) {
    if (isItemVisible(index)) {
      return;
    }
    index = switch (direction) {
      ScrollDirection.idle => index - ((focusableItemCount - 1) / 2).ceil(),
      ScrollDirection.forward => index - (focusableItemCount - 1),
      ScrollDirection.reverse => index,
    };
    if (index < 0) {
      index = 0;
    }
    final lastStartingItem = widget.filtered.length - focusableItemCount;
    if (index > lastStartingItem) {
      index = lastStartingItem;
    }
    if (index != startingIndex) {
      setState(() {
        startingIndex = index;
      });
    }
  }

  Offset _pan = Offset.zero;
  void onPanUpdate(PointerPanZoomUpdateEvent event) {
    _pan += event.localPanDelta;
    if (_pan.dy.abs() < 30) {
      return;
    }
    _onScrollDelta(-_pan);
    _pan = Offset.zero;
  }

  void onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }
    return _onScrollDelta(event.scrollDelta);
  }

  void _onScrollDelta(Offset scrollDelta) {
    int newHighlight = widget.highlighted.value;
    final multiplier = switch (HardwareKeyboard.instance.isControlPressed) {
      true => 5,
      false => 1,
    };
    ScrollDirection? direction;
    assert(scrollDelta.dy != 0, "unexpected value of 0 in event.scrollDelta.dy");
    if (scrollDelta.dy < 0) {
      direction = ScrollDirection.reverse;
      newHighlight -= 1 * multiplier;
    } else if (scrollDelta.dy > 0) {
      direction = ScrollDirection.forward;
      newHighlight += 1 * multiplier;
    }

    if (newHighlight < 0) {
      newHighlight = 0;
    }
    if (newHighlight >= widget.filtered.length) {
      newHighlight = widget.filtered.length - 1;
    }

    if (newHighlight != widget.highlighted.value) {
      widget.highlighted.value = newHighlight;
      scrollTo(newHighlight, direction!);
    }
  }
}

class _Item<T extends Object> {
  int index;
  Option<T> option;
  DateTime? timeRemoved;
  GlobalKey globalKey;
  _Item({
    required this.index,
    required this.option,
  }) : globalKey = GlobalKey();

  @override
  int get hashCode => option.hashCode;
  @override
  bool operator ==(Object other) {
    if (other is! _Item<T>) {
      return false;
    }
    return other.option == option;
  }
}

class _ItemAnimation<T extends Object> extends StatefulWidget {
  final bool isItemVisible;
  final bool isItemRemoved;
  final Motion motion;
  final Widget child;

  const _ItemAnimation({
    required this.isItemVisible,
    required this.isItemRemoved,
    required this.child,
    required this.motion,
    super.key,
  });

  @override
  State<_ItemAnimation> createState() => _ItemAnimationState();
}

class _ItemAnimationState extends State<_ItemAnimation> with TickerProviderStateMixin {
  late SingleMotionController opacityAnimationController;
  // TODO: 2 ANIMATIONS this should be a MotionController with a OffsetConverter
  late SingleMotionController translationAnimationController;
  late Animation<Offset> translationAnimation;

  @override
  void initState() {
    super.initState();
    opacityAnimationController = SingleMotionController(
      motion: widget.motion,
      initialValue: 0,
      vsync: this,
    );
    translationAnimationController = SingleMotionController(
      motion: widget.motion,
      initialValue: widget.isItemVisible ? 1 : 0.5,
      vsync: this,
    );
    translationAnimation = Tween<Offset>(
      begin: Offset(-0.25, 0),
      end: Offset(0.25, 0),
    ).animate(translationAnimationController);
    if (widget.isItemVisible) {
      opacityAnimationController.animateTo(1);
      translationAnimationController.animateTo(0.5);
    }
  }

  @override
  void didUpdateWidget(covariant _ItemAnimation<Object> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isItemVisible != oldWidget.isItemVisible) {
      opacityAnimationController.animateTo(widget.isItemVisible ? 1 : 0);
    }
    if (widget.isItemRemoved != oldWidget.isItemRemoved) {
      translationAnimationController.animateTo(widget.isItemRemoved ? 0 : 0.5);
    }
    if (widget.isItemRemoved && !oldWidget.isItemRemoved) {
      translationAnimationController.animateTo(0);
    }
  }

  @override
  void dispose() {
    opacityAnimationController.dispose();
    translationAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: translationAnimation,
      child: FadeTransition(
        opacity: opacityAnimationController,
        child: widget.child,
      ),
    );
  }
}
