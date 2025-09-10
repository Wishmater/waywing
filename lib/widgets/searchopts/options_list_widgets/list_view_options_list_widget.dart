import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "../searchopts.dart";

class ListViewOptionsListWidget<T extends Object> extends StatefulWidget {

  final List<Option<T>> options;
  final RenderOption<T> renderOption;
  final List<Option<T>> filtered;
  final Widget? prototypeItem;
  final ValueNotifier<int> highlighted;

  const ListViewOptionsListWidget({
    required this.options,
    required this.renderOption,
    required this.filtered,
    required this.prototypeItem,
    required this.highlighted,
    super.key,
  });

  @override
  State<ListViewOptionsListWidget<T>> createState() => _ListViewOptionsListWidgetState<T>();
}

class _ListViewOptionsListWidgetState<T extends Object> extends State<ListViewOptionsListWidget<T>> implements OptionsListRenderer {

  final ScrollController scrollController = ScrollController();

  GlobalKey? currentHighlightKey;
  double? itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.highlighted,
      builder: (context, _) {
        return ListView.builder(
          controller: scrollController,
          itemCount: widget.filtered.length,
          prototypeItem: _GetSizeWidget(
            child: widget.prototypeItem ??
                widget.renderOption(
                  context,
                  widget.options.first.object,
                  const SearchOptionsRenderConfig(isHighlighted: false),
                ),
            onSize: (v) => itemHeight = v.height,
          ),
          itemBuilder: (context, index) {
            final isHighlighted = widget.highlighted.value == index;
            final child = widget.renderOption(
              context,
              widget.filtered[index].object,
              SearchOptionsRenderConfig(isHighlighted: isHighlighted),
            );
            return KeyedSubtree(
              key: isHighlighted ? currentHighlightKey : null,
              child: child
            );
          },
        );
      },
    );
  }

  @override
  bool isItemVisible(int index) {
    assert(itemHeight != null);

    final viwportDimension = scrollController.position.viewportDimension;
    final pos = index * itemHeight!;
    return scrollController.offset < pos && pos < scrollController.offset + viwportDimension;
  }

  @override
  void scrollTo(int index, ScrollDirection direction) {
    assert(itemHeight != null);

    if (isItemVisible(index)) {
      return;
    }
    switch (direction) {
      case ScrollDirection.idle:
        throw UnimplementedError("ScrollDirection.idle behaiviour is not implented");
      case ScrollDirection.forward:
        /// Use index + 1 because if not than scrolling does not get to the item
        scrollController.jumpTo(max((index + 1) * itemHeight! - scrollController.position.viewportDimension, 0));
      case ScrollDirection.reverse:
        scrollController.jumpTo( index * itemHeight!);
    }
  }

}


// Helper widget to measure prototype size
class _GetSizeWidget extends SingleChildRenderObjectWidget {
  final void Function(Size) onSize;

  const _GetSizeWidget({
    required super.child,
    required this.onSize,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderItemSizer(onSize: onSize);
  }
}

class _RenderItemSizer extends RenderProxyBox {
  final void Function(Size) onSize;

  _RenderItemSizer({required this.onSize});

  @override
  void performLayout() {
    super.performLayout();
    // Notify parent when size is determined
    if (hasSize) {
      onSize(size);
    }
  }
}
