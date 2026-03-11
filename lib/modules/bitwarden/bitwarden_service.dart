import "dart:async";
import "dart:convert";
import "dart:io";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:dartx/dartx_io.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/service.dart";
import "package:bitwarden_vault_api/bitwarden_api.dart" as bw;
import "package:freedesktop_secrets/freedesktop_secrets.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/util/type_utils.dart";

part "bitwarden_service.config.dart";

class BitwardenService extends Service<BitwardenServiceConfig> {
  BitwardenService._();

  static void registerService(RegisterServiceCallback registration) {
    registration<BitwardenService, dynamic>(
      ServiceRegistration(
        constructor: BitwardenService._,
        configBuilder: BitwardenServiceConfig.fromBlock,
        schemaBuilder: () => BitwardenServiceConfig.schema,
      ),
    );
  }

  late final bw.ApiClient apiClient;
  late final FreedesktopSecretsClient? secretsClient;
  late final FreedesktopSecretsCollection? defaultCollection;
  late BwRunner _bwRunner;

  @override
  Future<void> init() async {
    apiClient = bw.ApiClient(basePath: "http://localhost:8087");

    _bwRunner = await BwRunner.create(config.bwPath, dataDir, logger);
    // Hack to wait for bw start
    await Future.delayed(Duration(seconds: 2));

    try {
      final secretsClient = FreedesktopSecretsClient();
      await secretsClient.session.open();
      final defaultCollection = (await secretsClient.defaultCollection())!;
      this.secretsClient = secretsClient;
      this.defaultCollection = defaultCollection;
      if (await defaultCollection.locked) {
        throw DefaultCollectionLockedException(await defaultCollection.label);
      }
    } catch (e, st) {
      logger.warning(
        "Error while setting up secrets access.\n"
        "The Bitwarden feather will work, but it will have to ask for password every time.",
        error: e,
        stackTrace: st,
      );
      secretsClient = null;
      defaultCollection = null;
    }

    final _ = await getMasterPassword();
    if (hasMasterPassword) {
      await unlock();
    }
  }

  String? _masterPassword;
  bool get hasMasterPassword => _masterPassword != null;

  Future<String?> getMasterPassword() async {
    if (_masterPassword != null) return _masterPassword;
    if (secretsClient == null || defaultCollection == null) return null;

    final secrets = await defaultCollection!.search({"id": "waywing_bitwarden"});
    if (secrets.isEmpty) return null;

    final secret = await secrets[0].getSecret(secretsClient!.session);
    _masterPassword = utf8.decode(secret.decrypt().value);
    return _masterPassword;
  }

  Future<void> setMasterPassword(String password) async {
    if (_masterPassword == password) return;
    _masterPassword = password;
    if (secretsClient == null || defaultCollection == null) return;

    final secret = FreedesktopSecretDecrypted(session: secretsClient!.session, value: utf8.encode(password));
    final (item, prompt) = await defaultCollection!.createItem(
      secret,
      FreedesktopSecretsCreateItemProps("waywing_bitwarden", {"id": "waywing_bitwarden"}),
      true,
    );
    if (prompt != null) {
      await prompt.complete((_, _) {});
    }
  }

  Future<R> _callApi<R>(Future<R> Function() call, [int numberOfCalls = 0]) async {
    try {
      return await call();
    } on IOException catch (_) {
      if (numberOfCalls == 1) {
        rethrow;
      }
      _bwRunner = await BwRunner.create(config.bwPath, dataDir, logger);
      return _callApi(call, numberOfCalls + 1);
    } on bw.ApiException catch (_) {
      /// TODO 1: handle Api Exception. Must likely reset master password
      rethrow;
    }
  }

  Future<List<bw.Item>> items() async {
    return await _callApi(bw.VaultItemsApi(apiClient).listObjectItemsGet);
  }

  Future<bool> unlock({bool checked = true, String? masterPassword}) async {
    masterPassword ??= _masterPassword;
    if (checked && masterPassword == null) {
      throw NeedsMasterPasswordException();
    }
    final lockUnlockApi = bw.LockUnlockApi(apiClient);
    return await _callApi(() async {
      final unlockResponse = await lockUnlockApi.unlockPost(bw.UnlockPostRequest(password: masterPassword));
      return unlockResponse?.success ?? false;
    });
  }

  Future<bool> lock() {
    return _callApi(() async {
      return (await bw.LockUnlockApi(apiClient).lockPost())?.success ?? false;
    });
  }

  Future<void> sync() {
    return _callApi(bw.MiscellaneousApi(apiClient).syncPost);
  }

