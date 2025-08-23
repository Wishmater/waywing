import "dart:async";

import "package:dbus/dbus.dart";
// ignore: implementation_imports
import "package:dbus/src/dbus_bus_name.dart";
import "package:tronco/tronco.dart";

class OrgKdeStatusNotifierWatcherImpl extends DBusObject {
  final List<DBusString> itemRegister;
  final List<DBusString> hostRegister;
  final _DBusRegistrationWatcher _registrationWatcher;
  final Logger logger;

  static const String interfaceName = "org.kde.StatusNotifierWatcher";
  static final DBusObjectPath objectPath = DBusObjectPath("/StatusNotifierWatcher");

  /// Creates a new object to expose on [path].
  OrgKdeStatusNotifierWatcherImpl(this.logger, {DBusObjectPath path = const DBusObjectPath.unchecked("/")})
    : itemRegister = [],
      hostRegister = [],
      _registrationWatcher = _DBusRegistrationWatcher(),
      super(path);

  void dispose() {
    _registrationWatcher.dispose();
  }

  /// Gets value of property org.kde.StatusNotifierWatcher.RegisteredStatusNotifierItems
  Future<DBusMethodResponse> getRegisteredStatusNotifierItems() async {
    logger.debug("doRegisterStatusNotifierItem $itemRegister");
    return DBusGetPropertyResponse(DBusArray(DBusSignature.string, itemRegister));
  }

  /// Gets value of property org.kde.StatusNotifierWatcher.IsStatusNotifierHostRegistered
  Future<DBusMethodResponse> getIsStatusNotifierHostRegistered() async {
    logger.debug("getIsStatusNotifierHostRegistered");
    return DBusGetPropertyResponse(DBusBoolean(true));
  }

  /// Gets value of property org.kde.StatusNotifierWatcher.ProtocolVersion
  Future<DBusMethodResponse> getProtocolVersion() async {
    return DBusGetPropertyResponse(DBusInt32(0));
  }

  /// Implementation of org.kde.StatusNotifierWatcher.RegisterStatusNotifierItem()
  ///
  /// This implemenation is based on the waybar implementation
  Future<DBusMethodResponse> doRegisterStatusNotifierItem(DBusMethodCall methodCall, String service) async {
    logger.debug("doRegisterStatusNotifierItem $service");
    String busname = service;
    String objectPath = "/StatusNotifierItem";
    if (service.startsWith("/")) {
      busname = methodCall.sender ?? "";
      objectPath = service;
    }
    try {
      // validate dbusname
      final _ = DBusBusName(busname);
    } catch (_) {
      return DBusMethodErrorResponse.invalidArgs("D-Bus bus name '$busname' is not valid");
    }
    final val = DBusString("$busname$objectPath");

    if (!itemRegister.contains(val)) {
      itemRegister.add(val);
      emitStatusNotifierItemRegistered(val);

      _registrationWatcher.registerWatch(busname, (_, newName) {
        if (newName == null) {
          itemRegister.remove(val);
          emitStatusNotifierItemUnregistered(val);
        }
      }, "Status Notifier Item");
    }
    return DBusMethodSuccessResponse([]);
  }

  /// Implementation of org.kde.StatusNotifierWatcher.RegisterStatusNotifierHost()
  ///
  /// This implemenation is based on the waybar implementation
  Future<DBusMethodResponse> doRegisterStatusNotifierHost(DBusMethodCall methodCall, String service) async {
    logger.debug("doRegisterStatusNotifierHost $service");
    String busname = service;
    // String objectPath = "/StatusNotifierHost";
    if (service.startsWith("/")) {
      busname = methodCall.sender ?? "";
      // objectPath = service;
    }
    try {
      // validate dbusname
      final _ = DBusBusName(busname);
    } catch (_) {
      return DBusMethodErrorResponse.invalidArgs("D-Bus bus name '$busname' is not valid");
    }

    final val = DBusString(busname);
    if (!hostRegister.contains(val)) {
      final wasEmpty = hostRegister.isEmpty;
      hostRegister.add(val);
      if (wasEmpty) {
        emitStatusNotifierHostRegistered();
      }

      _registrationWatcher.registerWatch(busname, (_, newName) {
        if (newName == null) {
          if (hostRegister.remove(DBusString(busname)) == true && hostRegister.isEmpty) {
            emitStatusNotifierHostUnregistered();
          }
        }
      }, "Status Notifier Host");
    }
    return DBusMethodSuccessResponse([]);
  }

