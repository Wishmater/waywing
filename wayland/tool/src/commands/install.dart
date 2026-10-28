import '../tool.dart';

class InstallCommand extends ToolCommand {
  @override
  String get name => 'install';

  @override
  String get description => 'Record the exact assets Flutter just built.';

  @override
  String get invocation =>
      'dart wayland/tool/wayland.dart install <appName> <localPath>';

  @override
  void run() {
    final args = argResults!.rest;
    expectCount(args, 2);
    final appName = args[0];
    final localPath = args[1].isEmpty ? null : args[1];
    final fallback = readManifest(tool.paths.launchBuildFile);
    final manifest = tool.resolveLaunch(
      appName: appName,
      localPath: localPath,
      fallback: fallback,
    );
    writeJson(tool.paths.launchFile, manifest);
  }
}