  Future<bw.Status?> status() {
    return _callApi(bw.MiscellaneousApi(apiClient).statusGet);
  }

  @override
  Future<void> dispose() async {
    await lock();
    await secretsClient?.close();
    await _bwRunner.stop();
    apiClient.client.close();
  }
}

final class NeedsMasterPasswordException implements Exception {
  @override
  String toString() => "BitwardenService needs master password to be set";
}

final class DefaultCollectionLockedException implements Exception {
  final String collectionName;

  const DefaultCollectionLockedException(this.collectionName);

  @override
  String toString() => "BitwardenService needs the default collection $collectionName to be unlocked";
}

class InstanceAlreadyRunning implements Exception {
  String? message;
  InstanceAlreadyRunning([this.message]);

  @override
  String toString() {
    if (message == null) return "InstanceAlreadyRunning";
    return "InstanceAlreadyRunning: $message";
  }
}

class BwRunner {
  Logger logger;
  RandomAccessFile bwFile;
  Either<Process, int> bwProcess;

  BwRunner._(this.logger, this.bwFile, this.bwProcess) {
    switch (bwProcess) {
      case EitherLeft<Process, int>(:final value):
        value.exitCode.then((code) {
          logger.debug("closed bw process ${value.pid} with exit code $code");
          bwFile.closeSync();
        });
      case EitherRigth<Process, int>():
        break;
    }
  }

  static Future<BwRunner> _createWithNewFile(String bwPath, Logger logger, File file) async {
    file.createSync();
    final randomAccessFile = file.openSync(mode: FileMode.write);
    randomAccessFile.lockSync(FileLock.exclusive);

    Process process;
    try {
      process = await _run(bwPath);
    } catch (e, st) {
      try {
        randomAccessFile.closeSync();
        file.deleteSync();
      } catch (_) {}

      if (e is InstanceAlreadyRunning) {
        rethrow;
      } else {
        throw InstanceAlreadyRunning("$e\n$st");
      }
    }
    await randomAccessFile.writeString(process.pid.toString());
    randomAccessFile.flushSync();

    return BwRunner._(logger, randomAccessFile, EitherLeft(process));
  }

  static Future<BwRunner> create(String bwPath, Directory dataDir, Logger logger) async {
    final file = dataDir.file("bw_pid");
    if (!file.existsSync()) {
      return _createWithNewFile(bwPath, logger, file);
    }

    final randomAccessFile = file.openSync(mode: FileMode.read);
    try {
      randomAccessFile.lockSync(FileLock.shared);
    } catch (e) {
      randomAccessFile.closeSync();
      throw InstanceAlreadyRunning("Locking file $e");
    }
    final length = randomAccessFile.lengthSync();
    final pidStr = utf8.decode(randomAccessFile.readSync(length));
    final pid = int.parse(pidStr);
    if (Process.killPid(pid, const _NullProcessSignal())) {
      return BwRunner._(logger, randomAccessFile, EitherRigth(pid));
    } else {
      file.deleteSync();
      return _createWithNewFile(bwPath, logger, file);
    }
  }

  static Future<Process> _run(String bwPath) async {
    final process = await Process.start(bwPath, ["serve"]);
    Completer<InstanceAlreadyRunning?> completer = Completer();
    process.exitCode.then((exitCode) async {
      final stderr = (await process.stderr.transform(Utf8Decoder(allowMalformed: true)).toList()).join();
      if (stderr.contains("EADDRINUSE: address already in use")) {
        if (!completer.isCompleted) completer.complete(InstanceAlreadyRunning(stderr));
      }
    });
    Future.delayed(Duration(seconds: 2), () => !completer.isCompleted ? completer.complete() : null);
    final value = await completer.future;
    if (value != null) {
      throw value;
    }
    return process;
  }

  Future<void> stop() async {
    switch (bwProcess) {
      case EitherLeft<Process, int>(value: final process):
        process.kill(ProcessSignal.sigterm);
      case EitherRigth<Process, int>(value: final pid):
        Process.killPid(pid);
        bwFile.closeSync();
    }
  }
}

@Config()
mixin BitwardenServiceConfigBase on BitwardenServiceConfigI {
  /// Path to the bw cli
  static const _bwPath = StringField(defaultTo: "bw");
}

class _NullProcessSignal implements ProcessSignal {
  const _NullProcessSignal();

  @override
  String get name => "NULL";

  @override
  int get signalNumber => 0;

  @override
  Stream<ProcessSignal> watch() {
    throw UnimplementedError();
  }
}
