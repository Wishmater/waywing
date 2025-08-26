import "dart:ui";

import "package:flutter/widgets.dart";

typedef ItemBuilder<T> = Widget Function(BuildContext context, T data);
typedef ItemTransitionBuilder<T> =
    Widget Function(BuildContext context, T data, Widget child, Animation<double> animation);
typedef LayoutBuilder<T> = Widget Function(BuildContext context, List<Widget> items);

class AnimatedLayout<T> extends StatefulWidget {
  /// T must implement equals and hashCode properly
  final List<T> data;
  final ItemBuilder<T> itemBuilder;
  final LayoutBuilder<T> layoutBuilder;
  final ItemTransitionBuilder<T> transitionBuilder;
  final Duration duration;
  final Curve? curve;

  /// Add a GlobalKey to each item. This has a performance impact and could have some issues,
  /// but it allows the child state to live permanently through list order changes,
  /// this allows to more easily implement consistent implicit animations when the child internals themselves change.
  final bool addGlobalKeys;

  const AnimatedLayout({
    required this.data,
    required this.itemBuilder,
    required this.layoutBuilder,
    required this.transitionBuilder,
    required this.duration,
    this.curve,
    this.addGlobalKeys = true,
    super.key,
  });

  @override
  State<AnimatedLayout<T>> createState() => _AnimatedLayoutState<T>();
}

class _AnimatedLayoutState<T> extends State<AnimatedLayout<T>> with TickerProviderStateMixin {
  late final Map<T, AnimationValues> incomingItems = {};
  late final Map<T, AnimationValues> outgoingItems = {};
  late final Map<T, MovingAnimationValues> movingItems = {};
  late final Map<T, GlobalKey> itemKeys = {};

  @override
  void dispose() {
    for (final e in incomingItems.values) {
      e.animationController.dispose();
    }
    for (final e in outgoingItems.values) {
      e.animationController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedLayout<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final List<int> removedOriginalIndices = [];
    for (int i = 0; i < oldWidget.data.length; i++) {
      final e = oldWidget.data[i];
      if (!widget.data.contains(e)) {
        removedOriginalIndices.add(i);
        addOutgoingItem(e, i);
      }
    }
    int addedItemsCount = 0;
    for (int i = 0; i < widget.data.length; i++) {
      final e = widget.data[i];
      final oldIndex = oldWidget.data.indexOf(e);
      if (oldIndex < 0) {
        addIncomingItem(e, i);
        addedItemsCount++;
      } else if (widget.addGlobalKeys) {
        // not supported without global keys
        final removedOriginalItemsCount = _getRemovedItemsCountUpToIndex(removedOriginalIndices, oldIndex);
        final oldIndexAdjusted = oldIndex + addedItemsCount - removedOriginalItemsCount;
        if (oldIndexAdjusted != i) {
          // item moved (changed index)
          if (!outgoingItems.containsKey(e)) {
            addOutgoingItem(e, oldIndexAdjusted);
          }
          // TODO: 1 what happens if the item is already moving? (incoming or outcoming should be fine) -- also what happens if the item is removed while its being moved
          addMovingItem(e, i, oldIndexAdjusted);
        }
      }
    }
  }

  int _getRemovedItemsCountUpToIndex(List<int> removedOriginalIndices, int oldIndex) {
    for (int i = 0; i < removedOriginalIndices.length; i++) {
      if (removedOriginalIndices[i] >= oldIndex) {
        return i;
      }
    }
    return removedOriginalIndices.length;
  }

  void addIncomingItem(T e, int index) {
    final anim = outgoingItems.remove(e) ?? initAnimationValues(AnimationValues(), true, index);
    anim.animationController.forward().whenComplete(() {
      if (!mounted) return;
      setState(() {
        anim.animationController.dispose();
        incomingItems.remove(e);
      });
    });
    incomingItems[e] = anim;
  }

  void addOutgoingItem(T e, int index) {
    final anim = incomingItems.remove(e) ?? initAnimationValues(AnimationValues(), false, index);
    anim.animationController.reverse().whenComplete(() {
      if (!mounted) return;
      setState(() {
        anim.animationController.dispose();
        outgoingItems.remove(e);
        itemKeys.remove(e);
      });
    });
    outgoingItems[e] = anim;
  }

  void addMovingItem(T e, int index, int originalIndex) {
    final anim = initAnimationValues(MovingAnimationValues(), true, index);
    anim.originalIndex = originalIndex;
    anim.originalPositioning = getPositioningForItem(e)!;
    anim.animationController.forward().whenComplete(() {
      if (!mounted) return;
      setState(() {
        anim.animationController.dispose();
        movingItems.remove(e);
      });
    });
    movingItems[e] = anim;
  }

  A initAnimationValues<A extends AnimationValues>(A anim, bool isIncoming, int index) {
    anim.index = index;
    anim.animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: isIncoming ? 0 : 1,
    );
    if (widget.curve != null) {
      anim.animation = CurvedAnimation(
        parent: anim.animationController,
        curve: widget.curve!,
        reverseCurve: FlippedCurve(widget.curve!),
      );
    } else {
      anim.animation = anim.animationController;
    }
    return anim;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];
    final List<Widget> overlays = [];

