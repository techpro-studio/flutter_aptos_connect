import 'package:aptos_connect/bcs/deserializer.dart';
import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/model/account_address.dart';
import 'package:aptos_connect/model/public_key.dart';
import 'package:aptos_connect/model/serializer.dart';

class AccountInfo extends BCSSerializable {
  final String? name;
  final PublicKey publicKey;
  final AccountAddress address;

  AccountInfo({
    required this.name,
    required this.publicKey,
    required this.address,
  });

  static const BCSSerializer<AccountInfo> bcsSerializer =
      _AccountInfoSerializer._();

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);
}

class _AccountInfoSerializer implements BCSSerializer<AccountInfo> {
  const _AccountInfoSerializer._();

  @override
  AccountInfo deserializeIn(Deserializer deserializer) {
    final address = AccountAddress.bcsSerializer.deserializeIn(deserializer);
    final publicKey = PublicKey.bcsSerializer.deserializeIn(deserializer);
    final name = deserializer.deserializeStr();
    return AccountInfo(
      name: name.isEmpty ? null : name,
      publicKey: publicKey,
      address: address,
    );
  }

  @override
  void serializeIn(Serializer serializer, AccountInfo value) {
    value.address.serializeBCS(serializer);
    value.publicKey.serializeBCS(serializer);
    serializer.serializeStr(value.name ?? '');
  }
}
