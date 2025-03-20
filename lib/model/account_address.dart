import 'dart:typed_data';

import 'package:aptos_connect/bcs/deserializer.dart';
import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/model/hex_string.dart';
import 'package:aptos_connect/model/serializer.dart';

class AccountAddress implements BCSSerializable {
  static const int length = 32;
  static const String _coreCodeAddress = "0x1";

  final Uint8List address;

  AccountAddress(this.address) {
    if (address.length != AccountAddress.length) {
      throw ArgumentError("Expected address of length 32");
    }
  }

  String hexAddress() {
    return HexString.fromBuffer(address).hex();
  }

  static AccountAddress coreCodeAddress() {
    return AccountAddress.fromHex(_coreCodeAddress);
  }

  static AccountAddress fromHex(String addr) {
    var address = HexString.ensure(addr);

    // If an address hex has odd number of digits, padd the hex string with 0
    // e.g. '1aa' would become '01aa'.
    if (address.noPrefix().length % 2 != 0) {
      address = HexString("0${address.noPrefix()}");
    }

    Uint8List addressBytes = address.toUint8Array();

    if (addressBytes.length > AccountAddress.length) {
      throw ArgumentError(
        "Hex string is too long. Address's length is 32 bytes.",
      );
    } else if (addressBytes.length == AccountAddress.length) {
      return AccountAddress(addressBytes);
    }

    final res = Uint8List(AccountAddress.length);
    res.setAll(AccountAddress.length - addressBytes.length, addressBytes);

    return AccountAddress(res);
  }

  static bool isValid(String addr) {
    // At least one zero is required
    if (addr.isEmpty) {
      return false;
    }

    var address = HexString.ensure(addr);

    // If an address hex has odd number of digits, padd the hex string with 0
    // e.g. '1aa' would become '01aa'.
    if (address.noPrefix().length % 2 != 0) {
      address = HexString("0${address.noPrefix()}");
    }

    final addressBytes = address.toUint8Array();

    return addressBytes.length <= AccountAddress.length;
  }

  static standardizeAddress(String address) {
    final lowercaseAddress = address.toLowerCase();
    final addressWithoutPrefix =
        lowercaseAddress.startsWith("0x")
            ? lowercaseAddress.substring(2)
            : lowercaseAddress;
    final addressWithPadding = addressWithoutPrefix.padLeft(64, "0");
    return "0x$addressWithPadding";
  }

  static const BCSSerializer<AccountAddress> bcsSerializer =
      _AccountAddressSerializer._();

  @override
  void serializeBCS(Serializer serializer) {
    return bcsSerializer.serializeIn(serializer, this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAddress &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;
}

class _AccountAddressSerializer implements BCSSerializer<AccountAddress> {
  const _AccountAddressSerializer._();

  @override
  AccountAddress deserializeIn(Deserializer deserializer) {
    return AccountAddress(
      deserializer.deserializeFixedBytes(AccountAddress.length),
    );
  }

  @override
  void serializeIn(Serializer serializer, AccountAddress value) {
    serializer.serializeFixedBytes(value.address);
  }
}
