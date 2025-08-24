import "package:dbus/dbus.dart";

class OrgFreedesktopApplication extends DBusRemoteObject {
  OrgFreedesktopApplication(super.client, String destination, DBusObjectPath path) : super(name: destination, path: path);

  /// Invokes org.freedesktop.Application.Activate()
  Future<void> callActivate(Map<String, DBusValue> platform_data, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.Application", "Activate", [DBusDict.stringVariant(platform_data)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Application.Open()
  Future<void> callOpen(List<String> uris, Map<String, DBusValue> platform_data, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.Application", "Open", [DBusArray.string(uris), DBusDict.stringVariant(platform_data)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.Application.ActivateAction()
  Future<void> callActivateAction(String action_name, List<DBusValue> parameter, Map<String, DBusValue> platform_data, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod("org.freedesktop.Application", "ActivateAction", [DBusString(action_name), DBusArray.variant(parameter), DBusDict.stringVariant(platform_data)], replySignature: DBusSignature(""), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }
}
