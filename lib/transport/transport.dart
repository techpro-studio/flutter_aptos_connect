import 'package:aptos_connect/model/provider.dart';
import 'package:aptos_connect/model/serializer.dart';
import 'package:aptos_connect/model/wallet_request.dart';
import 'package:aptos_connect/model/wallet_response.dart';

abstract class Transport {
  Future<WalletResponse<T>> performWalletRequest<T>(
    WalletRequest request,
    BCSSerializer<T> tSerializer, {
    AptosProvider? provider,
  });
}
