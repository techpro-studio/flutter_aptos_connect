import 'package:aptos_connect/model/account_address.dart';
import 'package:pinenacl/api.dart';

class AccountInfo {
  final String? name;
  final PublicKey publicKey;
  final AccountAddress address;

  AccountInfo({
    required this.name,
    required this.publicKey,
    required this.address,
  });
}
