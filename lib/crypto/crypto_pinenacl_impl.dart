import 'package:aptos_connect/crypto/crypto.dart';
import 'package:pinenacl/api.dart';

class CryptoPineNaclImpl implements CryptoInterface {
  @override
  Future<KeyPair> generateKeyPair() {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> signMessage(Uint8List message, KeyPair pair) {
    throw UnimplementedError();
  }

  @override
  Future<bool> verifySignature(
    Uint8List message,
    Uint8List signature,
    KeyPair pair,
  ) {
    throw UnimplementedError();
  }
}
