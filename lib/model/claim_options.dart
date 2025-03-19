import 'dart:typed_data';

import 'package:aptos_connect/bcs/deserializer.dart';
import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/model/network.dart';
import 'package:aptos_connect/model/serializer.dart';

class ClaimOptions {
  final String? asset;
  final NetworkEnum network;
  final Uint8List privateKey;

  ClaimOptions({this.asset, required this.network, required this.privateKey});

  static const bcsSerializer = _ClaimOptionsBCSSerializer._();
}

class _ClaimOptionsBCSSerializer implements BCSSerializer<ClaimOptions> {
  const _ClaimOptionsBCSSerializer._();

  @override
  ClaimOptions deserialize(Uint8List bytes) {
    final deserializer = Deserializer(bytes);
    final privateKeyBytes = deserializer.deserializeBytes();
    final networkString = deserializer.deserializeStr();
    final asset = deserializer.deserializeOptionalStr();
    return ClaimOptions(
      network: NetworkEnum.parse(networkString)!,
      privateKey: privateKeyBytes,
      asset: asset,
    );
  }

  @override
  void serializeIn(Serializer serializer, ClaimOptions value) {
    serializer.serialize(value.privateKey);
    serializer.serializeStr(value.network.toString());
    serializer.serializeOptionalStr(value.asset);
  }
}
