import 'dart:typed_data';

import 'package:aptos_connect/bcs/deserializer.dart';
import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/model/serializer.dart';

enum PublicKeyType {
  singleKey._(2);
  // ed25519._(0),
  // multiEd25519._(1),
  // multiKey._(3);

  const PublicKeyType._(int value) : _underline = value;

  final int _underline;
}

enum SingleKeyPublicKeyVariant {
  keyless._(3);
  // ed25519._(0),
  // secp256k1._(1),
  // federatedKeyless._(4);

  const SingleKeyPublicKeyVariant._(int value) : _underline = value;

  final int _underline;
}

class SingleKeyPublicKey {
  final SingleKeyPublicKeyVariant variant;
  final dynamic key;

  SingleKeyPublicKey({required this.variant, required this.key});
}

class _SingleKeyPublicKeySerializer
    implements BCSSerializer<SingleKeyPublicKey> {
  const _SingleKeyPublicKeySerializer._();

  static const _keylessSerializer = _KeylessPublicKeySerializer._();

  @override
  SingleKeyPublicKey deserializeIn(Deserializer deserializer) {
    final variant = deserializer.deserializeUleb128AsU32();
    if (variant == SingleKeyPublicKeyVariant.keyless._underline) {
      final keyless = _keylessSerializer.deserializeIn(deserializer);
      return SingleKeyPublicKey(
        variant: SingleKeyPublicKeyVariant.keyless,
        key: keyless,
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, SingleKeyPublicKey value) {
    serializer.serializeU32AsUleb128(value.variant._underline);
    if (value.variant == SingleKeyPublicKeyVariant.keyless) {
      _keylessSerializer.serializeIn(serializer, value.key);
    } else {
      throw UnimplementedError();
    }
  }
}

class KeylessPublicKey implements BCSSerializable {
  final String iss;
  final Uint8List idCommitment;

  static const BCSSerializer<KeylessPublicKey> bcsSerializer =
      _KeylessPublicKeySerializer._();

  KeylessPublicKey({required this.iss, required this.idCommitment});

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _KeylessPublicKeySerializer implements BCSSerializer<KeylessPublicKey> {
  const _KeylessPublicKeySerializer._();
  @override
  KeylessPublicKey deserializeIn(Deserializer deserializer) {
    final iss = deserializer.deserializeStr();
    final idCommitment = deserializer.deserializeBytes();
    return KeylessPublicKey(iss: iss, idCommitment: idCommitment);
  }

  @override
  void serializeIn(Serializer serializer, KeylessPublicKey value) {
    serializer.serializeStr(value.iss);
    serializer.serializeBytes(value.idCommitment);
  }
}

class Ed25519PublicKey {
  final Uint8List bytes;
  static const _size = 32;

  static const BCSSerializer<Ed25519PublicKey> bcsSerializer =
      _Ed25519PublicKeySerializer._();

  Ed25519PublicKey({required this.bytes});
}

class _Ed25519PublicKeySerializer implements BCSSerializer<Ed25519PublicKey> {
  const _Ed25519PublicKeySerializer._();

  @override
  Ed25519PublicKey deserializeIn(Deserializer deserializer) {
    return Ed25519PublicKey(bytes: deserializer.deserializeBytes());
  }

  @override
  void serializeIn(Serializer serializer, Ed25519PublicKey value) {
    serializer.serializeBytes(value.bytes);
  }
}

class PublicKey implements BCSSerializable {
  final PublicKeyType type;
  final dynamic data;

  static const BCSSerializer<PublicKey> bcsSerializer = _PublicKeySerializer();

  PublicKey({required this.data, required this.type});

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _PublicKeySerializer implements BCSSerializer<PublicKey> {
  const _PublicKeySerializer();

  static const _singleKeySerializer = _SingleKeyPublicKeySerializer._();

  @override
  PublicKey deserializeIn(Deserializer deserializer) {
    final type = deserializer.deserializeUleb128AsU32();
    if (PublicKeyType.singleKey._underline == type) {
      return PublicKey(
        data: _singleKeySerializer.deserializeIn(deserializer),
        type: PublicKeyType.singleKey,
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, PublicKey value) {
    serializer.serializeU32AsUleb128(value.type._underline);
    if (value.type == PublicKeyType.singleKey) {
      _singleKeySerializer.serializeIn(serializer, value.data);
    } else {
      throw UnimplementedError();
    }
  }
}
