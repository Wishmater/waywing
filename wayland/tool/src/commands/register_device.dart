import "dart:io";

import "../tool.dart";

class RegisterDeviceCommand extends ToolCommand {
  @override
  String get name => "register-device";

  @override
  String get description => "Register the global filo_wayland custom device.";

  @override
  String get invocation => "dart wayland/tool/wayland.dart register-device";

  @override
  bool get takesArguments => false;

  @override
  Future<void> run() async {
    final customDevice = File(tool.paths.customDeviceFile);
    if (!customDevice.existsSync()) {
      throw ToolError("${customDevice.path} not found");
    }
    final json = customDevice.readAsStringSync();

    await runQuiet("flutter", [
      "config",
      "--enable-custom-devices",
    ], workingDirectory: tool.paths.appRoot);
    // `custom-devices add` appends, so drop an older entry with the same id.
    await runQuiet(
      "flutter",
      ["custom-devices", "delete", "-d", "filo_wayland"],
      workingDirectory: tool.paths.appRoot,
      allowFailure: true,
    );
    await runInherited(
      "flutter",
      ["custom-devices", "add", "--json", json, "--check"],
      workingDirectory: tool.paths.appRoot,
      missingMessage: "flutter is not on PATH",
    );
  }
}
