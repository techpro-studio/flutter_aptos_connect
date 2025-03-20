import 'package:aptos_connect/model/account_info.dart';

abstract class AccountsStorage {
  Future<List<AccountInfo>> getAccounts();

  Future<void> appendAccount(AccountInfo account);

  Future<void> removeAccounts();

  Future<void> removeAccount(AccountInfo account);
}
