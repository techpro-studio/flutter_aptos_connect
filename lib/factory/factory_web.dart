import 'package:aptos_connect/client/client.dart';
import 'package:aptos_connect/factory/factory.dart';

class AptosConnectClientFactoryWeb implements AptosConnectClientFactory {
  final String dAppDomain;
  final String? dAppName;
  final String? dAppImageUrl;

  AptosConnectClientFactoryWeb({
    required this.dAppDomain,
    required this.dAppName,
    required this.dAppImageUrl,
  });

  @override
  AptosConnectClient make() {
    throw UnimplementedError("Need to implement");
  }
}
