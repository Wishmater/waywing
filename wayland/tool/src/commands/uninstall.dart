import "dart:io";

import "../tool.dart";

class UninstallCommand extends ToolCommand {
  @override
  String get name => "uninstall";

  @override
  String get description => "Remove the per-run launch state.";

  @override
  String get invocation => "dart wayland/tool/wayland.dart uninstall <appName>";

  @override
  void run() {
    final args = argResults!.rest;
    expectCount(args, 1);
    final directory = Directory("${tool.paths.waylandDir}/.filo");
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }
}
