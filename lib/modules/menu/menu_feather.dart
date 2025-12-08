import "dart:async";
import "dart:ffi";
import "package:ffi/ffi.dart";

import "package:flutter/material.dart";
import "package:flutter/foundation.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/searchopts/searchopts.dart";

import "./byte_line_splitter.dart";

// TODO: 1 this shouldn't be a Wing, it should instead be used in a modal, like AppLauncher
class MenuFeather extends Feather {
  MenuFeather._();

  static void registerFeather(RegisterFeatherCallback<MenuFeather, dynamic> registerFeather) {
    registerFeather(
      "Menu",
      FeatherRegistration<MenuFeather, dynamic>(
        constructor: MenuFeather._,
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
        logger.debug("menu request");
        if (response != null) return WaywingResponse(400, "menu is already showing");

        _arena = Arena(malloc);
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
        response = null;
        items.value.clear();
        subs.cancel().onError((_, _) {});
        _arena.releaseAll();
        return WaywingResponse.ok(resp);
      },
    ),
  };


  ManualValueNotifier<List<(Pointer<Uint8>, int)>> items = ManualValueNotifier([]);
  Completer<String>? response;

  @override
  ValueListenable<List<FeatherComponent>> get components => DummyValueNotifier([
    FeatherComponent(
      buildPopover: (context) {
        return Menu(
          items: items,
          onSelected: (selected) {
            response?.complete(selected.$1.cast<Utf8>().toDartString(length: selected.$2));
          },
        );
      },
    ),
  ]);
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
