import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';

import '../tool.dart';

class SetupFiloCommand extends ToolCommand {
  final _argParser = ArgParser()
    ..addFlag(
      'check',
      negatable: false,
      help: 'Run a fast build-graph check after fetching.',
    );

  @override
  String get name => 'setup-filo';

  @override
  String get description =>
      'Fetch filo, pin its hash, and initialize the package identity.';

  @override
  String get invocation =>
      'dart wayland/tool/wayland.dart setup-filo [--check] <filo-package-url>';

  @override
  ArgParser get argParser => _argParser;

  @override
  Future<void> run() async {
    final args = argResults!.rest;
    expectCount(args, 1);
    final check = argResults!['check'] as bool;

    final manifest = File('${tool.paths.waylandDir}/build.zig.zon');
    if (!manifest.existsSync()) {
      throw ToolError('${manifest.path} not found');
    }

    // Zig validates the fingerprint against the package name. Fix both before
    // fetching so zig fetch does not parse the template placeholders.
    final before = _ensureIdentity(manifest, tool.appName());
    if (before.changed) {
      stdout.writeln(
        '$toolName: package ${before.name}, fingerprint 0x${before.fingerprint}',
      );
    }

    await runInherited(
      'zig',
      ['fetch', '--save=filo', args[0]],
      workingDirectory: tool.paths.waylandDir,
      missingMessage: 'zig is not on PATH',
    );

    // zig fetch preserves the other manifest fields, but re-check in case it
    // rewrote formatting or the file changed underneath us.
    final after = _ensureIdentity(manifest, tool.appName());
    stdout.writeln(
      '$toolName: package ${after.name}, fingerprint 0x${after.fingerprint}',
    );
    final fetched = manifest.readAsStringSync();
    final hash = RegExp(
      r'\.hash\s*=\s*"([^"]+)"',
    ).firstMatch(fetched)?.group(1);
    if (hash != null) {
      stdout.writeln('$toolName: hash $hash');
    }
    stdout.writeln('$toolName: fetched filo from ${args[0]}');

    if (check) {
      await _checkBuildGraph(tool.paths.waylandDir);
      stdout.writeln('$toolName: build graph OK');
    }
  }
}

Future<void> _checkBuildGraph(String waylandDir) async {
  final ProcessResult result;
  try {
    result = await Process.run(
      'zig',
      ['build', '--help'],
      workingDirectory: waylandDir,
    );
  } on ProcessException {
    throw ToolError('zig is not on PATH');
  }
  if (result.exitCode != 0) {
    final output = '${result.stdout}${result.stderr}'.trim();
    if (output.isNotEmpty) stderr.writeln(output);
    throw ToolError(
      'zig build --help failed with exit code ${result.exitCode}',
    );
  }
}

class _Identity {
  _Identity(this.name, this.fingerprint, this.changed);

  final String name;
  final String fingerprint;
  final bool changed;
}

_Identity _ensureIdentity(File manifest, String appName) {
  var text = manifest.readAsStringSync();
  var changed = false;

  final namePattern = RegExp(r'\.name\s*=\s*\.([A-Za-z0-9_]+)');
  var nameMatch = namePattern.firstMatch(text);
  var name = nameMatch?.group(1);
  if (name == null || name == 'filo_wayland_host') {
    name = _packageName(appName);
    if (nameMatch == null) {
      text = _insertAfterVersion(text, '.name = .$name,');
    } else {
      text =
          text.replaceRange(nameMatch.start, nameMatch.end, '.name = .$name');
    }
    changed = true;
  }

  final fingerprintPattern = RegExp(r'\.fingerprint\s*=\s*0x([0-9a-fA-F]+)');
  final fingerprintMatch = fingerprintPattern.firstMatch(text);
  var fingerprint = fingerprintMatch?.group(1);
  if (fingerprint == null || !_validFingerprint(name, fingerprint)) {
    fingerprint = _generateFingerprint(name);
    if (fingerprintMatch == null) {
      text = _insertAfterVersion(text, '.fingerprint = 0x$fingerprint,');
    } else {
      text = text.replaceRange(
        fingerprintMatch.start,
        fingerprintMatch.end,
        '.fingerprint = 0x$fingerprint',
      );
    }
    changed = true;
  }

  // The template used to ship a placeholder filo dependency. zig fetch
  // parses the manifest before adding the real URL/hash, so clear the
  // placeholder first.
  if (text.contains('<hash>') || text.contains('#<commit>')) {
    final placeholder = RegExp(
      r'\.dependencies\s*=\s*\.\{\s*\.filo\s*=\s*\.\{.*?\}\s*,?\s*\}\s*,',
      dotAll: true,
    );
    final replaced = text.replaceFirst(placeholder, '.dependencies = .{},');
    if (replaced == text) {
      throw ToolError(
        'could not clear the placeholder filo dependency from build.zig.zon',
      );
    }
    text = replaced;
    changed = true;
  }

  if (changed) manifest.writeAsStringSync(text);
  return _Identity(name, fingerprint, changed);
}

String _insertAfterVersion(String text, String field) {
  final versionLine = RegExp(
    r'^(\s*)\.version\s*=.*$',
    multiLine: true,
  ).firstMatch(text);
  if (versionLine == null) {
    throw ToolError('build.zig.zon has no .version field');
  }
  final indent = versionLine.group(1) ?? '    ';
  return text.replaceRange(
    versionLine.end,
    versionLine.end,
    '\n$indent$field',
  );
}

String _packageName(String appName) {
  var base = appName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  if (base.isEmpty || !RegExp(r'^[a-z_]').hasMatch(base)) {
    base = 'app_$base';
  }
  const suffix = '_wayland';
  if (base.length + suffix.length > 32) {
    base = base.substring(0, 32 - suffix.length);
  }
  return '$base$suffix';
}

bool _validFingerprint(String name, String hex) {
  final value = BigInt.tryParse(hex, radix: 16);
  if (value == null || value.isNegative || value.bitLength > 64) {
    return false;
  }
  final id = (value & BigInt.from(0xffffffff)).toInt();
  final checksum = (value >> 32).toInt() & 0xffffffff;
  return id != 0 && id != 0xffffffff && checksum == _crc32(name);
}

String _generateFingerprint(String name) {
  final checksum = _crc32(name);
  final id = Random.secure().nextInt(0xfffffffe) + 1;
  final value = (BigInt.from(checksum) << 32) | BigInt.from(id);
  return value.toRadixString(16).padLeft(16, '0');
}

int _crc32(String text) {
  var crc = 0xffffffff;
  for (final byte in utf8.encode(text)) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xedb88320 : crc >> 1;
    }
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}
