import 'dart:typed_data';

import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/model/claim_options.dart';
import 'package:aptos_connect/model/serializer.dart';

class ConnectRequest {
  final ClaimOptions? claimOptions;
  final String? dAppEd25519PublicKeyB64;
  final String? dAppId;
  final String? preferredWalletName;

  ConnectRequest({
    this.claimOptions,
    this.dAppEd25519PublicKeyB64,
    this.dAppId,
    this.preferredWalletName,
  });

  static const bcsSerializer = _ConnectRequestBCSSerializer._();
}

class _ConnectRequestBCSSerializer implements BCSSerializer<ConnectRequest> {
  const _ConnectRequestBCSSerializer._();

  @override
  ConnectRequest deserialize(Uint8List bytes) {
    throw UnimplementedError("For now not done");
  }

  @override
  void serializeIn(Serializer serializer, ConnectRequest value) {
    serializer.serializeOptionalStr(value.dAppId);
    serializer.serializeOptionalStr(value.dAppEd25519PublicKeyB64);
    serializer.serializeOptionalStr(value.preferredWalletName);
    final optionsExists = value.claimOptions != null;
    serializer.serializeBool(optionsExists);
    if (optionsExists) {
      ClaimOptions.bcsSerializer.serializeIn(serializer, value.claimOptions!);
    }
  }
}
