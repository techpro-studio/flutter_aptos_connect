import 'package:aptos_connect/client/client.dart';
import 'package:aptos_connect/crypto/crypto.dart';
import 'package:aptos_connect/crypto/crypto_client.dart';
import 'package:aptos_connect/crypto/crypto_impl.dart';
import 'package:aptos_connect/crypto/key_pair_storage.dart';
import 'package:aptos_connect/crypto/key_pair_storage_impl.dart';
import 'package:aptos_connect/factory/factory.dart';
import 'package:aptos_connect/model/dapp.dart';
import 'package:aptos_connect/storage/kv_storage_io.dart';
import 'package:aptos_connect/transport/io_transport.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AptosConnectClientFactoryIO implements AptosConnectClientFactory {
  final String dAppName;
  final String aptosConnectRedirectUrl;
  final String? dAppImageUrl;

  final FlutterSecureStorage? _secureStorageOverride;
  final CryptoInterface? _cryptoInterfaceOverride;
  final KeyPairStorage? _keyPairStorageOverride;
  final CryptoClient? _cryptoClientOverride;

  AptosConnectClientFactoryIO({
    required this.dAppName,
    required this.aptosConnectRedirectUrl,
    required this.dAppImageUrl,
    FlutterSecureStorage? secureStorageOverride,
    CryptoInterface? cryptoInterfaceOverride,
    KeyPairStorage? keyPairStorageOverride,
    CryptoClient? cryptoClientOverride,
  }) : _secureStorageOverride = secureStorageOverride,
       _cryptoInterfaceOverride = cryptoInterfaceOverride,
       _keyPairStorageOverride = keyPairStorageOverride,
       _cryptoClientOverride = cryptoClientOverride;

  @override
  AptosConnectClient make() {
    final kvStorage = KVStorageIO(
      _secureStorageOverride ?? FlutterSecureStorage(),
    );
    final CryptoInterface crypto = _cryptoInterfaceOverride ?? CryptoImpl();
    final keyPairStorage =
        _keyPairStorageOverride ?? KeyPairStorageImpl(kvStorage);
    final config = IOTransportConfig(
      baseUrl: "https://staging.aptosconnect.app",
      redirectUrl: aptosConnectRedirectUrl,
    );
    final cryptoClient =
        _cryptoClientOverride ??
        CryptoClient(keyPairStorage: keyPairStorage, cryptoInterface: crypto);
    final transport = IOTransport(cryptoClient, config);
    final dAppInfo = DAppInfo(
      domain: "Native Dapp",
      name: dAppName,
      imageUrl: dAppImageUrl,
    );
    return AptosConnectClient(cryptoClient, transport, dAppInfo);
  }
}
