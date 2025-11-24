import "dart:ui";

import "package:dartx/dartx.dart";
import "package:flutter/widgets.dart";
import "package:motor/motor.dart";
import "package:waywing/util/animation_utils.dart";
import "package:waywing/util/state_positioning.dart";

typedef ItemBuilder<T> = Widget Function(BuildContext context, T data);
typedef ItemTransitionBuilder<T> =
    Widget Function(BuildContext context, T data, Widget child, Animation<double> animation);
typedef LayoutBuilder<T> = Widget Function(BuildContext context, List<Widget> items, List<T> data);

class MotionLayout<T> extends StatefulWidget {
  /// T must implement equals and hashCode properly
  final List<T> data;
  final ItemBuilder<T> itemBuilder;
  final LayoutBuilder<T> layoutBuilder;
  final ItemTransitionBuilder<T> transitionBuilder;
  final Motion motion;

  /// This makes sense for some layouts, like Column and Row; but doesn't for others, like Stacks.
  final bool animateIndexChanges;

  /// Add a GlobalKey to each item. This has a performance impact and could have some issues,
  /// but it allows the child state to live permanently through list order changes,
  /// this allows to more easily implement consistent implicit animations when the child internals themselves change.
  final bool addGlobalKeys;

  const MotionLayout({
    required this.data,
    required this.itemBuilder,
    required this.layoutBuilder,
    required this.transitionBuilder,
    required this.motion,
    this.addGlobalKeys = true,
    this.animateIndexChanges = false,
    super.key,
  }) : assert(
         !animateIndexChanges || addGlobalKeys,
         "animateIndexChanges requires addGlobalKeys to be enabled, "
         "so the MotionLayout can get the positioning of the children widgets.",
       );

  @override
  State<MotionLayout<T>> createState() => _MotionLayoutState<T>();
}

class _MotionLayoutState<T> extends State<MotionLayout<T>> with TickerProviderStateMixin {
  late final List<_UpdateBatch<T>> updateBatches = [];
  late final Map<T, GlobalKey> itemKeys = {};