    for (final e in widget.data) {
      Widget item = widget.itemBuilder(context, e);
      final incomingAnim = incomingItems[e];
      if (incomingAnim != null) {
        item = addGlobalKey(context, e, item);
        item = widget.transitionBuilder(context, e, item, incomingAnim.animation);
      } else {
        final movingAnim = movingItems[e];
        if (movingAnim != null) {
          // original item is added to overlay and a sized proxy is added to main list instead
          overlays.add(buildMovingTransition(movingAnim, e, item));
          final positioning = getPositioningForItem(e);
          item = buildProxiedSizedBox(e, positioning?.$2 ?? movingAnim.originalPositioning.$2);
          item = addGlobalKey(context, e, item);
          item = widget.transitionBuilder(context, e, item, movingAnim.animation);
        } else {
          item = addGlobalKey(context, e, item);
        }
      }
      items.add(item);
    }

    final outgoingEntries = outgoingItems.entries.toList();
    for (int i = 0; i < outgoingItems.length; i++) {
      final entry = outgoingEntries[i];
      final e = entry.key;
      final outgoingAnim = entry.value;
      Widget item;
      final movingAnim = movingItems[e];
      if (movingAnim != null) {
        item = buildProxiedSizedBox(e, movingAnim.originalPositioning.$2);
      } else {
        item = widget.itemBuilder(context, e);
        item = addGlobalKey(context, e, item);
      }
      item = widget.transitionBuilder(context, e, item, outgoingAnim.animation);
      items.insert(outgoingAnim.index.clamp(0, items.length), item);
    }

    return Stack(
      children: [
        widget.layoutBuilder(context, items),
        ...overlays,
      ],
    );
  }

  AnimatedBuilder buildMovingTransition(MovingAnimationValues movingAnim, T e, Widget item) {
    return AnimatedBuilder(
      animation: movingAnim.animation,
      child: item,
      builder: (context, child) {
        final positioning = getPositioningForItem(e);
        final left = positioning == null
            ? movingAnim.originalPositioning.$1.dx
            : lerpDouble(
                movingAnim.originalPositioning.$1.dx,
                positioning.$1.dx,
                movingAnim.animation.value,
              );
        final top = positioning == null
            ? movingAnim.originalPositioning.$1.dy
            : lerpDouble(
                movingAnim.originalPositioning.$1.dy,
                positioning.$1.dy,
                movingAnim.animation.value,
              );
        var opacityValue = movingAnim.animation.value;
        if (opacityValue < 0.5) {
          opacityValue = 1 - opacityValue * 2;
        } else {
          opacityValue = 0.5 + (opacityValue - 0.5) * 2;
        }
        opacityValue = opacityValue.clamp(0.66, 1);
        return Positioned(
          left: left,
          top: top,
          child: Opacity(
            opacity: opacityValue,
            child: SizedBox.fromSize(
              size: movingAnim.originalPositioning.$2,
              child: child!,
            ),
          ),
        );
      },
    );
  }

  Widget addGlobalKey(BuildContext context, T e, Widget item) {
    if (!widget.addGlobalKeys) return item;
    var key = itemKeys[e];
    if (key == null) {
      key = GlobalKey();
      itemKeys[e] = key;
    }
    return KeyedSubtree(
      key: key,
      child: item,
    );
  }

  (Offset, Size)? getPositioningForItem(T e) {
    if (!widget.addGlobalKeys) return null;
    final globalKey = itemKeys[e];
    if (globalKey == null || globalKey.currentContext == null) return null;
    try {
      RenderBox box = globalKey.currentContext!.findRenderObject()! as RenderBox;
      final position = box.localToGlobal(
        Offset.zero,
        ancestor: context.findRenderObject(),
      );
      return (position, box.size);
    } catch (_) {}
    return null;
  }

  Widget buildProxiedSizedBox(T e, [Size? size]) {
    final size = getPositioningForItem(e)?.$2;
    if (size != null) {
      return SizedBox.fromSize(size: size);
    } else {
      return SizedBox.shrink();
    }
  }
}

