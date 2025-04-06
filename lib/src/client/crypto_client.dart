import 'dart:convert';
import 'dart:typed_data';

import 'package:aptos_connect/src/client/kv_storage.dart';
import 'package:aptos_core/aptos_core.dart';

class CryptoClient {
  final KVStorage _privateKeyStorage;
  final _cryptoAlgorithm = Ed25519Algorithm();

  static const _kPrivateKey = 'app.aptosconnect.privateKey';

  CryptoClient({required KVStorage privateKeyStorage})
    : _privateKeyStorage = privateKeyStorage;

  Future<Ed25519PrivateKey> getPrivateKey() async {
    var privateKey = await _privateKeyStorage.getValue(_kPrivateKey);
    if (privateKey == null) {
      final generated = await _cryptoAlgorithm.generatePrivateKey();
      privateKey = base64Encode(generated.toUint8List());
      await _privateKeyStorage.setValue(_kPrivateKey, privateKey);
      return generated;
    }
    return Ed25519PrivateKey(key: base64Decode(privateKey));
  }

  Future<Uint8List> signMessage(Uint8List message) async {
    final privateKey = await getPrivateKey();
    final signature = await privateKey.signMessage(message);
    return signature.toUint8List();
  }

  Future<void> deleteKeyPair() => _privateKeyStorage.removeValue(_kPrivateKey);
}
