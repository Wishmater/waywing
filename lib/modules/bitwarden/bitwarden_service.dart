import "dart:convert";

import "package:waywing/core/service.dart";
import "package:bitwarden_vault_api/bitwarden_api.dart" as bw;
import "package:freedesktop_secrets/freedesktop_secrets.dart";
import "package:waywing/core/service_registry.dart";

class BitwardenService extends Service {
  BitwardenService._();

  static void registerService(RegisterServiceCallback registration) {
    registration<BitwardenService, dynamic>(
      ServiceRegistration(
        constructor: BitwardenService._,
      ),
    );
  }

  late final bw.ApiClient apiClient;
  late final FreedesktopSecretsClient? secretsClient;
  late final FreedesktopSecretsCollection? defaultCollection;

  @override
  Future<void> init() async {
    apiClient = bw.ApiClient(basePath: "http://localhost:8087");

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

  Future<List<bw.Item>> items() {
    return bw.VaultItemsApi(apiClient).listObjectItemsGet();
  }

  Future<void> unlock({bool checked = true, String? masterPassword}) {
    masterPassword ??= _masterPassword;
    if (checked && masterPassword == null) {
      throw NeedsMasterPasswordException();
    }
    return bw.LockUnlockApi(apiClient).unlockPost(bw.UnlockPostRequest(password: masterPassword));
  }

  Future<void> lock() {
    return bw.LockUnlockApi(apiClient).lockPost();
  }

  @override
  Future<void> dispose() async {
    await lock();
    await secretsClient?.close();
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
