import "dart:async";

import "package:dbus/dbus.dart";

class OrgKdeStatusNotifierWatcherImpl extends DBusObject {
  final List<DBusString> itemRegister;
  final List<DBusString> hostRegister;
  final _DBusRegistrationWatcher _registrationWatcher;

  static const String interfaceName = "org.kde.StatusNotifierWatcher";
  static final DBusObjectPath objectPath = DBusObjectPath("/StatusNotifierWatcher");

  /// Creates a new object to expose on [path].
  OrgKdeStatusNotifierWatcherImpl({DBusObjectPath path = const DBusObjectPath.unchecked("/")})
    : itemRegister = [],
      hostRegister = [],
      _registrationWatcher = _DBusRegistrationWatcher(),
      super(path);

  void dispose() {
    _registrationWatcher.dispose();
  }

  /// Gets value of property org.kde.StatusNotifierWatcher.RegisteredStatusNotifierItems
  Future<DBusMethodResponse> getRegisteredStatusNotifierItems() async {
    return DBusMethodSuccessResponse([DBusArray(DBusSignature.string, itemRegister)]);
  }

  /// Gets value of property org.kde.StatusNotifierWatcher.IsStatusNotifierHostRegistered
  Future<DBusMethodResponse> getIsStatusNotifierHostRegistered() async {
    return DBusMethodSuccessResponse([DBusBoolean(hostRegister.isNotEmpty)]);
  }

  /// Gets value of property org.kde.StatusNotifierWatcher.ProtocolVersion
  Future<DBusMethodResponse> getProtocolVersion() async {
    return DBusMethodSuccessResponse([DBusInt32(0)]);
  }

  /// Implementation of org.kde.StatusNotifierWatcher.RegisterStatusNotifierItem()
  Future<DBusMethodResponse> doRegisterStatusNotifierItem(String service) async {
    final val = DBusString(service);
    if (!itemRegister.contains(val)) {
      itemRegister.add(DBusString(service));
      emitStatusNotifierItemRegistered(service);

      _registrationWatcher.registerWatch(service, (_, newName) {
        if (newName == null) {
          emitStatusNotifierItemUnregistered(service);
        }
      });
    }
    return DBusMethodSuccessResponse([]);
  }

  /// Implementation of org.kde.StatusNotifierWatcher.RegisterStatusNotifierHost()
  Future<DBusMethodResponse> doRegisterStatusNotifierHost(String service) async {
    final val = DBusString(service);
    if (!hostRegister.contains(val)) {
      final wasEmpty = hostRegister.isEmpty;
      hostRegister.add(val);
      if (wasEmpty) {
        emitStatusNotifierHostRegistered();
      }

      _registrationWatcher.registerWatch(service, (_, newName) {
        if (newName == null) {
          emitStatusNotifierItemUnregistered(service);
        }
      });
    }
    return DBusMethodSuccessResponse([]);
  }

  /// Emits signal org.kde.StatusNotifierWatcher.StatusNotifierItemRegistered
  Future<void> emitStatusNotifierItemRegistered(String arg_0) async {
    await emitSignal("org.kde.StatusNotifierWatcher", "StatusNotifierItemRegistered", [DBusString(arg_0)]);
  }

  /// Emits signal org.kde.StatusNotifierWatcher.StatusNotifierItemUnregistered
  Future<void> emitStatusNotifierItemUnregistered(String arg_0) async {
    await emitSignal("org.kde.StatusNotifierWatcher", "StatusNotifierItemUnregistered", [DBusString(arg_0)]);
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
        return doRegisterStatusNotifierItem(methodCall.values[0].asString());
      } else if (methodCall.name == "RegisterStatusNotifierHost") {
        if (methodCall.signature != DBusSignature("s")) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doRegisterStatusNotifierHost(methodCall.values[0].asString());
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
      final cb = _toWatch[event.name];
      if (cb != null) {
        cb(event.oldOwner, event.newOwner);
      }
    });
  }

  void dispose() {
    _subscription.cancel().then((_) => _client.close());
  }

  registerWatch(String service, _Callback cb) {
    _toWatch[service] = cb;
  }
}
