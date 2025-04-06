import 'package:aptos_core/aptos_core.dart';

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
    final publicKey = PublicKeySerializer.bcsSerializer.deserializeIn(
      deserializer,
    );
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
    PublicKeySerializer.bcsSerializer.serializeIn(serializer, value.publicKey);
    serializer.serializeStr(value.name ?? '');
  }
}
