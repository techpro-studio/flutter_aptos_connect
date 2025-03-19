import 'dart:typed_data';

class KeyPair {
  final Uint8List publicKey;
  final Uint8List privateKey;

  KeyPair({required this.publicKey, required this.privateKey});
}

abstract class CryptoInterface {
  Future<KeyPair> generateKeyPair();
  Future<Uint8List> signMessage(Uint8List message, KeyPair pair);
  Future<bool> verifySignature(
    Uint8List message,
    Uint8List signature,
    KeyPair pair,
  );
}
