import 'package:aptos_connect/aptos_connect.dart';
import 'package:example/connect/factory_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'factory_mobile.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'factory_web.dart';

AptosConnectClient getAptosClient() => getAptosConnectClientFactory().make();
