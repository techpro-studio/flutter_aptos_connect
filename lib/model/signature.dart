import 'dart:typed_data';

import 'package:aptos_connect/bcs/deserializer.dart';
import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/model/ephemeral.dart';
import 'package:aptos_connect/model/keyless.dart';
import 'package:aptos_connect/model/serializer.dart';

enum SignatureType {
  singleKey._(2),
  ed25519._(0);
  // multiEd25519._(1),
  // multiKey._(3);

  const SignatureType._(int value) : _underline = value;

  final int _underline;
}

enum SingleKeySignatureVariant {
  keyless._(3),
  ed25519._(0);
  // secp256k1._(1),

  const SingleKeySignatureVariant._(int value) : _underline = value;

  final int _underline;
}

class Ed25519Signature {
  final Uint8List bytes;
  static const _size = 64;

  static const BCSSerializer<Ed25519Signature> bcsSerializer =
      _Ed25519SignatureSerializer._();

  Ed25519Signature({required this.bytes});
}

class _Ed25519SignatureSerializer implements BCSSerializer<Ed25519Signature> {
  const _Ed25519SignatureSerializer._();

  @override
  Ed25519Signature deserializeIn(Deserializer deserializer) {
    return Ed25519Signature(bytes: deserializer.deserializeBytes());
  }

  @override
  void serializeIn(Serializer serializer, Ed25519Signature value) {
    serializer.serializeBytes(value.bytes);
  }
}

class KeylessSignature {
  final EphemeralCertificate ephemeralCertificate;
  final String jwtHeader;
  final BigInt expiryDateSecs;
  final EphemeralPublicKey ephemeralPublicKey;
  final EphemeralSignature ephemeralSignature;

  KeylessSignature({
    required this.ephemeralCertificate,
    required this.jwtHeader,
    required this.expiryDateSecs,
    required this.ephemeralPublicKey,
    required this.ephemeralSignature,
  });
}

class _KeylessSignatureSerializer implements BCSSerializer<KeylessSignature> {
  const _KeylessSignatureSerializer._();

  @override
  KeylessSignature deserializeIn(Deserializer deserializer) {
    final certificate = EphemeralCertificate.bcsSerializer.deserializeIn(
      deserializer,
    );
    final jwtHeader = deserializer.deserializeStr();
    final expiryDateSecs = deserializer.deserializeU64();
    final ephemeralPublicKey = EphemeralPublicKey.bcsSerializer.deserializeIn(
      deserializer,
    );
    final ephemeralSignature = EphemeralSignature.bcsSerializer.deserializeIn(
      deserializer,
    );
    return KeylessSignature(
      ephemeralCertificate: certificate,
      jwtHeader: jwtHeader,
      expiryDateSecs: expiryDateSecs,
      ephemeralPublicKey: ephemeralPublicKey,
      ephemeralSignature: ephemeralSignature,
    );
  }

  @override
  void serializeIn(Serializer serializer, KeylessSignature value) {
    EphemeralCertificate.bcsSerializer.serializeIn(
      serializer,
      value.ephemeralCertificate,
    );
    serializer.serializeStr(value.jwtHeader);
    serializer.serializeU64(value.expiryDateSecs);
    EphemeralPublicKey.bcsSerializer.serializeIn(
      serializer,
      value.ephemeralPublicKey,
    );
    EphemeralSignature.bcsSerializer.serializeIn(
      serializer,
      value.ephemeralSignature,
    );
  }
}

class SingleKeySignature {
  final SingleKeySignatureVariant variant;
  final dynamic data;

  SingleKeySignature({required this.variant, required this.data});
}

class _SingleKeySignatureSerializer
    implements BCSSerializer<SingleKeySignature> {
  static const _ed25519Serializer = _Ed25519SignatureSerializer._();
  static const _keylessSerializer = _KeylessSignatureSerializer._();

  const _SingleKeySignatureSerializer();
  @override
  SingleKeySignature deserializeIn(Deserializer deserializer) {
    final variant = deserializer.deserializeUleb128AsU32();
    if (SingleKeySignatureVariant.ed25519._underline == variant) {
      return SingleKeySignature(
        variant: SingleKeySignatureVariant.ed25519,
        data: _ed25519Serializer.deserializeIn(deserializer),
      );
    } else if (SingleKeySignatureVariant.keyless._underline == variant) {
      return SingleKeySignature(
        variant: SingleKeySignatureVariant.keyless,
        data: _keylessSerializer.deserializeIn(deserializer),
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, SingleKeySignature value) {
    // TODO: implement serializeIn
  }
}

class Signature extends BCSSerializable {
  final SignatureType type;
  final dynamic data;

  Signature({required this.type, required this.data});

  static BCSSerializer<Signature> bcsSerializer = _SignatureSerializer._();

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _SignatureSerializer implements BCSSerializer<Signature> {
  static const _singleKeySerializer = _SingleKeySignatureSerializer();
  static const _ed25519Serializer = _Ed25519SignatureSerializer._();

  const _SignatureSerializer._();
  @override
  Signature deserializeIn(Deserializer deserializer) {
    final type = deserializer.deserializeUleb128AsU32();
    if (SignatureType.ed25519._underline == type) {
      return Signature(
        type: SignatureType.ed25519,
        data: _ed25519Serializer.deserializeIn(deserializer),
      );
    } else if (SignatureType.singleKey._underline == type) {
      return Signature(
        type: SignatureType.singleKey,
        data: _singleKeySerializer.deserializeIn(deserializer),
      );
    } else {
      throw UnimplementedError();
    }
  }

  @override
  void serializeIn(Serializer serializer, Signature value) {
    // TODO: implement serializeIn
  }
}
