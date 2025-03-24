import 'dart:typed_data';

import 'package:aptos_connect/bcs/deserializer.dart';
import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/model/ephemeral.dart';
import 'package:aptos_connect/model/serializer.dart';

class G1Bytes implements BCSSerializable {
  final Uint8List bytes;
  static const size = 32;

  G1Bytes._({required this.bytes});

  factory G1Bytes(Uint8List bytes) {
    if (bytes.length != size) {
      throw ArgumentError('Invalid size');
    }
    return G1Bytes._(bytes: bytes);
  }

  static const BCSSerializer<G1Bytes> bcsSerializer = _G1BytesSerializer._();

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _G1BytesSerializer implements BCSSerializer<G1Bytes> {
  const _G1BytesSerializer._();
  @override
  G1Bytes deserializeIn(Deserializer deserializer) {
    return G1Bytes(deserializer.deserializeFixedBytes(G1Bytes.size));
  }

  @override
  void serializeIn(Serializer serializer, G1Bytes value) {
    serializer.serializeFixedBytes(value.bytes);
  }
}

class G2Bytes implements BCSSerializable {
  final Uint8List bytes;
  static const size = 64;

  G2Bytes._({required this.bytes});

  factory G2Bytes(Uint8List bytes) {
    if (bytes.length != size) {
      throw ArgumentError('Invalid size');
    }
    return G2Bytes._(bytes: bytes);
  }

  static const BCSSerializer<G2Bytes> bcsSerializer = _G2BytesSerializer._();

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _G2BytesSerializer implements BCSSerializer<G2Bytes> {
  const _G2BytesSerializer._();
  @override
  G2Bytes deserializeIn(Deserializer deserializer) {
    return G2Bytes(deserializer.deserializeFixedBytes(G2Bytes.size));
  }

  @override
  void serializeIn(Serializer serializer, G2Bytes value) {
    serializer.serializeFixedBytes(value.bytes);
  }
}

class Groth16Zkp {
  final G1Bytes a;
  final G2Bytes b;
  final G1Bytes c;

  Groth16Zkp({required this.a, required this.b, required this.c});
}

class _Groth16ZkpSerializer implements BCSSerializer<Groth16Zkp> {
  const _Groth16ZkpSerializer._();
  @override
  Groth16Zkp deserializeIn(Deserializer deserializer) {
    final a = G1Bytes.bcsSerializer.deserializeIn(deserializer);
    final b = G2Bytes.bcsSerializer.deserializeIn(deserializer);
    final c = G1Bytes.bcsSerializer.deserializeIn(deserializer);
    return Groth16Zkp(a: a, b: b, c: c);
  }

  @override
  void serializeIn(Serializer serializer, Groth16Zkp value) {
    value.a.serializeBCS(serializer);
    value.b.serializeBCS(serializer);
    value.c.serializeBCS(serializer);
  }
}

enum ZkpVariant {
  groth16._(0);

  const ZkpVariant._(int value) : _internal = value;

  final int _internal;
}

class ZkProof {
  final dynamic proof;
  final ZkpVariant variant;

  ZkProof({required this.proof, required this.variant});
}

class _ZkProofSerializer implements BCSSerializer<ZkProof> {
  const _ZkProofSerializer._();

  static const _groth16Serializer = _Groth16ZkpSerializer._();
  @override
  ZkProof deserializeIn(Deserializer deserializer) {
    final variant = deserializer.deserializeUleb128AsU32();
    if (ZkpVariant.groth16._internal == variant) {
      return ZkProof(
        proof: _groth16Serializer.deserializeIn(deserializer),
        variant: ZkpVariant.groth16,
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, ZkProof value) {
    serializer.serializeU32AsUleb128(value.variant._internal);
    if (ZkpVariant.groth16 == value.variant) {
      _groth16Serializer.serializeIn(serializer, value.proof);
    } else {
      throw UnimplementedError();
    }
  }
}

class ZeroKnowledgeSignature {
  final ZkProof proof;
  final BigInt expHorizonSecs;
  final String? extraField;
  final String? overrideAudVal;
  final EphemeralSignature? trainingWheelsSignature;

  ZeroKnowledgeSignature({
    required this.proof,
    required this.expHorizonSecs,
    required this.extraField,
    required this.overrideAudVal,
    required this.trainingWheelsSignature,
  });
}

class _ZeroKnowledgeSignatureSerializer
    implements BCSSerializer<ZeroKnowledgeSignature> {
  static const _zkProofSerializer = _ZkProofSerializer._();

  const _ZeroKnowledgeSignatureSerializer._();
  @override
  ZeroKnowledgeSignature deserializeIn(Deserializer deserializer) {
    final proof = _zkProofSerializer.deserializeIn(deserializer);
    final expHorizonSecs = deserializer.deserializeU64();
    final extraField = deserializer.deserializeOptionalStr();
    final overrideAudVal = deserializer.deserializeOptionalStr();
    final trainingWheelsSignature = EphemeralSignature.bcsSerializer
        .deserializeOptionalIn(deserializer);
    return ZeroKnowledgeSignature(
      proof: proof,
      expHorizonSecs: expHorizonSecs,
      extraField: extraField,
      overrideAudVal: overrideAudVal,
      trainingWheelsSignature: trainingWheelsSignature,
    );
  }

  @override
  void serializeIn(Serializer serializer, ZeroKnowledgeSignature value) {
    _zkProofSerializer.serializeIn(serializer, value.proof);
    serializer.serializeU64(value.expHorizonSecs);
    serializer.serializeOptionalStr(value.extraField);
    serializer.serializeOptionalStr(value.overrideAudVal);
    EphemeralSignature.bcsSerializer.serializeOptionalIn(
      serializer,
      value.trainingWheelsSignature,
    );
  }
}

enum EphemeralCertificateVariant {
  zkProof._(0);

  const EphemeralCertificateVariant._(int value) : _internal = value;

  final int _internal;
}

class EphemeralCertificate {
  final dynamic signature;
  final EphemeralCertificateVariant variant;

  static const BCSSerializer<EphemeralCertificate> bcsSerializer =
      _EphemeralCertificateSerializer._();

  EphemeralCertificate({required this.signature, required this.variant});
}

class _EphemeralCertificateSerializer
    implements BCSSerializer<EphemeralCertificate> {
  static const _zeroKnowledgeSignatureSerializer =
      _ZeroKnowledgeSignatureSerializer._();

  const _EphemeralCertificateSerializer._();

  @override
  EphemeralCertificate deserializeIn(Deserializer deserializer) {
    final type = deserializer.deserializeUleb128AsU32();
    if (EphemeralCertificateVariant.zkProof._internal == type) {
      return EphemeralCertificate(
        signature: _zeroKnowledgeSignatureSerializer.deserializeIn(
          deserializer,
        ),
        variant: EphemeralCertificateVariant.zkProof,
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, EphemeralCertificate value) {
    serializer.serializeU32AsUleb128(value.variant._internal);
    if (value.variant == EphemeralCertificateVariant.zkProof) {
      _zeroKnowledgeSignatureSerializer.serializeIn(
        serializer,
        value.signature,
      );
    } else {
      throw UnimplementedError();
    }
  }
}
