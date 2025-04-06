import 'package:aptos_connect/src/client/account_storage_impl.dart';
import 'package:aptos_connect/src/client/accounts_storage.dart';
import 'package:aptos_connect/src/client/client.dart';
import 'package:aptos_connect/src/client/crypto_client.dart';
import 'package:aptos_connect/src/client/kv_storage.dart';
import 'package:aptos_connect/src/factory/factory.dart';
import 'package:aptos_connect/src/model/dapp.dart';
import 'package:aptos_connect/src/transport/web_transport.dart';
import 'package:web/web.dart' as web;

class AptosConnectClientFactoryWeb implements AptosConnectClientFactory {
  final String dAppName;
  final String? dAppImageUrl;

  final KVStorage _kvStorage;
  final CryptoClient? _cryptoClientOverride;
  final AccountsStorage? _accountsStorageOverride;

  AptosConnectClientFactoryWeb({
    required this.dAppName,
    required this.dAppImageUrl,
    required KVStorage storage,

    CryptoClient? cryptoClientOverride,
    AccountsStorage? accountStorageOverride,
  }) : _kvStorage = storage,
       _cryptoClientOverride = cryptoClientOverride,
       _accountsStorageOverride = accountStorageOverride;

  @override
  AptosConnectClient make() {
    final config = WebTransportConfig(baseUrl: "https://aptosconnect.app");
    final cryptoClient =
        _cryptoClientOverride ?? CryptoClient(privateKeyStorage: _kvStorage);
    final transport = WebTransport(config);
    final dAppInfo = DAppInfo(
      domain: web.window.location.origin,
      name: dAppName,
      imageUrl: dAppImageUrl,
    );
    final accountsStorage =
        _accountsStorageOverride ?? AccountsStorageImpl(kvStorage: _kvStorage);
    return AptosConnectClient(
      cryptoClient,
      transport,
      accountsStorage,
      dAppInfo,
    );
  }
}
