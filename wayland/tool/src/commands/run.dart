import 'dart:async';
import 'dart:io';

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
  String get invocation => 'dart wayland/tool/wayland.dart run [dart arguments...]';

  @override
  ArgParser get argParser => _passthrough;

  @override
  Future<void> run() async {
    final args = argResults!.rest;
    final buildManifest = readManifest(tool.paths.launchBuildFile);
    final installedManifest = readManifest(tool.paths.launchFile);
    final fallback = installedManifest ?? buildManifest;
    final appName = fallback.fieldStr('app_name') ?? 'app';
    ;
    // A manifest with an AOT snapshot is a release build: keep the paths it
    // recorded instead of re-resolving them through the debug FILO_* values.
    final manifest = fallback.fieldStr('aot') == null
        ? tool.resolveLaunch(appName: appName, fallback: fallback)
        : tool.launchManifest(
            appName: appName,
            engine: fallback.fieldRequire('engine', 'the launch manifest has no engine path'),
            icu: fallback.fieldRequire('icu', 'the launch manifest has no ICU data path'),
            assets: fallback.fieldRequire('assets', 'the launch manifest has no assets path'),
            aot: fallback.fieldStr('aot'),
            fallback: fallback,
          );
    writeJson(tool.paths.launchFile, manifest);

    final host = tool.resolveHost(appName);
    await startAndWait(host, args, workingDirectory: tool.paths.appRoot);
  }
}


Future<void> startAndWait(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
}) async {
  final Process process;
  try {
    process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      mode: ProcessStartMode.inheritStdio,
    );
  } on ProcessException {
    throw ToolError('failed to run $executable');
  }

  final subscriptions = <StreamSubscription<ProcessSignal>>[];
  void forward(ProcessSignal signal) {
    try {
      subscriptions.add(
        signal.watch().listen((_) {
          process.kill(signal);
        }),
      );
    } on SignalException {
      // Signal is not supported on this platform; ignore it.
    }
  }

  forward(ProcessSignal.sigterm);
  forward(ProcessSignal.sigint);
  forward(ProcessSignal.sighup);

  final code = await process.exitCode;
  for (final subscription in subscriptions) {
    await subscription.cancel();
  }
  if (code != 0) {
    exitCode = code < 0 ? 128 - code : code;
  }
}
