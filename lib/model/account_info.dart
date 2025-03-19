import 'dart:typed_data';

import 'package:aptos_connect/model/account_address.dart';

class AccountInfo {
  final String? name;
  final Uint8List publicKey;
  final AccountAddress address;

  AccountInfo({
    required this.name,
    required this.publicKey,
    required this.address,
  });
}
