import 'dart:convert';

import 'package:aptos_connect/src/model/account_info.dart';
import 'package:aptos_core/aptos_core.dart';

class ConnectResponse {
  final AccountInfo accountInfo;
  final Map<String, dynamic>? pairingData;

  static const BCSSerializer<ConnectResponse> bcsSerializer =
      _ConnectResponseSerializer._();

  ConnectResponse({required this.accountInfo, required this.pairingData});
}

class _ConnectResponseSerializer implements BCSSerializer<ConnectResponse> {
  const _ConnectResponseSerializer._();
  @override
  ConnectResponse deserializeIn(Deserializer deserializer) {
    final accountInfo = AccountInfo.bcsSerializer.deserializeIn(deserializer);
    final pairingString = deserializer.deserializeOptionalStr();
    Map<String, dynamic>? pairingData;
    if (pairingString != null) {
      pairingData = jsonDecode(pairingString);
    }
    return ConnectResponse(accountInfo: accountInfo, pairingData: pairingData);
  }

  @override
  void serializeIn(Serializer serializer, ConnectResponse value) {
    value.accountInfo.serializeBCS(serializer);
    serializer.serializeOptionalStr(
      value.pairingData != null ? jsonEncode(value.pairingData) : null,
    );
  }
}
