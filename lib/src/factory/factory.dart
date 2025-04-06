import 'package:aptos_connect/src/client/client.dart';

abstract class AptosConnectClientFactory {
  AptosConnectClient make();
}
