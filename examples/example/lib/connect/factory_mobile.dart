import 'package:aptos_connect/aptos_connect.dart';
import 'package:aptos_connect/aptos_connect_io.dart';

class MemoryKVStorage implements KVStorage {
  final Map<String, String> _map = {};
  @override
  Future<String?> getValue(String key) async {
    return _map[key];
  }

  @override
  Future<void> removeValue(String key) async {
    _map.remove(key);
  }

  @override
  Future<void> setValue(String key, String value) async {
    _map[key] = value;
  }
}

AptosConnectClientFactory getAptosConnectClientFactory() {
  return AptosConnectClientFactoryIO(
    dAppName: 'Test app',
    dAppImageUrl: '',
    storage: MemoryKVStorage(),
  );
}
