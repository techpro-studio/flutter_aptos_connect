import 'dart:convert';
import 'dart:typed_data';

import 'package:aptos_connect/bcs/serializer.dart';

class WalletRequest {
  final String name;
  final int version;
  final Uint8List data;

  WalletRequest({
    required this.name,
    required this.version,
    required this.data,
  });

  static const _kName = 'name';
  static const _kVersion = 'version';
  static const _kData = 'data';

  String encodeToJsonBase64() {
    return base64Encode(
      utf8.encode(
        jsonEncode({
          _kData: base64Encode(data),
          _kName: name,
          _kVersion: version,
        }),
      ),
    );
  }

  String encodeToBcsUrlBase64() {
    final serializer = Serializer();
    serializer.serializeStr(name);
    serializer.serializeBytes(data);
    serializer.serializeStr(version.toString());
    return base64UrlEncode(serializer.getBytes());
  }
}
