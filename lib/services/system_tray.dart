import 'package:dbus/dbus.dart';

final systemTray = SystemTrayService();

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

class SystemTrayService {
  Future<void>? _initFuture;
  late DBusClient _client;
  late _StatusNotifierWatcherObject _watcher;

  Future<void> ensureInitialized() {
    _initFuture ??= _init();
    return _initFuture!;
  }

  Future<void> _init() async {
    _client = DBusClient.session();
    await _client.requestName(_StatusNotifierWatcherObject.objectname);
    _watcher = _StatusNotifierWatcherObject(
      onRegisterStatusNotifierItem: onRegisterStatusNotifierItem,
    );
    await _client.registerObject(_watcher);
  }

  Future<void> dispose() async {
    if (_initFuture != null) await _initFuture;
    await _client.unregisterObject(_watcher);
    await _client.releaseName(_StatusNotifierWatcherObject.objectname);
    await _client.close();
  }

  List<String> get items => [];

  Future<void> onRegisterStatusNotifierItem(String? sender, List<String> values) async {
    final service = values.first;
    final parts = service.split('/');
    final serviceName = parts[0];
    final path = '/${parts.sublist(1).join('/')}';
    print('');
    print('parsed item $service\nserviceName=$serviceName\npath=$path');
    getItemDetails(sender ?? service, path);
  }

  Future<void> getItemDetails(String name, String path) async {
    final object = DBusRemoteObject(
      _client,
      name: name,
      path: DBusObjectPath(path),
    );
    // Fetch all StatusNotifierItem properties
    var properties = await object.getAllProperties('org.kde.StatusNotifierItem');
    print(properties);
  }

  Future<void> getMenuItems(Map<String, dynamic> properties) async {
    // Fetch menu items if Menu property exists
    List<Map<String, dynamic>> menuItems = [];
    if (properties['Menu'] != null) {
      var menuPath = properties['Menu']!.asObjectPath();
      // menuItems = await _fetchMenuItems(service, menuPath);
    }
  }
}

typedef _StandardWatcherCallback = void Function(String? sender, List<String> values);

class _StatusNotifierWatcherObject extends DBusObject {
  static const objectname = 'org.kde.StatusNotifierWatcher';
  // static const objectname = 'org.kde.StatusNotifierWatcher';
  static const objectpath = '/StatusNotifierWatcher';

  final _StandardWatcherCallback onRegisterStatusNotifierItem;
  final List<String> registeredItems = [];

  _StatusNotifierWatcherObject({
    required this.onRegisterStatusNotifierItem,
  }) : super(DBusObjectPath(objectpath));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
    objectname: {
      'ProtocolVersion': DBusInt32(0),
      'IsStatusNotifierHostRegistered': DBusBoolean(true),
      'RegisteredStatusNotifierItems': DBusArray.string(registeredItems),
    },
  };

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    print('received method call: $methodCall ${methodCall.interface} ${methodCall.name}');
    if (methodCall.interface == _StatusNotifierWatcherObject.objectname) {
      if (methodCall.name == 'RegisterStatusNotifierItem') {
        final stringValues = methodCall.values.map((e) => e.asString()).toList();
        onRegisterStatusNotifierItem(methodCall.sender, stringValues);
        return DBusMethodSuccessResponse();
      }

      // if (methodCall.name == 'RegisterStatusNotifierHost') {
      //   var host = methodCall.values[0].asString();
      // }

      print('unknownMethod: ${methodCall.name}: ${methodCall.values}');
    }
    return DBusMethodErrorResponse.unknownMethod();
  }
}