class AnimationValues {
  late final AnimationController animationController;
  late final Animation<double> animation;
  late final int index; // only used for ougoing items
}

class MovingAnimationValues extends AnimationValues {
  late final int originalIndex;
  late final (Offset, Size) originalPositioning;
}

class AnimatedFlex<T> extends StatelessWidget {
  final List<T> data;
  final ItemBuilder<T> itemBuilder;
  final ItemTransitionBuilder<T>? transitionBuilder;
  final Duration duration;
  final Curve? curve;
  final bool addGlobalKeys;
  // Flex params (Column / Row)
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final Clip clipBehavior;
  final double spacing;

  const AnimatedFlex({
    required this.data,
    required this.itemBuilder,
    this.transitionBuilder,
    required this.duration,
    this.curve,
    this.addGlobalKeys = true,
    // Flex params (Column / Row)
    required this.direction,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.clipBehavior = Clip.none,
    this.spacing = 0.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedLayout<T>(
      data: data,
      itemBuilder: itemBuilder,
      transitionBuilder: transitionBuilder ?? defaultTransitionBuilder,
      duration: duration,
      curve: curve,
      addGlobalKeys: addGlobalKeys,
      layoutBuilder: (context, children) {
        return Flex(
          direction: direction,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          clipBehavior: clipBehavior,
          spacing: spacing,
          children: children,
        );
      },
    );
  }

  Widget defaultTransitionBuilder(BuildContext context, T data, Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axis: direction,
        // hack to prevent SizeTransition from breaking cross-axis sizing when inside IntrinsicWidth/Height
        child: Flex(
          direction: direction,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [child],
        ),
      ),
    );
  }
}

class AnimatedColumn<T> extends AnimatedFlex<T> {
  const AnimatedColumn({
    required super.data,
    required super.itemBuilder,
    super.transitionBuilder,
    required super.duration,
    super.curve,
    super.addGlobalKeys = true,
    // Column params
    super.mainAxisAlignment = MainAxisAlignment.start,
    super.mainAxisSize = MainAxisSize.max,
    super.crossAxisAlignment = CrossAxisAlignment.center,
    super.textDirection,
    super.verticalDirection = VerticalDirection.down,
    super.textBaseline,
    super.clipBehavior = Clip.none,
    super.spacing = 0.0,
    super.key,
  }) : super(direction: Axis.vertical);
}

class AnimatedRow<T> extends AnimatedFlex<T> {
  const AnimatedRow({
    required super.data,
    required super.itemBuilder,
    super.transitionBuilder,
    required super.duration,
    super.curve,
    super.addGlobalKeys = true,
    // Column params
    super.mainAxisAlignment = MainAxisAlignment.start,
    super.mainAxisSize = MainAxisSize.max,
    super.crossAxisAlignment = CrossAxisAlignment.center,
    super.textDirection,
    super.verticalDirection = VerticalDirection.down,
    super.textBaseline,
    super.clipBehavior = Clip.none,
    super.spacing = 0.0,
    super.key,
  }) : super(direction: Axis.horizontal);
}

// TODO: 2 implement AnimatedStack with this same logic
