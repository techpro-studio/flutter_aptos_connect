import 'dart:typed_data';

import 'package:aptos_connect/bcs/deserializer.dart';
import 'package:aptos_connect/bcs/serializer.dart';

abstract class BCSSerializable {
  void serializeBCS(Serializer serializer);
}

abstract class BCSSerializer<T> {
  void serializeIn(Serializer serializer, T value);

  T deserializeIn(Deserializer deserializer);
}

extension BCSSerializerExt<T> on BCSSerializer<T> {
  Uint8List serialize(T value) {
    final serializer = Serializer();
    serializeIn(serializer, value);
    return serializer.getBytes();
  }

  T deserialize(Uint8List bytes) {
    final deserializer = Deserializer(bytes);
    return deserializeIn(deserializer);
  }
}
