import "dart:async";

import "package:dbus/dbus.dart";
import "package:flutter/material.dart";
import "package:waywing/modules/system_tray/service/istatus_notifier_item.dart";
import "package:waywing/modules/system_tray/service/istatus_notifier_watcher.dart";
import "package:waywing/modules/system_tray/service/status_notifier_watcher.dart";
import "package:waywing/util/slice.dart";

class OrgKdeStatusNotifierHostImpl extends DBusObject {
  late final OrgKdeStatusNotifierWatcher _watcher;

  final Map<String, OrgKdeStatusNotifierItem> _items;
  ValueNotifier<Slice<OrgKdeStatusNotifierItem>> items;

  final List<StreamSubscription> _subscriptions;

  OrgKdeStatusNotifierHostImpl(super.path) : _items = {}, items = ValueNotifier(Slice([])), _subscriptions = [];

  /// Init all resources needed to work normally
  ///
  /// Needs to be registered first
  Future<void> init() async {
    assert(client != null);
    _watcher = OrgKdeStatusNotifierWatcher(
      client!,
      OrgKdeStatusNotifierWatcherImpl.interfaceName,
      OrgKdeStatusNotifierWatcherImpl.objectPath,
    );
    await _fillStatusNotifierItems();
  }

  /// Init all resources needed to work normally
  ///
  /// Does not handle deregistration.
  /// Caller needs to handle that as it needs to handle registration too
  void dispose() {
    for (var e in _subscriptions) {
      e.cancel();
    }
    items.dispose();
  }

  void _addItem(String itemPath) {
    final (destination, path) = OrgKdeStatusNotifierItem.splitItemStr(itemPath);
    _items[itemPath] = OrgKdeStatusNotifierItem(client!, destination, path);
  }

  void _removeItem(String itemPath) {
    _items.remove(itemPath);
  }

  Future<void> _fillStatusNotifierItems() async {
    final itemsPath = await _watcher.getRegisteredStatusNotifierItems();
    for (final itemPath in itemsPath) {
      _addItem(itemPath);
    }
    items.value = Slice(_items.values);

    // listen to signal of new registered item
    _subscriptions.add(
      _watcher.statusNotifierItemRegistered.listen((v) {
        _addItem(v.arg_0);
        items.value = Slice(_items.values);
      }),
    );
    // listen to signal of unregistered item
    _subscriptions.add(
      _watcher.statusNotifierItemUnregistered.listen((v) {
        _removeItem(v.arg_0);
        items.value = Slice(_items.values);
      }),
    );
  }
}
