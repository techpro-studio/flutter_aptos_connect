import 'dart:typed_data';

import 'package:aptos_connect/bcs/deserializer.dart';
import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/model/serializer.dart';


class DAppInfo {
  final String domain;
  final String name;
  final String? imageUrl;

  DAppInfo({required this.domain, required this.name, required this.imageUrl,});

  static const bcsSerializer = _DAppInfoSerializer._();
}


class _DAppInfoSerializer implements BCSSerializer<DAppInfo> {

  const _DAppInfoSerializer._();

  @override
  DAppInfo deserialize(Uint8List bytes) {
      final deserializer = Deserializer(bytes);
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

