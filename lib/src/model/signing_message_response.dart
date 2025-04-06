import 'package:aptos_core/aptos_core.dart';

class SigningMessageResponse implements BCSSerializable {
  final String fullMessage;
  final Signature signature;

  SigningMessageResponse({required this.fullMessage, required this.signature});

  static const BCSSerializer<SigningMessageResponse> bcsSerializer =
      _SigningMessageResponseSerializer._();

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _SigningMessageResponseSerializer
    implements BCSSerializer<SigningMessageResponse> {
  const _SigningMessageResponseSerializer._();

  @override
  SigningMessageResponse deserializeIn(Deserializer deserializer) {
    final fullMessage = deserializer.deserializeStr();
    final signature = SignatureSerializer.bcsSerializer.deserializeIn(
      deserializer,
    );
    return SigningMessageResponse(
      fullMessage: fullMessage,
      signature: signature,
    );
  }

  @override
  void serializeIn(Serializer serializer, SigningMessageResponse value) {
    serializer.serializeStr(value.fullMessage);
    SignatureSerializer.bcsSerializer.serializeIn(serializer, value.signature);
  }
}
