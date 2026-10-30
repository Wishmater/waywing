import 'dart:io';

import '../tool.dart';

class RegisterDeviceCommand extends ToolCommand {
  @override
  String get name => 'register-device';

  @override
  String get description => 'Register the global filo_wayland custom device.';

  @override
  String get invocation => 'dart wayland/tool/wayland.dart register-device';

  @override
  bool get takesArguments => false;

  @override
  Future<void> run() async {
    final customDevice = File(tool.paths.customDeviceFile);
    if (!customDevice.existsSync()) {
      throw ToolError('${customDevice.path} not found');
    }
    final json = customDevice.readAsStringSync();

    await runQuiet('flutter', [
      'config',
      '--enable-custom-devices',
    ], workingDirectory: tool.paths.appRoot);
    // `custom-devices add` appends, so drop an older entry with the same id.
    await runQuiet(
      'flutter',
      ['custom-devices', 'delete', '-d', 'filo_wayland'],
      workingDirectory: tool.paths.appRoot,
      allowFailure: true,
    );
    await runInherited(
      'flutter',
      ['custom-devices', 'add', '--json', json, '--check'],
      workingDirectory: tool.paths.appRoot,
      missingMessage: 'flutter is not on PATH',
    );
  }
}


Future<void> runQuiet(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
  bool allowFailure = false,
}) async {
  final ProcessResult result;
  try {
    result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
    );
  } on ProcessException {
    throw ToolError('$executable is not on PATH');
  }
  if (result.exitCode == 0 || allowFailure) return;
  final output = '${result.stdout}${result.stderr}'.trim();
  throw ToolError(
    '$executable ${arguments.join(' ')} failed with exit code '
    '${result.exitCode}${output.isEmpty ? '' : ':\n$output'}',
  );
}
