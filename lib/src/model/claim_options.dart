import 'dart:typed_data';

import 'package:aptos_core/aptos_core.dart';

class ClaimOptions implements BCSSerializable {
  final String? asset;
  final Network network;
  final Uint8List privateKey;

  ClaimOptions({this.asset, required this.network, required this.privateKey});

  static const BCSSerializer<ClaimOptions> bcsSerializer =
      _ClaimOptionsBCSSerializer._();

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _ClaimOptionsBCSSerializer implements BCSSerializer<ClaimOptions> {
  const _ClaimOptionsBCSSerializer._();

  @override
  ClaimOptions deserializeIn(Deserializer deserializer) {
    final privateKeyBytes = deserializer.deserializeBytes();
    final networkString = deserializer.deserializeStr();
    final asset = deserializer.deserializeOptionalStr();
    return ClaimOptions(
      network: Network.parseKey(networkString)!,
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
