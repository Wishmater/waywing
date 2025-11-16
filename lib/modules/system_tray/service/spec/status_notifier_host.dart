import "dart:async";

import "package:dbus/dbus.dart";
import "package:tronco/tronco.dart";
import "package:waywing/modules/system_tray/service/spec/istatus_notifier_item.dart";
import "package:waywing/modules/system_tray/service/spec/istatus_notifier_watcher.dart";
import "package:waywing/modules/system_tray/service/spec/status_notifier_watcher.dart";
import "package:waywing/modules/system_tray/service/status_item.dart";
import "package:waywing/util/derived_value_notifier.dart";

class OrgKdeStatusNotifierHostImpl extends DBusObject {
  late final OrgKdeStatusNotifierWatcher _watcher;
  late final _DBusUnRegistrationWatcher _dBusWatcher;

  // final Map<String, OrgKdeStatusNotifierItemValues> _items;
  ManualValueNotifier<List<OrgKdeStatusNotifierItemValues>> items;
  final Logger logger;

  final List<StreamSubscription> _subscriptions;

  OrgKdeStatusNotifierHostImpl(this.logger, super.path)
    : items = ManualValueNotifier([]),
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
    _dBusWatcher = _DBusUnRegistrationWatcher(client!);
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
    _dBusWatcher.dispose();
    // _items.clear();
  }

  Future<void> _addItem(String itemPath) async {
    logger.debug("Host addItem $itemPath");
    final (destination, path) = OrgKdeStatusNotifierItem.splitItemStr(itemPath);

    if (items.value.indexWhere((e) => e.originalPath == itemPath) != -1) {
      logger.debug("item already in list");
      return;
    }

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
      await itemValues.initFields();
    } catch(e, st) {
      logger.error("initFields failed", error: e, stackTrace: st);
      return;
    }
    if (itemValues.failed) {
      logger.warning("initFields failed");
      return;
    }
    items.value.add(itemValues);
    _dBusWatcher.registerWatch(destination, (_, newOwner) {
      if (newOwner == null) {
        logger.debug("item got out of dbus ${itemValues.originalPath}");
        _removeItem(itemValues.originalPath);
      }
    });
    items.manualNotifyListeners();
  }

  void _removeItem(String itemPath) {
    final index = items.value.indexWhere((e) => e.originalPath == itemPath);
    if (index == -1) {
      return;
    }
    items.value.removeAt(index).dispose();
    items.manualNotifyListeners();
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

typedef _Callback = void Function(String? oldName, String? newName);
class _DBusUnRegistrationWatcher {
  final DBusClient _client;
  final Map<String, _Callback> _toWatch;
  late final StreamSubscription _subscription;

  _DBusUnRegistrationWatcher(this._client) : _toWatch = {} {
    _subscription = _client.nameOwnerChanged.listen((event) {
      _toWatch[event.name]?.call(event.oldOwner, event.newOwner);
      _toWatch.remove(event.name);
    });
  }

  void dispose() {
    _subscription.cancel().then((_) => _client.close());
  }

  void registerWatch(String dbusname, _Callback cb, [String? debugName]) {
    if (!_toWatch.containsKey(dbusname)) {
      _toWatch[dbusname] = cb;
    }
  }
}
