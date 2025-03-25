import 'dart:async';
import 'dart:convert';

import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/crypto/accounts_storage.dart';
import 'package:aptos_connect/crypto/crypto_client.dart';
import 'package:aptos_connect/model/account_info.dart';
import 'package:aptos_connect/model/connect_request.dart';
import 'package:aptos_connect/model/connect_response.dart';
import 'package:aptos_connect/model/dapp.dart';
import 'package:aptos_connect/model/provider.dart' show AptosProvider;
import 'package:aptos_connect/model/serializer.dart';
import 'package:aptos_connect/model/signing_message_request.dart';
import 'package:aptos_connect/model/signing_message_response.dart';
import 'package:aptos_connect/model/wallet_request.dart';
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

  Future<void> connect(AptosProvider provider) async {
    String? publicKey;
    if (kIsWeb || kIsWasm) {
      final keyPair = await _cryptoClient.getKeyPair();
      publicKey = base64Encode(keyPair.publicKey);
    }
    final request = ConnectRequest(dAppEd25519PublicKeyB64: publicKey);
    final response = await _transport.performWalletRequest(
      _buildWalletRequest(request, 'connect', 4),
      ConnectResponse.bcsSerializer,
      provider: provider,
    );
    if (response.approved) {
      await _accountsStorage.appendAccount(response.value!.accountInfo);
    }
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