  /// Emits signal org.kde.StatusNotifierWatcher.StatusNotifierItemRegistered
  Future<void> emitStatusNotifierItemRegistered(DBusString arg_0) async {
    await emitSignal("org.kde.StatusNotifierWatcher", "StatusNotifierItemRegistered", [arg_0]);
  }

  /// Emits signal org.kde.StatusNotifierWatcher.StatusNotifierItemUnregistered
  Future<void> emitStatusNotifierItemUnregistered(DBusString arg_0) async {
    await emitSignal("org.kde.StatusNotifierWatcher", "StatusNotifierItemUnregistered", [arg_0]);
  }

  /// Emits signal org.kde.StatusNotifierWatcher.StatusNotifierHostRegistered
  Future<void> emitStatusNotifierHostRegistered() async {
    await emitSignal("org.kde.StatusNotifierWatcher", "StatusNotifierHostRegistered", []);
  }

  /// Emits signal org.kde.StatusNotifierWatcher.StatusNotifierHostUnregistered
  Future<void> emitStatusNotifierHostUnregistered() async {
    await emitSignal("org.kde.StatusNotifierWatcher", "StatusNotifierHostUnregistered", []);
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(
        "org.kde.StatusNotifierWatcher",
        methods: [
          DBusIntrospectMethod(
            "RegisterStatusNotifierItem",
            args: [DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.in_, name: "service")],
          ),
          DBusIntrospectMethod(
            "RegisterStatusNotifierHost",
            args: [DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.in_, name: "service")],
          ),
        ],
        signals: [
          DBusIntrospectSignal(
            "StatusNotifierItemRegistered",
            args: [DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.out)],
          ),
          DBusIntrospectSignal(
            "StatusNotifierItemUnregistered",
            args: [DBusIntrospectArgument(DBusSignature("s"), DBusArgumentDirection.out)],
          ),
          DBusIntrospectSignal("StatusNotifierHostRegistered"),
          DBusIntrospectSignal("StatusNotifierHostUnregistered"),
        ],
        properties: [
          DBusIntrospectProperty("RegisteredStatusNotifierItems", DBusSignature("as"), access: DBusPropertyAccess.read),
          DBusIntrospectProperty("IsStatusNotifierHostRegistered", DBusSignature("b"), access: DBusPropertyAccess.read),
          DBusIntrospectProperty("ProtocolVersion", DBusSignature("i"), access: DBusPropertyAccess.read),
        ],
      ),
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == "org.kde.StatusNotifierWatcher") {
      if (methodCall.name == "RegisterStatusNotifierItem") {
        if (methodCall.signature != DBusSignature("s")) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doRegisterStatusNotifierItem(methodCall, methodCall.values[0].asString());
      } else if (methodCall.name == "RegisterStatusNotifierHost") {
        if (methodCall.signature != DBusSignature("s")) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doRegisterStatusNotifierHost(methodCall, methodCall.values[0].asString());
      } else {
        return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == "org.kde.StatusNotifierWatcher") {
      if (name == "RegisteredStatusNotifierItems") {
        return getRegisteredStatusNotifierItems();
      } else if (name == "IsStatusNotifierHostRegistered") {
        return getIsStatusNotifierHostRegistered();
      } else if (name == "ProtocolVersion") {
        return getProtocolVersion();
      } else {
        return DBusMethodErrorResponse.unknownProperty();
      }
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async {
    if (interface == "org.kde.StatusNotifierWatcher") {
      if (name == "RegisteredStatusNotifierItems") {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == "IsStatusNotifierHostRegistered") {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else if (name == "ProtocolVersion") {
        return DBusMethodErrorResponse.propertyReadOnly();
      } else {
        return DBusMethodErrorResponse.unknownProperty();
      }
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    var properties = <String, DBusValue>{};
    if (interface == "org.kde.StatusNotifierWatcher") {
      properties["RegisteredStatusNotifierItems"] = (await getRegisteredStatusNotifierItems()).returnValues[0];
      properties["IsStatusNotifierHostRegistered"] = (await getIsStatusNotifierHostRegistered()).returnValues[0];
      properties["ProtocolVersion"] = (await getProtocolVersion()).returnValues[0];
    }
    return DBusMethodSuccessResponse([DBusDict.stringVariant(properties)]);
  }
}

typedef _Callback = void Function(String? oldName, String? newName);

class _DBusRegistrationWatcher {
  final DBusClient _client;
  final Map<String, _Callback> _toWatch;
  late final StreamSubscription _subscription;

  _DBusRegistrationWatcher() : _client = DBusClient.session(), _toWatch = {} {
    _subscription = _client.nameOwnerChanged.listen((event) {
      _toWatch[event.name]?.call(event.oldOwner, event.newOwner);
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
