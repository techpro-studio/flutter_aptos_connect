import 'dart:typed_data';

import 'package:aptos_connect/crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as cryptolib;

// Hide crypto library here.

class CryptoImpl implements CryptoInterface {
  @override
  Future<KeyPair> generateKeyPair() async {
    final algo = cryptolib.Ed25519();
    final pair = await algo.newKeyPair();
    return KeyPair(
      publicKey: Uint8List.fromList((await pair.extractPublicKey()).bytes),
      privateKey: Uint8List.fromList(await pair.extractPrivateKeyBytes()),
    );
  }

  @override
  Future<Uint8List> signMessage(Uint8List message, KeyPair pair) async {
    final algo = cryptolib.Ed25519();
    final libKeyPair = _getLibPair(pair);
    final signed = await algo.sign(message, keyPair: libKeyPair);
    return Uint8List.fromList(signed.bytes);
  }

  cryptolib.SimpleKeyPairData _getLibPair(KeyPair pair) {
    return cryptolib.SimpleKeyPairData(
      pair.privateKey,
      publicKey: cryptolib.SimplePublicKey(
        pair.publicKey,
        type: cryptolib.KeyPairType.ed25519,
      ),
      type: cryptolib.KeyPairType.ed25519,
    );
  }

  @override
  Future<bool> verifySignature(
    Uint8List message,
    Uint8List signature,
    KeyPair pair,
  ) {
    final algo = cryptolib.Ed25519();
    final libKeyPair = _getLibPair(pair);
    final libSignature = cryptolib.Signature(
      signature,
      publicKey: libKeyPair.publicKey,
    );
    return algo.verify(message, signature: libSignature);
  }
}