  @override
  void dispose() {
    for (final batch in updateBatches) {
      for (final e in batch.incomingItems.values) {
        e.motionController.dispose();
      }
      for (final e in batch.outgoingItems.values) {
        e.motionController.dispose();
      }
      for (final e in batch.movingItems.values) {
        e.motionController.dispose();
      }
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MotionLayout<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final batch = _UpdateBatch<T>();
    for (int i = 0; i < oldWidget.data.length; i++) {
      final e = oldWidget.data[i];
      if (!widget.data.contains(e)) {
        addOutgoingItem(batch, e, i);
      }
    }
    for (int i = 0; i < widget.data.length; i++) {
      final e = widget.data[i];
      final oldIndex = oldWidget.data.indexOf(e);
      if (oldIndex < 0) {
        addIncomingItem(batch, e);
      } else if (widget.animateIndexChanges) {
        // add moving items if their index changed
        final addedItemsCount = batch.incomingItems.length;
        final removedOriginalItemsCount = _getRemovedItemsCountUpToIndex(batch, oldIndex);
        final oldIndexAdjusted = oldIndex + addedItemsCount - removedOriginalItemsCount;
        if (oldIndexAdjusted != i) {
          addMovingItem(batch, e, i, oldIndexAdjusted);
        }
      }
    }
    updateBatches.add(batch);
  }

  int _getRemovedItemsCountUpToIndex(_UpdateBatch<T> batch, int oldIndex) {
    final outgoingAnims = batch.outgoingItems.values.toList();
    for (int i = 0; i < outgoingAnims.length; i++) {
      if (outgoingAnims[i].oldIndex >= oldIndex) {
        return i;
      }
    }
    return outgoingAnims.length;
  }

  void addIncomingItem(_UpdateBatch<T> batch, T e) {
    final outgoingAnim = _removeOutgoingItem(e);
    final anim = IncomingAnimationValues();
    if (outgoingAnim != null) {
      anim.motionController = outgoingAnim.motionController;
    } else {
      initAnimationValues(anim, true);
    }
    anim.motionController.forward().whenComplete(() {
      if (!mounted) return;
      setState(() {
        anim.motionController.dispose();
        _removeIncomingItem(e);
      });
    });
    batch.incomingItems[e] = anim;
  }

  void addOutgoingItem(_UpdateBatch<T> batch, T e, int index) {
    final incomingAnim = _removeIncomingItem(e);
    final anim = OutgoingAnimationValues();
    if (incomingAnim != null) {
      anim.motionController = incomingAnim.motionController;
    } else {
      initAnimationValues(anim, false);
    }
    anim.oldIndex = index;
    anim.motionController.reverse().whenComplete(() {
      if (!mounted) return;
      setState(() {
        anim.motionController.dispose();
        _removeOutgoingItem(e);
        itemKeys.remove(e);
      });
    });
    batch.outgoingItems[e] = anim;
  }

  void addMovingItem(_UpdateBatch<T> batch, T e, int newIndex, int originalIndex) {
    final positioning = getPositioningForItem(e);
    if (positioning == null) {
      addIncomingItem(batch, e);
      return;
    }
    // TODO: 1 what happens if the item is already moving?
    final movingAnim = _removeMovingItem(e);
    final anim = MovingAnimationValues();
    if (movingAnim == null) {
      initAnimationValues(anim, true);
      anim.originalPositioning = positioning;
    } else {
      initAnimationValues(anim, true);
      anim.originalPositioning = positioning;
    }
    anim.targetIndex = newIndex;
    anim.originIndex = originalIndex;
    anim.motionController.forward().whenComplete(() {
      if (!mounted) return;
      setState(() {
        anim.motionController.dispose();
        _removeMovingItem(e);
      });
    });
    batch.movingItems[e] = anim;
  }

  A initAnimationValues<A extends AnimationValues>(A anim, bool isForward) {
    anim.motionController = BoundedMotionController<double>(
      vsync: this,
      motion: widget.motion,
      converter: SingleMotionConverter(),
      lowerBound: 0,
      upperBound: 1,
      initialValue: isForward ? 0 : 1,
    );
    return anim;
  }

  IncomingAnimationValues? _removeIncomingItem(T e) {
    final batchIndex = updateBatches.indexWhere((batch) => batch.incomingItems.containsKey(e));
    if (batchIndex < 0) return null;
    final result = updateBatches[batchIndex].incomingItems.remove(e);
    if (updateBatches[batchIndex].isEmpty) {
      updateBatches.removeAt(batchIndex);
    }
    return result;
  }

  OutgoingAnimationValues? _removeOutgoingItem(T e) {
    final batchIndex = updateBatches.indexWhere((batch) => batch.outgoingItems.containsKey(e));
    if (batchIndex < 0) return null;
    final result = updateBatches[batchIndex].outgoingItems.remove(e);
    if (updateBatches[batchIndex].isEmpty) {
      updateBatches.removeAt(batchIndex);
    }
    return result;
  }

  MovingAnimationValues? _removeMovingItem(T e) {
    final batchIndex = updateBatches.indexWhere((batch) => batch.movingItems.containsKey(e));
    if (batchIndex < 0) return null;
    final result = updateBatches[batchIndex].movingItems.remove(e);
    if (updateBatches[batchIndex].isEmpty) {
      updateBatches.removeAt(batchIndex);
    }
    return result;
  }

  // TODO: 3 PERFORMANCE we might want to optimize the findItem methods, because they are called SEVERAL times during build
  IncomingAnimationValues? _findIncomingAnim(T e) {
    return updateBatches.map((batch) => batch.incomingItems[e]).firstOrNullWhere((e) => e != null);
  }

  OutgoingAnimationValues? _findOutgoingAnim(T e) {
    return updateBatches.map((batch) => batch.outgoingItems[e]).firstOrNullWhere((e) => e != null);
  }

  MovingAnimationValues? _findMovingAnim(T e) {
    if (!widget.animateIndexChanges) return null;
    return updateBatches.map((batch) => batch.movingItems[e]).firstOrNullWhere((e) => e != null);
  }

  int getIndexOffset(int batchIndex, int itemIndex) {
    int result = 0;
    for (int i = 0; i < batchIndex; i++) {
      for (final previousOutgoingAnim in updateBatches[i].outgoingItems.values) {
        if (previousOutgoingAnim.oldIndex > itemIndex) break;
        result++;
      }
      for (final previousMovingAnim in updateBatches[i].outgoingItems.values) {
        if (previousMovingAnim.oldIndex > itemIndex) break;
        result++;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    final List<T> data = [];
    final List<Widget> overlayWidgets = [];

    // build currently existing item widgets
    for (final e in widget.data) {
      final movingAnim = _findMovingAnim(e);
      Widget itemWidget;
      if (movingAnim == null) {
        itemWidget = widget.itemBuilder(context, e);
        itemWidget = addGlobalKey(context, e, itemWidget);
        final incomingAnim = _findIncomingAnim(e);
        if (incomingAnim != null) {
          itemWidget = widget.transitionBuilder(context, e, itemWidget, incomingAnim.animation);
        }
      } else {
        // we need to add the target widget of moving items at this moment,
        // if we don't, indices will be distorted.
        // in other words: the target widget of a movingAnim for an item that is still on the list
        // is technically an existing item widget for layout, so not adding it at the proper time
        // will break the indices and layout
        itemWidget = buildMovingTargetWidget(movingAnim, _findOutgoingAnim(e), e);
      }
      widgets.add(itemWidget);
      data.add(e);
    }

    for (int batchIndex = 0; batchIndex < updateBatches.length; batchIndex++) {
      final batch = updateBatches[batchIndex];

      // build outgoing item widgets
      for (final entry in batch.outgoingItems.entries) {
        final e = entry.key;
        final outgoingAnim = entry.value;
        final movingAnim = _findMovingAnim(e);
        Widget outgoingWidget;
        if (movingAnim == null) {
          outgoingWidget = widget.itemBuilder(context, e);
          outgoingWidget = addGlobalKey(context, e, outgoingWidget);
          outgoingWidget = widget.transitionBuilder(context, e, outgoingWidget, outgoingAnim.animation);
        } else {
          // we need to add the target widget of moving items at this moment,
          // if we don't, indices will be distorted.
          // in other words: the origin widget of a movingAnim is technically an outgoing item widget,
          // so  adding at this time makes it way easier to handle calculating adjustedIndices
          assert(movingAnim.originIndex == outgoingAnim.oldIndex);
          outgoingWidget = buildMovingOriginWidget(movingAnim, _findIncomingAnim(e), e);
        }
        final indexOffset = getIndexOffset(batchIndex, outgoingAnim.oldIndex);
        final adjustedIndex = (outgoingAnim.oldIndex + indexOffset).clamp(0, widgets.length);
        widgets.insert(adjustedIndex, outgoingWidget);
        data.insert(adjustedIndex, e);
      }

      // build moving item widgets, this is the cause for 90% of the complexity
      for (final entry in batch.movingItems.entries) {
        final e = entry.key;
        final movingAnim = entry.value;
        final incomingAnim = _findIncomingAnim(e);
        final outgoingAnim = _findOutgoingAnim(e);
        // add actual item to overlay, animating its Position
        Widget item = widget.itemBuilder(context, e);
        item = addGlobalKey(context, e, item);
        if (incomingAnim != null || outgoingAnim != null) {
          assert(
            incomingAnim == null || outgoingAnim == null,
            "An item can't have both incoming and outgoint animations, "
            "this should have be validated when creating them",
          );
          item = widget.transitionBuilder(context, e, item, (incomingAnim ?? outgoingAnim!).animation);
        }
        item = buildMovingTransition(movingAnim, e, item);
        overlayWidgets.add(item);
        // add a sized proxy to the original index,
        // only if it wasn't already added (item is still in list).
        // in other words: if the item was removed from list, originWidget will be added
        // when building outgoingAnims; if it still in the list, we need to add it here
        if (outgoingAnim == null) {
          final originWidget = buildMovingOriginWidget(movingAnim, incomingAnim, e);
          final outgoingIndexOffset = getIndexOffset(batchIndex, movingAnim.originIndex);
          final outgoingAdjustedIndex = movingAnim.originIndex + outgoingIndexOffset;
          widgets.insert(outgoingAdjustedIndex, originWidget);
          data.insert(outgoingAdjustedIndex, e);
        }
        // add a sized proxy to the target index,
        // only if it wasn't already added (item was removed from the list).
        // in other words: if the item is still on the list, targetWidget will be added
        // when building widget.data; if it was removed from the list, we need to add it here
        if (outgoingAnim != null) {
          final targetWidget = buildMovingTargetWidget(movingAnim, outgoingAnim, e);
          final targetIndexOffset = getIndexOffset(batchIndex, movingAnim.targetIndex);
          final targetAdjustedIndex = movingAnim.originIndex + targetIndexOffset;
          widgets.insert(targetAdjustedIndex, targetWidget);
          data.insert(targetAdjustedIndex, e);
        }
      }
    }

    return Stack(
      children: [
        widget.layoutBuilder(context, widgets, data),
        ...overlayWidgets,
      ],
    );
  }

  Positioning? getPositioningForItem(T e) {
    if (!widget.addGlobalKeys) return null;
    final globalKey = itemKeys[e];
    if (globalKey == null || globalKey.currentContext == null) return null;
    try {
      RenderBox box = globalKey.currentContext!.findRenderObject()! as RenderBox;
      final position = box.localToGlobal(
        Offset.zero,
        ancestor: context.findRenderObject(),
      );
      return Positioning(position, box.size);
    } catch (_) {}
    return null;
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

  Widget buildMovingOriginWidget(MovingAnimationValues movingAnim, IncomingAnimationValues? incomingAnim, T e) {
    // // TODO: 2 getting size from flying item isn't working,
    // // so we use the cached size from when the move happened
    // // this will look weird if the item size changes while flying
    // // this issue applies to both outgoing and incoming proxied sizebox
    // final positioning = getPositioningForItem(e);
    Widget originItem = buildProxiedSizedBox(e, movingAnim.originalPositioning.size);
    // if there is an item incoming to the list that has been moved,
    // the incomingAnim will affect be the originWidget animation
    final originAnimation = incomingAnim == null
        ? ReverseAnimation(movingAnim.animation)
        : MultipliedAnimation(incomingAnim.animation, ReverseAnimation(movingAnim.animation));
    originItem = widget.transitionBuilder(context, e, originItem, originAnimation);
    return originItem;
  }

  Widget buildMovingTargetWidget(MovingAnimationValues movingAnim, OutgoingAnimationValues? outgoingAnim, T e) {
    // // TODO: 2 getting size from flying item isn't working,
    // // so we use the cached size from when the move happened
    // // this will look weird if the item size changes while flying
    // // this issue applies to both outgoing and incoming proxied sizebox
    // final positioning = getPositioningForItem(e);
    Widget targetItem = buildProxiedSizedBox(e, movingAnim.originalPositioning.size);
    // if there is a moving item that has been removed from the list,
    // the outgoingAnim will affect be the targetWidget animation
    targetItem = PositioningMonitor(
      controller: movingAnim.targetPositioningController,
      child: targetItem,
    );
    final targetAnimation = outgoingAnim == null
        ? movingAnim.animation
        : MultipliedAnimation(outgoingAnim.animation, movingAnim.animation);
    targetItem = widget.transitionBuilder(context, e, targetItem, targetAnimation);
    return targetItem;
  }

  Widget buildProxiedSizedBox(T e, [Size? size]) {
    final size = getPositioningForItem(e)?.size;
    if (size != null) {
      return SizedBox.fromSize(size: size);
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildMovingTransition(MovingAnimationValues movingAnim, T e, Widget item) {
    // this builds a Positioned widget that will animate the moving item's position from origin to target point
    return AnimatedBuilder(
      animation: movingAnim.animation,
      child: item,
      builder: (context, child) {
        Positioning? positioning;
        try {
          positioning = movingAnim.targetPositioningController.getPositioning(
            parentContext: this.context,
          );
        } catch (_) {}
        final left = positioning == null
            ? movingAnim.originalPositioning.offset.dx
            : lerpDouble(
                movingAnim.originalPositioning.offset.dx,
                positioning.offset.dx,
                movingAnim.animation.value,
              );
        final top = positioning == null
            ? movingAnim.originalPositioning.offset.dy
            : lerpDouble(
                movingAnim.originalPositioning.offset.dy,
                positioning.offset.dy,
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
              size: movingAnim.originalPositioning.size,
              child: child!,
            ),
          ),
        );
      },
    );
  }
}

class _UpdateBatch<T> {
  final Map<T, IncomingAnimationValues> incomingItems = {};
  final Map<T, OutgoingAnimationValues> outgoingItems = {};
  final Map<T, MovingAnimationValues> movingItems = {};

  bool get isEmpty => incomingItems.isEmpty && outgoingItems.isEmpty && movingItems.isEmpty;
}

class AnimationValues<T extends Object> {
  late final BoundedMotionController<T> motionController;
  Animation<T> get animation => motionController;
}

class IncomingAnimationValues extends AnimationValues<double> {}

class OutgoingAnimationValues extends AnimationValues<double> {
  late final int oldIndex;
}

class MovingAnimationValues extends AnimationValues<double> {
  late final int targetIndex;
  late final int originIndex;
  late final Positioning originalPositioning;
  late final PositioningController targetPositioningController = PositioningController();
}
