import "package:flutter/widgets.dart";
import "package:waywing/util/state_positioning.dart";

typedef ItemBuilder<T> = Widget Function(BuildContext context, T data);
typedef ItemTransitionBuilder<T> =
    Widget Function(
      BuildContext context,
      T data,
      Widget child,
      Animation<double> animation,
      PositioningNullableGetter getPositioning,
    );
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
    // TODO: 1 handle items that change index (how to animate this?)
    for (int i = 0; i < oldWidget.data.length; i++) {
      final e = oldWidget.data[i];
      if (!widget.data.contains(e)) {
        addOutgoingItem(e, i);
      }
    }
    for (int i = 0; i < widget.data.length; i++) {
      final e = widget.data[i];
      if (!oldWidget.data.contains(e)) {
        addIncomingItem(e, i);
      }
    }
  }

  void addIncomingItem(T e, int index) {
    final anim = outgoingItems.remove(e) ?? initAnimationValues(true, index);
    anim.animationController.forward().whenComplete(() {
      setState(() {
        anim.animationController.dispose();
        incomingItems.remove(e);
      });
    });
    incomingItems[e] = anim;
  }

  void addOutgoingItem(T e, int index) {
    final anim = incomingItems.remove(e) ?? initAnimationValues(false, index);
    anim.animationController.reverse().whenComplete(() {
      setState(() {
        anim.animationController.dispose();
        outgoingItems.remove(e);
      });
    });
    outgoingItems[e] = anim;
  }

  AnimationValues initAnimationValues(bool isIncoming, int index) {
    final anim = AnimationValues();
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
    for (final e in widget.data) {
      Widget item = widget.itemBuilder(context, e);
      item = addGlobalKey(context, e, item);
      final incomingAnim = incomingItems[e];
      if (incomingAnim != null) {
        item = widget.transitionBuilder(context, e, item, incomingAnim.animation, () => getPositioningForItem(e));
      }
      items.add(item);
    }

    final outgoingEntries = outgoingItems.entries.toList();
    for (int i = 0; i < outgoingItems.length; i++) {
      final entry = outgoingEntries[i];
      final e = entry.key;
      final outgoingAnim = entry.value;
      Widget item = widget.itemBuilder(context, e);
      item = addGlobalKey(context, e, item);
      item = widget.transitionBuilder(context, e, item, outgoingAnim.animation, () => getPositioningForItem(e));
      items.insert(outgoingAnim.index.clamp(0, items.length), item);
    }

    return widget.layoutBuilder(context, items);
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
}

class AnimationValues {
  late final AnimationController animationController;
  late final Animation<double> animation;
  late final int index; // only used for ougoing items
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

  Widget defaultTransitionBuilder(
    BuildContext context,
    T data,
    Widget child,
    Animation<double> animation,
    PositioningNullableGetter getPositioning,
  ) {
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
