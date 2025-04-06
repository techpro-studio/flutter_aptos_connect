import 'dart:convert';
import 'dart:typed_data';

import 'package:aptos_core/aptos_core.dart';

class SigningMessageRequest implements BCSSerializable {
  final Uint8List message;
  final Network network;
  final Uint8List nonce;
  final AccountAddress? signer;

  factory SigningMessageRequest.fromStringAndNowNonce(
    String message, {
    Network network = Network.mainNet,
    AccountAddress? signer,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return SigningMessageRequest(
      message: utf8.encode(message),
      nonce: utf8.encode(now.toString()),
      network: network,
      signer: signer,
    );
  }

  static const BCSSerializer<SigningMessageRequest> bcsSerializer =
      _SigningMessageRequestSerializer._();

  SigningMessageRequest({
    required this.message,
    required this.nonce,
    required this.network,
    required this.signer,
  });

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _SigningMessageRequestSerializer
    implements BCSSerializer<SigningMessageRequest> {
  const _SigningMessageRequestSerializer._();
  @override
  SigningMessageRequest deserializeIn(Deserializer deserializer) {
    final hasSigner = deserializer.deserializeBool();
    AccountAddress? signer;
    if (hasSigner) {
      signer = AccountAddress.bcsSerializer.deserializeIn(deserializer);
    }
    final chainId = deserializer.deserializeU8();
    final nonce = deserializer.deserializeBytes();
    final message = deserializer.deserializeBytes();
    return SigningMessageRequest(
      message: message,
      nonce: nonce,
      network: Network.parseChainId(chainId)!,
      signer: signer,
    );
  }

  @override
  void serializeIn(Serializer serializer, SigningMessageRequest value) {
    serializer.serializeBool(value.signer != null);
    if (value.signer != null) {
      value.signer!.serializeBCS(serializer);
    }
    serializer.serializeU8(value.network.chainId);
    serializer.serializeBytes(value.nonce);
    serializer.serializeBytes(value.message);
  }
}
