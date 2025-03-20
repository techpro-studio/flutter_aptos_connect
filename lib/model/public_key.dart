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

enum SingleKeyVariant {
  keyless._(3);
  // ed25519._(0),
  // secp256k1._(1),
  // federatedKeyless._(4);

  const SingleKeyVariant._(int value) : _underline = value;

  final int _underline;
}

class SingleKeyPublicKey {
  final SingleKeyVariant variant;
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
    if (variant == SingleKeyVariant.keyless._underline) {
      final keyless = _keylessSerializer.deserializeIn(deserializer);
      return SingleKeyPublicKey(
        variant: SingleKeyVariant.keyless,
        key: keyless,
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, SingleKeyPublicKey value) {
    serializer.serializeU32AsUleb128(value.variant._underline);
    if (value.variant == SingleKeyVariant.keyless) {
      _keylessSerializer.serializeIn(serializer, value.key);
    } else {
      throw UnimplementedError();
    }
  }
}

class KeylessPublicKey {
  final String iss;
  final Uint8List idCommitment;

  KeylessPublicKey({required this.iss, required this.idCommitment});
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
