import 'package:aptos_connect/bcs/deserializer.dart';
import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/model/serializer.dart';
import 'package:aptos_connect/model/signature.dart';

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
    final signature = Signature.bcsSerializer.deserializeIn(deserializer);
    return SigningMessageResponse(
      fullMessage: fullMessage,
      signature: signature,
    );
  }

  @override
  void serializeIn(Serializer serializer, SigningMessageResponse value) {
    serializer.serializeStr(value.fullMessage);
    value.signature.serializeBCS(serializer);
  }
}
