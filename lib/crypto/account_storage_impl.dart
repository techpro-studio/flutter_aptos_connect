import 'dart:convert';

import 'package:aptos_connect/bcs/deserializer.dart';
import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/crypto/accounts_storage.dart';
import 'package:aptos_connect/model/account_info.dart';
import 'package:aptos_connect/storage/kv_storage.dart';

class AccountsStorageImpl implements AccountsStorage {
  final KVStorage _kvStorage;

  static const _kAccounts = 'app.aptosconnect.accounts';

  AccountsStorageImpl({required KVStorage kvStorage}) : _kvStorage = kvStorage;

  @override
  Future<List<AccountInfo>> getAccounts() async {
    final result = await _kvStorage.getValue(_kAccounts);
    if (result == null) return [];
    final deserializer = Deserializer(base64.decode(base64.normalize(result)));
    final length = deserializer.deserializeUleb128AsU32();
    return List<AccountInfo>.generate(length, (i) {
      return AccountInfo.bcsSerializer.deserializeIn(deserializer);
    });
  }

  @override
  Future<void> appendAccount(AccountInfo account) async {
    final accounts = await getAccounts();
    accounts.add(account);
    await _setAccounts(accounts);
  }

  @override
  Future<void> removeAccounts() async {
    await _kvStorage.removeValue(_kAccounts);
  }

  @override
  Future<void> removeAccount(AccountInfo account) async {
    final accounts = await getAccounts();
    accounts.remove(account);
    if (accounts.isEmpty) {
      await removeAccounts();
    } else {
      await _setAccounts(accounts);
    }
  }

  Future<void> _setAccounts(List<AccountInfo> accounts) async {
    final serializer = Serializer();
    serializer.serializeU32AsUleb128(accounts.length);
    for (final account in accounts) {
      account.serializeBCS(serializer);
    }
    final encoded = base64Encode(serializer.getBytes());
    await _kvStorage.setValue(_kAccounts, encoded);
  }
}
