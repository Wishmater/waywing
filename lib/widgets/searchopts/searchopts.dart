import "dart:ffi";

import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart";
import "package:fuzzy_string/fuzzy_string.dart";
import "package:nucleo_dart/nucleo_dart.dart";
import "package:waywing/core/config.dart";
import "filtered_list.dart";
import "./options_list_widgets/stack_option_list_widget.dart";

/// An [Intent] to highlight the previous option in the autocomplete list.
class SearchPreviousOptionIntent extends Intent {
  /// Creates an instance of SearchPreviousOptionIntent.
  const SearchPreviousOptionIntent();
}

/// An [Intent] to highlight the next option in the Search list.
class SearchNextOptionIntent extends Intent {
  /// Creates an instance of SearchNextOptionIntent.
  const SearchNextOptionIntent();
}

/// An [Intent] to select the current highlighted option in the Search list.
class SearchSelectOptionIntent extends Intent {
  /// Creates an instance of SearchSelectOptionIntent.
  const SearchSelectOptionIntent();
}

sealed class OptionValue {
  const OptionValue();
}

class StringOptionValue extends OptionValue {
  final String value;
  const StringOptionValue(this.value);
}

class NativeOptionValue extends OptionValue {
  final Pointer<Uint8> pointer;
  final int length;
  const NativeOptionValue(this.pointer, this.length);
}

abstract class Option<T extends Object> {
  int get identifier;

  OptionValue get primaryValue;

  OptionValue? get secondaryValue;

  T get object;

  const Option();

  static List<Option<T>> from<T extends Object>(List<T> options, Option<T> Function(T) conveter) {
    return options.map((e) => conveter(e)).toList();
  }

  static List<Option<String>> fromString(List<String> options) {
    return from(options, (v) => _StringOption(v));
  }
}

class _StringOption extends Option<String> {
  final String _value;

  _StringOption(this._value);

  @override
  int get identifier => _value.hashCode;

  @override
  String get object => _value;

  @override
  OptionValue get primaryValue => StringOptionValue(_value);

  @override
  OptionValue? get secondaryValue => null;
}

class SearchOptionsRenderConfig {
  final bool isHighlighted;

  const SearchOptionsRenderConfig({required this.isHighlighted});
}

typedef RenderOption<T extends Object> =
    Widget Function(BuildContext context, T item, SearchOptionsRenderConfig config);

class SearchOptions<T extends Object> extends StatefulWidget {
  const SearchOptions({
    super.key,
    required this.options,
    required this.renderOption,
    required this.onSelected,
    required this.width,
    required this.height,
    this.focusNode,
    this.showScrollBar = true,
    this.previousOptionActivator = const SingleActivator(LogicalKeyboardKey.arrowUp),
    this.nextOptionActivator = const SingleActivator(LogicalKeyboardKey.arrowDown),
    this.selectOptionActivator = const SingleActivator(LogicalKeyboardKey.enter),
    this.prototypeItem,
    this.matcher = const SmithWaterman(),
  });

  final List<Option<T>> options;

  final RenderOption<T> renderOption;

  final void Function(T item) onSelected;

  final Widget? prototypeItem;

  /// Shorcut activator to highlight the previous option
  final ShortcutActivator previousOptionActivator;

  /// Shorcut activator to highlight the next option
  final ShortcutActivator nextOptionActivator;

  /// Shorcut activator to select the current highlighted option
  final ShortcutActivator selectOptionActivator;

  /// fuzzy matching alghorithm used to filter
  final FuzzyStringMatcher matcher;

  final FocusNode? focusNode;

  final bool showScrollBar;

  final double width;

  final double height;

  @override
  State<SearchOptions<T>> createState() => _SearchOptionsState<T>();
}

class _SearchOptionsState<T extends Object> extends State<SearchOptions<T>> with SingleTickerProviderStateMixin {
  late NucleoDart nucleo;

  late Map<int, Option<T>> items;
  late FilteredList<Option<T>> filtered;
  late Ticker tick;

  ValueNotifier<int> highlighted = ValueNotifier(0);

