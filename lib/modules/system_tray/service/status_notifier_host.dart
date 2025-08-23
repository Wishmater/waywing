import "dart:async";

import "package:dbus/dbus.dart";
import "package:flutter/foundation.dart" hide StringProperty;
import "package:tronco/tronco.dart";
import "package:waywing/modules/system_tray/service/istatus_notifier_item.dart";
import "package:waywing/modules/system_tray/service/istatus_notifier_watcher.dart";
import "package:waywing/modules/system_tray/service/status_notifier_watcher.dart";
import "package:waywing/util/derived_value_notifier.dart";

class OrgKdeStatusNotifierHostImpl extends DBusObject {
  late final OrgKdeStatusNotifierWatcher _watcher;

  // final Map<String, OrgKdeStatusNotifierItemValues> _items;
  ValueListenable<List<OrgKdeStatusNotifierItemValues>> items;
  final Logger logger;

  final List<StreamSubscription> _subscriptions;

  OrgKdeStatusNotifierHostImpl(this.logger, super.path)
    : items = _ManualValueNotifier([]),
      _subscriptions = [];

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
    for (final item in items.value) {
      item.dispose();
    }
    // _items.clear();
  }

  Future<void> _addItem(String itemPath) async {
    logger.debug("Host addItem $itemPath");
    final (destination, path) = OrgKdeStatusNotifierItem.splitItemStr(itemPath);

    // check name owner exists
    if ((await client!.getNameOwner(destination)) == null) {
      logger.warning("no name owner for $destination");
      return;
    }

    final item = OrgKdeStatusNotifierItem(client!, destination, path);

    OrgKdeStatusNotifierItemValues itemValues;
    try {
      itemValues = OrgKdeStatusNotifierItemValues(
        item,
        logger.clone(
          properties: [
            ...logger.defaultProperties,
            StringProperty("OrgKdeStatusNotifierItemValues $itemPath")
          ],
        ),
        itemPath,
      );
    } catch (e, st) {
      logger.error("failed to initialize OrgKdeStatusNotifierItem", error: e, stackTrace: st);
      return;
    }
    try {
      itemValues.initFields();
    } catch(e, st) {
      logger.error("initFields failed", error: e, stackTrace: st);
    }
    items.value.add(itemValues);
    (items as _ManualValueNotifier)._manualNotifyListeners();
  }

  void _removeItem(String itemPath) {
    final index = items.value.indexWhere((e) => e.originalPath == itemPath);
    if (index == -1) {
      return;
    }
    items.value.removeAt(index).dispose();
    (items as _ManualValueNotifier)._manualNotifyListeners();
  }

  Future<void> _fillStatusNotifierItems() async {
    final itemsPath = await _watcher.getRegisteredStatusNotifierItems();
    logger.debug("_fillStatusNotifierItems $itemsPath");
    for (final itemPath in itemsPath) {
      await _addItem(itemPath);
    }

    // listen to signal of new registered item
    _subscriptions.add(
      _watcher.statusNotifierItemRegistered.listen((v) async {
        await _addItem(v.arg_0);
      }),
    );
    // listen to signal of unregistered item
    _subscriptions.add(
      _watcher.statusNotifierItemUnregistered.listen((v) {
        _removeItem(v.arg_0);
      }),
    );
  }
}

class _ManualValueNotifier<T> extends DummyValueNotifier<T> {
  _ManualValueNotifier(super.value);

  void _manualNotifyListeners() {
    notifyListeners();
  }
}
