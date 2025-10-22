import "dart:convert";

import "package:waywing/core/service.dart";
import "package:bitwarden_vault_api/bitwarden_api.dart" as bw;
import "package:freedesktop_secrets/freedesktop_secrets.dart";

class BitwardenService extends Service {
  late final bw.ApiClient apiClient;
  late final FreedesktopSecretsClient secretsClient;
  late final FreedesktopSecretsCollection defaultCollection;

  @override
  Future<void> init() async {
    apiClient = bw.ApiClient(basePath: "http://localhost:8087");
    secretsClient = FreedesktopSecretsClient();
    defaultCollection = (await secretsClient.defaultCollection())!;

    if (await defaultCollection.locked) {
      throw Exception("Default collection is locked and bitwarden service needs the default collection to be unlocked");
    }
  }

  String? _masterPassword;
  Future<String?> getMasterPassword() async {
    if (_masterPassword != null) return _masterPassword;

    final secrets = await defaultCollection.search({"id": "waywing_bitwarden"});
    if (secrets.isEmpty) return null;

    final secret = await secrets[0].getSecret(secretsClient.session);
    _masterPassword = utf8.decode(secret.decrypt().value);
    return _masterPassword;
  }

  Future<void> setMasterPassword(String password) async {
    if (_masterPassword == password) return;
    _masterPassword = password;

    final secret = FreedesktopSecretDecrypted(session: secretsClient.session, value: utf8.encode(password));
    final (item, prompt) = await defaultCollection.createItem(
      secret,
      FreedesktopSecretsCreateItemProps("waywing_bitwarden", {"id": "waywing_bitwarden"}),
      true,
    );
    if (prompt != null) {
      await prompt.complete((_, _) {});
    }
  }

  Future<void> items() async {
    bw.VaultItemsApi(apiClient).listObjectItemsGet();
  }

  @override
  Future<void> dispose() async {
    await secretsClient.close();
    apiClient.client.close();
  }
}
