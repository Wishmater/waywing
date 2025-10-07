import "dart:async";
import "dart:ffi";
import "package:dartx/dartx_io.dart";
import "package:ffi/ffi.dart";

import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/util/focus_grab/widget.dart";
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/searchopts/searchopts.dart";

import "./byte_line_splitter.dart";

class MenuWing extends Wing {
  MenuWing._();

  static void registerFeather(RegisterFeatherCallback<MenuWing, dynamic> registerFeather) {
    registerFeather(
      "Menu",
      FeatherRegistration<MenuWing, dynamic>(
        constructor: MenuWing._,
      ),
    );
  }

  @override
  String get name => "Menu";

  // TODO 1
  // The dart ffi arena implementation is dog shit
  // we will be better using the zig std arena for this
  // as we seem to be expending a lot of time in allocations
  Arena _arena = Arena(malloc);

  @override
  late final Map<String, WaywingAction>? actions = {
    "activate": WaywingAction(
      "Show menu",
      (request) async {
        if (response != null) return WaywingResponse(400, "menu is already showing");

        _arena = Arena(malloc);
        showMenu.value = true;
        controller.grabFocus();
        response = Completer();

        final subs = request.body
            .transform(BytesLineSplitter())
            .listen(
              (lines) {
                if (response == null || lines.isEmpty) return;

                for (final line in lines) {
                  if (line.isNotEmpty) {
                    final lineNative = line.alloc(_arena);
                    items.value.add((lineNative, line.length));
                  }
                }
                items.manualNotifyListeners();
              },
              onDone: () {
                if (items.value.isEmpty && response != null) {
                  response!.complete("");
                  return;
                }
              },
            );

        final resp = await response!.future;
        controller.ungrabFocus();
        response = null;
        showMenu.value = false;
        items.value.clear();
        subs.cancel().onError((_, _) {});
        _arena.releaseAll();
        return WaywingResponse.ok(resp);
      },
    ),
  };

  ValueNotifier<bool> showMenu = ValueNotifier(false);
  late final controller = FocusGrabController(
    onCleared: () {
      response?.complete("");
    },
  );

  ManualValueNotifier<List<(Pointer<Uint8>, int)>> items = ManualValueNotifier([]);
  Completer<String>? response;

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    return ValueListenableBuilder(
      valueListenable: showMenu,
      builder: (context, show, _) {
        if (!show) {
          return SizedBox.shrink();
        }
        return Center(
          child: InputRegion(
            child: KeyboardFocus(
              mode: KeyboardFocusMode.onDemand,
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.escape): () {
                    response?.complete("");
                  },
                },
                child: FocusGrab(
                  controller: controller,
                  child: SizedBox(
                    width: 400,
                    height: 400,
                    child: Menu(
                      items: items,
                      onSelected: (selected) {
                        response?.complete(selected.$1.cast<Utf8>().toDartString(length: selected.$2));
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Menu extends StatelessWidget {
  final ManualValueNotifier<List<(Pointer<Uint8>, int)>> items;
  final Function((Pointer<Uint8>, int)) onSelected;

  const Menu({super.key, required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return KeyboardFocus(
      mode: KeyboardFocusMode.onDemand,
      child: ValueListenableBuilder(
        valueListenable: items,
        builder: (context, value, _) {
          return SearchOptions<(Pointer<Uint8>, int)>(
            options: value.map((e) => NativeStringOption(e.$1, e.$2)).toList(),
            onSelected: onSelected,
            height: 400.0,
            width: 400.0,
            renderOption: (context, value, config) {
              return ListTile(
                title: Text(
                  value.$1.cast<Utf8>().toDartString(length: value.$2),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NativeStringOption extends Option<(Pointer<Uint8>, int)> {
  final Pointer<Uint8> pointer;
  final int length;

  @override
  (Pointer<Uint8>, int) get object => (pointer, length);

  const NativeStringOption(this.pointer, this.length);

  @override
  int get identifier => Object.hashAll([pointer.address, length]);

  @override
  NativeOptionValue get primaryValue => NativeOptionValue(pointer, length);

  @override
  NativeOptionValue? get secondaryValue => null;
}


extension on Uint8List {
  Pointer<Uint8> alloc([Allocator allocator = malloc]) {
    final result = allocator<Uint8>(lengthInBytes);
    result.asTypedList(lengthInBytes).setRange(0, lengthInBytes, this);
    return result;
  }
}
