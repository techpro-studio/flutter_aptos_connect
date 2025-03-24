import 'package:aptos_connect/bcs/deserializer.dart';
import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/model/public_key.dart';
import 'package:aptos_connect/model/serializer.dart';
import 'package:aptos_connect/model/signature.dart';

enum EphemeralSignatureVariant {
  ed25519._(0);

  const EphemeralSignatureVariant._(int value) : _underline = value;

  final int _underline;
}

enum EphemeralPublicKeyVariant {
  ed25519._(0);

  const EphemeralPublicKeyVariant._(int value) : _underline = value;

  final int _underline;
}

class EphemeralPublicKey {
  final EphemeralPublicKeyVariant variant;
  final dynamic key;

  static const BCSSerializer<EphemeralPublicKey> bcsSerializer =
      _EphemeralPublicKeySerializer._();

  EphemeralPublicKey({required this.variant, required this.key});
}

class _EphemeralPublicKeySerializer
    implements BCSSerializer<EphemeralPublicKey> {
  const _EphemeralPublicKeySerializer._();

  @override
  EphemeralPublicKey deserializeIn(Deserializer deserializer) {
    final variant = deserializer.deserializeUleb128AsU32();
    if (EphemeralPublicKeyVariant.ed25519._underline == variant) {
      return EphemeralPublicKey(
        key: Ed25519PublicKey.bcsSerializer.deserializeIn(deserializer),
        variant: EphemeralPublicKeyVariant.ed25519,
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, EphemeralPublicKey value) {
    serializer.serializeU32AsUleb128(value.variant._underline);
    if (EphemeralPublicKeyVariant.ed25519 == value.variant) {
      Ed25519PublicKey.bcsSerializer.serializeIn(serializer, value.key);
    } else {
      throw UnimplementedError();
    }
  }
}

class EphemeralSignature {
  final EphemeralSignatureVariant variant;
  final dynamic signature;

  static const BCSSerializer<EphemeralSignature> bcsSerializer =
      _EphemeralSignatureSerializer._();

  EphemeralSignature({required this.variant, required this.signature});
}

class _EphemeralSignatureSerializer
    implements BCSSerializer<EphemeralSignature> {
  const _EphemeralSignatureSerializer._();

  @override
  EphemeralSignature deserializeIn(Deserializer deserializer) {
    final variant = deserializer.deserializeUleb128AsU32();
    if (EphemeralPublicKeyVariant.ed25519._underline == variant) {
      return EphemeralSignature(
        signature: Ed25519Signature.bcsSerializer.deserializeIn(deserializer),
        variant: EphemeralSignatureVariant.ed25519,
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, EphemeralSignature value) {
    serializer.serializeU32AsUleb128(value.variant._underline);
    if (EphemeralSignatureVariant.ed25519 == value.variant) {
      Ed25519Signature.bcsSerializer.serializeIn(serializer, value.signature);
    } else {
      throw UnimplementedError();
    }
  }
}
