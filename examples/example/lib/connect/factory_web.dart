import 'package:aptos_connect/factory/factory.dart';
import 'package:aptos_connect/factory/factory_web.dart'
    show AptosConnectClientFactoryWeb;

AptosConnectClientFactory getAptosConnectClientFactory() {
  return AptosConnectClientFactoryWeb(dAppName: 'Test app', dAppImageUrl: '');
}
