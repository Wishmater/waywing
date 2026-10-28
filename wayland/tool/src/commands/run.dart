import 'package:args/args.dart';

import '../tool.dart';

class RunCommand extends ToolCommand {
  // The host forwards everything after `run` to Dart's main(List<String> args),
  // so the command must not try to interpret those arguments as its own.
  final _passthrough = ArgParser.allowAnything();

  @override
  String get name => 'run';

  @override
  String get description => 'Refresh the launch manifest and run the host.';

  @override
  String get invocation =>
      'dart wayland/tool/wayland.dart run [dart arguments...]';

  @override
  ArgParser get argParser => _passthrough;

  @override
  Future<void> run() async {
    final args = argResults!.rest;
    final buildManifest = readManifest(tool.paths.launchBuildFile);
    final installedManifest = readManifest(tool.paths.launchFile);
    final fallback = installedManifest ?? buildManifest;
    final appName = stringField(fallback, 'app_name') ?? 'app';
    // A manifest with an AOT snapshot is a release build: keep the paths it
    // recorded instead of re-resolving them through the debug FILO_* values.
    final manifest = stringField(fallback, 'aot') == null
        ? tool.resolveLaunch(appName: appName, fallback: fallback)
        : tool.launchManifest(
            appName: appName,
            engine: requireValue(
              stringField(fallback, 'engine'),
              'the launch manifest has no engine path',
            ),
            icu: requireValue(
              stringField(fallback, 'icu'),
              'the launch manifest has no ICU data path',
            ),
            assets: requireValue(
              stringField(fallback, 'assets'),
              'the launch manifest has no assets path',
            ),
            aot: stringField(fallback, 'aot'),
            fallback: fallback,
          );
    writeJson(tool.paths.launchFile, manifest);

    final host = tool.resolveHost(appName);
    await startAndWait(host, args, workingDirectory: tool.paths.appRoot);
  }
}
