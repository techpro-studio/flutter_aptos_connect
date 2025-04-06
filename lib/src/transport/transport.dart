import 'package:aptos_connect/src/model/provider.dart';
import 'package:aptos_connect/src/model/wallet_request.dart';
import 'package:aptos_connect/src/model/wallet_response.dart';
import 'package:aptos_core/aptos_core.dart';

abstract class Transport {
  Future<WalletResponse<T>> performWalletRequest<T>(
    WalletRequest request,
    BCSSerializer<T> tSerializer, {
    AptosProvider? provider,
  });
}
