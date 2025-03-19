import 'dart:typed_data';

import 'package:aptos_connect/crypto/crypto.dart';
import 'package:aptos_connect/crypto/key_pair_storage.dart';

class CryptoClient {
  final KeyPairStorage _keyPairStorage;
  final CryptoInterface _cryptoInterface;

  CryptoClient({
    required KeyPairStorage keyPairStorage,
    required CryptoInterface cryptoInterface,
  }) : _keyPairStorage = keyPairStorage,
       _cryptoInterface = cryptoInterface;

  Future<KeyPair> getKeyPair() async {
    var pair = await _keyPairStorage.getKeyPair();
    if (pair == null) {
      pair = await _cryptoInterface.generateKeyPair();
      await _keyPairStorage.saveKeyPair(pair);
    }
    return pair;
  }

  Future<Uint8List> signMessage(Uint8List message) async {
    return _cryptoInterface.signMessage(message, await getKeyPair());
  }

  Future<bool> verifySignature(Uint8List message, Uint8List signature) async {
    return _cryptoInterface.verifySignature(
      message,
      signature,
      await getKeyPair(),
    );
  }

  Future<void> deleteKeyPair() => _keyPairStorage.removeKeyPair();
}
