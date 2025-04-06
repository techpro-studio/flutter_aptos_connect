import 'dart:async';
import 'dart:convert';

import 'package:aptos_connect/src/client/accounts_storage.dart';
import 'package:aptos_connect/src/client/crypto_client.dart';
import 'package:aptos_connect/src/model/account_info.dart';
import 'package:aptos_connect/src/model/connect_request.dart';
import 'package:aptos_connect/src/model/connect_response.dart';
import 'package:aptos_connect/src/model/dapp.dart';
import 'package:aptos_connect/src/model/provider.dart';
import 'package:aptos_connect/src/model/signing_message_request.dart';
import 'package:aptos_connect/src/model/signing_message_response.dart';
import 'package:aptos_connect/src/model/wallet_request.dart';
import 'package:aptos_connect/src/transport/transport.dart';
import 'package:aptos_core/aptos_core.dart';
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

  Future<List<AccountInfo>> getConnectedAccounts() =>
      _accountsStorage.getAccounts();

  Future<void> disconnectAll() async {
    await _accountsStorage.removeAccounts();
    await _cryptoClient.deleteKeyPair();
  }

  Future<void> disconnectAccount(AccountInfo account) async {
    await _accountsStorage.removeAccount(account);
  }

  WalletRequest _buildWalletRequest<T extends BCSSerializable>(
    T request,
    String name,
    int version,
  ) {
    final serializer = Serializer();
    DAppInfo.bcsSerializer.serializeIn(serializer, _appInfo);
    request.serializeBCS(serializer);
    return WalletRequest(
      name: name,
      version: version,
      data: serializer.getBytes(),
    );
  }

  Future<AccountInfo?> connect(AptosProvider provider) async {
    String? publicKey;
    if (kIsWeb || kIsWasm) {
      final privateKey = await _cryptoClient.getPrivateKey();
      publicKey = base64Encode((await privateKey.getPublicKey()).toUint8List());
    }
    final request = ConnectRequest(dAppEd25519PublicKeyB64: publicKey);
    final response = await _transport.performWalletRequest(
      _buildWalletRequest(request, 'connect', 4),
      ConnectResponse.bcsSerializer,
      provider: provider,
    );
    if (response.approved) {
      await _accountsStorage.appendAccount(response.value!.accountInfo);
      return response.value!.accountInfo;
    }
    return null;
  }

  Future<SigningMessageResponse?> signMessage(
    SigningMessageRequest request,
  ) async {
    final walletRequest = _buildWalletRequest(request, 'signMessage', 2);
    final response = await _transport.performWalletRequest(
      walletRequest,
      SigningMessageResponse.bcsSerializer,
    );
    debugPrint("Signing message ${response.value?.fullMessage}");
    return response.value;
  }
}
