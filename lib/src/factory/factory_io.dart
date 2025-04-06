import 'package:aptos_connect/src/client/account_storage_impl.dart';
import 'package:aptos_connect/src/client/accounts_storage.dart';
import 'package:aptos_connect/src/client/client.dart';
import 'package:aptos_connect/src/client/crypto_client.dart';
import 'package:aptos_connect/src/client/kv_storage.dart';
import 'package:aptos_connect/src/factory/factory.dart';
import 'package:aptos_connect/src/model/dapp.dart';
import 'package:aptos_connect/src/transport/io_transport.dart';

class AptosConnectClientFactoryIO implements AptosConnectClientFactory {
  final String dAppName;
  final String aptosConnectRedirectUrl;
  final String? dAppImageUrl;

  final KVStorage _kvStorage;
  final CryptoClient? _cryptoClientOverride;
  final AccountsStorage? _accountsStorageOverride;

  AptosConnectClientFactoryIO({
    required this.dAppName,
    required this.dAppImageUrl,
    required KVStorage storage,
    this.aptosConnectRedirectUrl = 'http://localhost/callback',
    CryptoClient? cryptoClientOverride,
    AccountsStorage? accountStorageOverride,
  }) : _kvStorage = storage,
       _cryptoClientOverride = cryptoClientOverride,
       _accountsStorageOverride = accountStorageOverride;

  @override
  AptosConnectClient make() {
    final config = IOTransportConfig(
      baseUrl: "https://aptosconnect.app",
      redirectUrl: aptosConnectRedirectUrl,
    );
    final cryptoClient =
        _cryptoClientOverride ?? CryptoClient(privateKeyStorage: _kvStorage);
    final transport = IOTransport(cryptoClient, config);
    final dAppInfo = DAppInfo(
      domain: "Native Dapp",
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
