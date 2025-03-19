import 'package:aptos_connect/crypto/crypto.dart';

abstract class KeyPairStorage {
  Future<KeyPair?> getKeyPair();
  Future<void> saveKeyPair(KeyPair keyPair);
  Future<void> removeKeyPair();
}
