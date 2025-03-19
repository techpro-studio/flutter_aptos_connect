import 'package:aptos_connect/model/provider.dart';
import 'package:aptos_connect/model/wallet_request.dart';

abstract class Transport {
  Future performWalletRequest(WalletRequest request, {AptosProvider? provider});
}
