import 'dart:async';
import 'dart:convert';

import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/crypto/accounts_storage.dart';
import 'package:aptos_connect/crypto/crypto_client.dart';
import 'package:aptos_connect/model/connect_request.dart';
import 'package:aptos_connect/model/connect_response.dart';
import 'package:aptos_connect/model/dapp.dart';
import 'package:aptos_connect/model/provider.dart' show AptosProvider;
import 'package:aptos_connect/model/wallet_request.dart';
import 'package:aptos_connect/model/wallet_response.dart';
import 'package:aptos_connect/transport/transport.dart';
import 'package:flutter/foundation.dart';

class AptosConnectClient {
  final CryptoClient _cryptoClient;
  final Transport _transport;
  final DAppInfo _appInfo;
  final AccountsStorage _accountsStorage;

  AptosConnectClient(
    this._cryptoClient,
    this._transport,
    this._accountsStorage,
    this._appInfo,
  );

  Future<void> disconnect() async {
    await _accountsStorage.removeAccounts();
    await _cryptoClient.deleteKeyPair();
  }

  Future<WalletResponse<ConnectResponse>> connect(
    AptosProvider provider,
  ) async {
    final serializer = Serializer();
    DAppInfo.bcsSerializer.serializeIn(serializer, _appInfo);
    String? publicKey;
    if (kIsWeb || kIsWasm) {
      final keyPair = await _cryptoClient.getKeyPair();
      publicKey = base64Encode(keyPair.publicKey);
    }
    final request = ConnectRequest(dAppEd25519PublicKeyB64: publicKey);
    request.serializeBCS(serializer);
    final response = await _transport.performWalletRequest(
      WalletRequest(name: 'connect', version: 4, data: serializer.getBytes()),
      ConnectResponse.bcsSerializer,
      provider: provider,
    );
    return response;
  }
}
