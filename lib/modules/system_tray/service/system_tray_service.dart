import "package:dbus/dbus.dart";
import "package:flutter/material.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/system_tray/service/istatus_notifier_item.dart";
import "package:waywing/modules/system_tray/service/status_notifier_host.dart";
import "package:waywing/modules/system_tray/service/status_notifier_watcher.dart";
import "package:waywing/util/slice.dart";

class SystemTrayItem {
  String id;
  String name;
  String status;
  String? iconId;
  String? category;

  String? menuPath;

  SystemTrayItem({
    required this.id,
    required this.name,
    required this.status,
    this.iconId,
    this.category,
    this.menuPath,
  });
}

class SystemTrayService extends Service {

  SystemTrayService._();

  static registerService(RegisterServiceCallback registerService) {
    registerService<SystemTrayService, dynamic>(
      ServiceRegistration(
        constructor: SystemTrayService._,
      ),
    );
  }

  late DBusClient _client;
  OrgKdeStatusNotifierWatcherImpl? _watcher;
  late OrgKdeStatusNotifierHostImpl _host;
  late StatusNotifierItemsValues values;

  @override
  Future<void> init() async {
    _client = DBusClient.session();
    final reply = await _client.requestName(
      OrgKdeStatusNotifierWatcherImpl.interfaceName,
      flags: {DBusRequestNameFlag.doNotQueue},
    );

    if (reply == DBusRequestNameReply.alreadyOwner || reply == DBusRequestNameReply.primaryOwner) {
      _watcher = OrgKdeStatusNotifierWatcherImpl(path: OrgKdeStatusNotifierWatcherImpl.objectPath);
      await _client.registerObject(_watcher!);
    }

    await _client.requestName("shell.waywing.StatusNotifierHost");
    try {
      _host = OrgKdeStatusNotifierHostImpl(DBusObjectPath("/"));
    } catch(e,st) {
      logger.fatal('DBusObjectPath("shell.waywing.StatusNotifierHost") failed', error: e, stackTrace: st);
    }
    await _client.registerObject(_host);
    await _host.init();

    values = StatusNotifierItemsValues(_host);
  }

  @override
  Future<void> dispose() async {
    if (_watcher != null) {
      await _client.unregisterObject(_watcher!);
      await _client.releaseName(OrgKdeStatusNotifierWatcherImpl.interfaceName);
      _watcher!.dispose();
    }
    await _client.close();
    await logger.destroy();
  }
}

class StatusNotifierItemsValues {
  final OrgKdeStatusNotifierHostImpl host;

  StatusNotifierItemsValues(this.host);

  ValueNotifier<Slice<OrgKdeStatusNotifierItem>> get items => host.items;
}
