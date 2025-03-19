import 'package:aptos_connect/model/provider.dart';
import 'package:aptos_connect/model/wallet_request.dart';
import 'package:aptos_connect/transport/transport.dart';

class WebTransport implements Transport {
  WebTransport();

  @override
  Future performWalletRequest(
    WalletRequest request, {
    AptosProvider? provider,
  }) async {}
}