  late final Map<Type, Action<Intent>> actionMap;
  late final CallbackAction<SearchPreviousOptionIntent> previousOptionAction;
  late final CallbackAction<SearchNextOptionIntent> nextOptionAction;
  late final CallbackAction<SearchSelectOptionIntent> selectOptionAction;

  late final Map<ShortcutActivator, Intent> shortcuts;

  final GlobalKey optionsListWidgetGlobalKey = GlobalKey();
  OptionsListRenderer get optionsListRenderer {
    final state = optionsListWidgetGlobalKey.currentState;
    assert(
      state != null,
      "optionsListWidgetGlobalKey hasn't been assigned to a widget, or was accessed before the first frame",
    );
    assert(
      state is OptionsListRenderer,
      "optionsListWidgetGlobalKey was assigned to a widget whose state doesn't implement OptionsListRenderer",
    );
    return state as OptionsListRenderer;
  }

  bool _needsUpdateFilters = false;
  void _updateFilters() {
    filtered = FilteredList<Option<T>>(items, nucleo.getSnapshot());
    updateHighlight(highlighted.value, ScrollDirection.forward);
    setState(() {});
  }

  @override
  void didUpdateWidget(SearchOptions<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final start = oldWidget.options.length;
    final end = widget.options.length;
    // This assume that the widget change is only additional entries.
    // final iterable = widget.options.getRange(start, end);
    for (int i = start; i < end; i++) {
      items[i] = widget.options[i];
    }
    for (int i = start; i < end; i++) {
      final e = widget.options[i];
      final v = e.primaryValue;
      switch (v) {
        case StringOptionValue():
          nucleo.add(i, v.value);
        case NativeOptionValue():
          nucleo.addNative(i, v.pointer, v.length);
      }
    }
    // for (final e in iterable) {
    //   switch(e.primaryValue) {
    //     case StringOptionValue():
    //     nucleo.add()
    //     case NativeOptionValue():
    //       throw UnimplementedError();
    //   }
    // }
    // nucleo.addAllAsync(iterable.map((e) => e.primaryValue).toList(), List.generate(end - start, (i) => i + start));
  }

  void _initNucleo() {
    nucleo = NucleoDart(() {});
    // TODO maybe we can use the secondaryValue using the multicolumn feature of nucleo
    // nucleo.addAll(widget.options.map((e) => e.primaryValue));
    for (int i = 0; i < widget.options.length; i++) {
      final e = widget.options[i];
      final v = e.primaryValue;
      switch (v) {
        case StringOptionValue():
          nucleo.add(i, v.value);
        case NativeOptionValue():
          nucleo.addNative(i, v.pointer, v.length);
      }
    }
    nucleo.reparse("");
    nucleo.tick();

    tick = createTicker((d) {
      nucleo.tick();
      if (_needsUpdateFilters) {
        _updateFilters();
        _needsUpdateFilters = false;
      }
    });
    tick.start();
  }

  @override
  void initState() {
    super.initState();

    _initNucleo();

    items = {};
    for (int i = 0; i < widget.options.length; i++) {
      items[i] = widget.options[i];
    }
    filtered = FilteredList<Option<T>>(items, nucleo.getSnapshot());

    shortcuts = <ShortcutActivator, Intent>{
      widget.previousOptionActivator: const SearchPreviousOptionIntent(),
      widget.nextOptionActivator: const SearchNextOptionIntent(),
      widget.selectOptionActivator: const SearchSelectOptionIntent(),
    };

    previousOptionAction = CallbackAction<SearchPreviousOptionIntent>(onInvoke: highlightPreviousOption);
    nextOptionAction = CallbackAction<SearchNextOptionIntent>(onInvoke: highlightNextOption);
    selectOptionAction = CallbackAction<SearchSelectOptionIntent>(onInvoke: selectOption);

    actionMap = <Type, Action<Intent>>{
      SearchPreviousOptionIntent: previousOptionAction,
      SearchNextOptionIntent: nextOptionAction,
      SearchSelectOptionIntent: selectOptionAction,
    };
  }

