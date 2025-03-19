import 'dart:typed_data';

import 'package:aptos_connect/bcs/serializer.dart';

abstract class BCSSerializer<T> {
  void serializeIn(Serializer serializer, T value);

  T deserialize(Uint8List bytes);
}

extension BCSSerializerExt<T> on BCSSerializer<T> {
  Uint8List serialize(T value) {
    final serializer = Serializer();
    serializeIn(serializer, value);
    return serializer.getBytes();
  }
}
