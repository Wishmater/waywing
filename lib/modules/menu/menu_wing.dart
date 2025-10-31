import "dart:async";
import "dart:convert";

import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/searchopts/searchopts.dart";

// TODO: 1 this shouldn't be a Wing, it should instead be used in a modal, like AppLauncher
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

  @override
  late final Map<String, WaywingAction>? actions = {
    "activate": WaywingAction(
      "Show menu",
      (request) async {
        if (response != null) return WaywingResponse(400, "menu is already showing");

        showMenu.value = true;
        response = Completer();

        final subs = request.body
            .cast<List<int>>()
            .transform(utf8.decoder)
            .listen(
              (chunk) {
                if (response == null || chunk.codeUnits.isEmpty) return;

                for (final line in chunk.split("\n")) {
                  if (line.isNotEmpty) {
                    items.value.add(line);
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
        showMenu.value = false;
        items.value.clear();
        subs.cancel().onError((_, _) {});
        return WaywingResponse.ok(resp);
      },
    ),
  };

  ValueNotifier<bool> showMenu = ValueNotifier(false);

  ManualValueNotifier<List<String>> items = ManualValueNotifier([]);
  Completer<String>? response;

  @override
  Widget buildWing(BuildContext context, EdgeInsets rerservedSpace) {
    return ValueListenableBuilder(
      valueListenable: showMenu,
      builder: (context, show, _) {
        if (!show) {
          return SizedBox.shrink();
        }
        return Center(
          child: InputRegion(
            child: KeyboardFocus(
              debugLabel: "Menu",
              mode: KeyboardFocusMode.onDemand,
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.escape): () {
                    response?.complete("");
                  },
                },
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: Menu(
                    items: items,
                    onSelected: (selected) {
                      response?.complete(selected);
                    },
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
  final ManualValueNotifier<List<String>> items;
  final Function(String) onSelected;

  const Menu({super.key, required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: items,
      builder: (context, value, _) {
        return SearchOptions(
          options: Option.fromString(value),
          onSelected: onSelected,
          height: 400.0,
          renderOption: (context, value, config) {
            return ListTile(title: Text(value, overflow: TextOverflow.ellipsis, maxLines: 1));
          },
        );
      },
    );
  }
}
