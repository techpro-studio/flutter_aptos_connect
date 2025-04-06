import 'package:aptos_core/aptos_core.dart';

class DAppInfo implements BCSSerializable {
  final String domain;
  final String name;
  final String? imageUrl;

  DAppInfo({required this.domain, required this.name, required this.imageUrl});

  static const BCSSerializer<DAppInfo> bcsSerializer = _DAppInfoSerializer._();

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _DAppInfoSerializer implements BCSSerializer<DAppInfo> {
  const _DAppInfoSerializer._();

  @override
  DAppInfo deserializeIn(Deserializer deserializer) {
    final domain = deserializer.deserializeStr();
    final name = deserializer.deserializeStr();
    String? imageUrl;
    final imageUrlExists = deserializer.deserializeBool();
    if (imageUrlExists) {
      imageUrl = deserializer.deserializeStr();
    }
    return DAppInfo(domain: domain, name: name, imageUrl: imageUrl);
  }

  @override
  void serializeIn(Serializer serializer, DAppInfo value) {
    serializer.serializeStr(value.domain);
    serializer.serializeStr(value.name);
    final imageUrlExists = value.imageUrl != null;
    serializer.serializeBool(imageUrlExists);
    if (imageUrlExists) {
      serializer.serializeStr(value.imageUrl!);
    }
  }
}
