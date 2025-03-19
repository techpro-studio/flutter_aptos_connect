import 'dart:convert';

import 'package:aptos_connect/crypto/key_pair_storage.dart';
import 'package:aptos_connect/storage/kv_storage.dart';

import 'crypto.dart' show KeyPair;

class KeyPairStorageImpl implements KeyPairStorage {
  final KVStorage _kvStorage;

  static const _kAptosConnectPublicKey = 'app.aptosconnect.public_key';
  static const _kAptosConnectPrivateKey = 'app.aptosconnect.private_key';

  KeyPairStorageImpl(this._kvStorage);

  @override
  Future<KeyPair?> getKeyPair() async {
    final private = await _kvStorage.getValue(_kAptosConnectPrivateKey);
    if (private == null) {
      return null;
    }
    final public = await _kvStorage.getValue(_kAptosConnectPublicKey);
    return KeyPair(
      publicKey: base64Decode(public!),
      privateKey: base64Decode(private),
    );
  }

  @override
  Future<void> saveKeyPair(KeyPair keyPair) async {
    await _kvStorage.setValue(
      _kAptosConnectPrivateKey,
      base64Encode(keyPair.privateKey),
    );
    await _kvStorage.setValue(
      _kAptosConnectPublicKey,
      base64Encode(keyPair.publicKey),
    );
  }

  @override
  Future<void> removeKeyPair() async {
    await _kvStorage.removeValue(_kAptosConnectPublicKey);
    await _kvStorage.removeValue(_kAptosConnectPrivateKey);
  }
}
