import 'package:aptos_core/aptos_core.dart';

class WalletResponse<T> {
  final bool approved;
  final T? value;

  WalletResponse({required this.approved, required this.value});
}

class WalletResponseSerializer<Child>
    extends BCSSerializer<WalletResponse<Child>> {
  final BCSSerializer<Child> _childSerializer;

  WalletResponseSerializer(this._childSerializer);

  @override
  WalletResponse<Child> deserializeIn(Deserializer deserializer) {
    final approved = deserializer.deserializeBool();
    Child? child;
    if (approved) {
      child = _childSerializer.deserializeIn(deserializer);
    }
    return WalletResponse(approved: approved, value: child);
  }

  @override
  void serializeIn(Serializer serializer, WalletResponse<Child> value) {
    serializer.serializeBool(value.approved);
    if (value.approved) {
      _childSerializer.serializeIn(serializer, value.value!);
    }
  }
}
