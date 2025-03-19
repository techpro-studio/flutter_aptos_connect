import 'dart:async';

import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/crypto/crypto_client.dart';
import 'package:aptos_connect/model/connect_request.dart';
import 'package:aptos_connect/model/dapp.dart';
import 'package:aptos_connect/model/provider.dart' show AptosProvider;
import 'package:aptos_connect/model/wallet_request.dart';
import 'package:aptos_connect/transport/transport.dart';

class AptosConnectClient {
  final CryptoClient _cryptoClient;
  final Transport _transport;
  final DAppInfo _appInfo;

  AptosConnectClient(this._cryptoClient, this._transport, this._appInfo);

  Future<void> disconnect() async {
    await _cryptoClient.deleteKeyPair();
  }

  Future<WalletRequest> getConnectionWalletRequest() async {
    final serializer = Serializer();
    DAppInfo.bcsSerializer.serializeIn(serializer, _appInfo);
    final keyPair = await _cryptoClient.getKeyPair();
    ConnectRequest.bcsSerializer.serializeIn(
      serializer,
      ConnectRequest(
        // dAppEd25519PublicKeyB64: base64Encode(keyPair.publicKey.toUint8List()),
      ),
    );
    final data = serializer.getBytes();
    return WalletRequest(name: 'connect', version: 4, data: data);
  }

  Future connect(AptosProvider provider) async {
    return _transport.performWalletRequest(
      await getConnectionWalletRequest(),
      provider: provider,
    );
  }
}