  @override
  void dispose() {
    tick.dispose();
    nucleo.destroy();
    highlighted.dispose();
    super.dispose();
  }

  // ignore: unused_element could this be useful in the future? I dont know so i will let it be for now
  bool _isItemVisible(int index) {
    return optionsListRenderer.isItemVisible(index);
  }

  void _scrollTo(int index, ScrollDirection direction) {
    optionsListRenderer.scrollTo(index, direction);
  }

  void updateHighlight(int newIndex, ScrollDirection direction) {
    if (filtered.isEmpty) {
      highlighted.value = 0;
      return;
    }
    highlighted.value = newIndex % filtered.length;
    _scrollTo(highlighted.value, direction);
  }

  void highlightPreviousOption(SearchPreviousOptionIntent intent) {
    // if its the first item change the scrolling direction to avoid weird jumps animations
    return switch (highlighted.value) {
      0 => updateHighlight(highlighted.value - 1, ScrollDirection.forward),
      _ => updateHighlight(highlighted.value - 1, ScrollDirection.reverse),
    };
  }

  void highlightNextOption(SearchNextOptionIntent intent) {
    // if its the last item change the scrolling direction to avoid weird jumps animations
    return switch (highlighted.value == filtered.length - 1) {
      true => updateHighlight(highlighted.value + 1, ScrollDirection.reverse),
      false => updateHighlight(highlighted.value + 1, ScrollDirection.forward),
    };
  }

  void selectOption(SearchSelectOptionIntent intent) {
    widget.onSelected(filtered[highlighted.value].object);
  }

  void updateFilter(String v) {
    nucleo.reparse(v);
    _needsUpdateFilters = true;
  }

  @override
  Widget build(BuildContext context) {
    const textFieldHeight = 64.0;
    const itemHeight = 64.0; // TODO 3: this should be reported by the same that gives renderOption

    final height = widget.height;
    final width = widget.width;

    final contentHeight = height - textFieldHeight;
    final focusableItemCount = (contentHeight / itemHeight).floor();
    final lastItemPos = itemHeight * focusableItemCount;

    Widget optionsView = StackOptionsListWidget<T>(
      key: optionsListWidgetGlobalKey,
      options: widget.options,
      renderOption: widget.renderOption,
      itemHeight: itemHeight,
      prototypeItem: widget.prototypeItem,
      filtered: filtered,
      highlighted: highlighted,
      availableHeight: contentHeight,
      showScrollBar: widget.showScrollBar,
      motion: mainConfig.motions.expressive.spatial.normal,
    );

    final borderRadiusTop = const BorderRadius.vertical(top: Radius.circular(10));
    final borderRadiusBottom = const BorderRadius.vertical(bottom: Radius.circular(10));
    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actionMap,
        // TODO: 2 migrate this to use WingedContainer
        child: InputRegion(
          child: Column(
            children: [
              SizedBox(
                height: textFieldHeight,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadiusTop,
                  ),
                  child: Material(
                    borderRadius: borderRadiusTop,
                    child: TextFormField(
                      autofocus: true,
                      focusNode: widget.focusNode,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 32,
                          // ugly hack, but flutter TextFormField widget is dogshit
                          // and doesn't allow me to set a fixed height, so it is what it is
                          vertical: (textFieldHeight - 16) / 2,
                        ),
                      ),
                      onChanged: updateFilter,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ExcludeFocusTraversal(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadiusBottom,
                      ),
                      child: Material(
                        borderRadius: borderRadiusBottom,
                        child: ShaderMask(
                          blendMode: BlendMode.dstOut,
                          shaderCallback: (_) {
                            // don't use provided bounds that change with inner size, instead use fixed constraints from the LayoutBuilder
                            final shaderRect = Rect.fromLTRB(
                              0,
                              lastItemPos,
                              width,
                              contentHeight,
                            );
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black],
                            ).createShader(shaderRect);
                          },
                          child: optionsView,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class OptionsListRenderer {
  bool isItemVisible(int index);
  void scrollTo(int index, ScrollDirection direction);
}
