import 'package:aptos_connect/client/client.dart';
import 'package:aptos_connect/crypto/account_storage_impl.dart';
import 'package:aptos_connect/crypto/accounts_storage.dart';
import 'package:aptos_connect/crypto/crypto.dart';
import 'package:aptos_connect/crypto/crypto_client.dart';
import 'package:aptos_connect/crypto/crypto_impl.dart';
import 'package:aptos_connect/crypto/key_pair_storage.dart';
import 'package:aptos_connect/crypto/key_pair_storage_impl.dart';
import 'package:aptos_connect/factory/factory.dart';
import 'package:aptos_connect/model/dapp.dart';
import 'package:aptos_connect/storage/kv_storage.dart';
import 'package:aptos_connect/transport/web_transport.dart';
import 'package:web/web.dart' as web;

class AptosConnectClientFactoryWeb implements AptosConnectClientFactory {
  final String dAppName;
  final String? dAppImageUrl;

  final KVStorage _kvStorage;

  final CryptoInterface? _cryptoInterfaceOverride;
  final KeyPairStorage? _keyPairStorageOverride;
  final CryptoClient? _cryptoClientOverride;
  final AccountsStorage? _accountsStorageOverride;

  AptosConnectClientFactoryWeb({
    required this.dAppName,
    required this.dAppImageUrl,
    required KVStorage storage,
    CryptoInterface? cryptoInterfaceOverride,
    KeyPairStorage? keyPairStorageOverride,
    CryptoClient? cryptoClientOverride,
    AccountsStorage? accountStorageOverride,
  }) : _kvStorage = storage,
       _cryptoInterfaceOverride = cryptoInterfaceOverride,
       _keyPairStorageOverride = keyPairStorageOverride,
       _cryptoClientOverride = cryptoClientOverride,
       _accountsStorageOverride = accountStorageOverride;

  @override
  AptosConnectClient make() {
    final CryptoInterface crypto = _cryptoInterfaceOverride ?? CryptoImpl();
    final keyPairStorage =
        _keyPairStorageOverride ?? KeyPairStorageImpl(_kvStorage);
    final config = WebTransportConfig(
      baseUrl: "https://staging.aptosconnect.app",
    );
    final cryptoClient =
        _cryptoClientOverride ??
        CryptoClient(keyPairStorage: keyPairStorage, cryptoInterface: crypto);
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
