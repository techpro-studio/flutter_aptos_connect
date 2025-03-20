import 'package:aptos_connect/model/provider.dart';
import 'package:aptos_connect/model/serializer.dart';
import 'package:aptos_connect/model/wallet_request.dart';
import 'package:aptos_connect/model/wallet_response.dart';
import 'package:aptos_connect/transport/transport.dart';

class WebTransport implements Transport {
  WebTransport();

  @override
  Future<WalletResponse<T>> performWalletRequest<T>(
    WalletRequest request,
    BCSSerializer<T> tSerializer, {
    AptosProvider? provider,
  }) {
    throw UnimplementedError();
  }
}
