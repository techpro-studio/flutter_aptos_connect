import 'package:aptos_connect/storage/kv_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KVStorageIO implements KVStorage {
  final FlutterSecureStorage _secureStorage;

  KVStorageIO(this._secureStorage);

  @override
  Future<String?> getValue(String key) {
    return _secureStorage.read(key: key);
  }

  @override
  Future<void> removeValue(String key) {
    return _secureStorage.delete(key: key);
  }

  @override
  Future<void> setValue(String key, String value) {
    return _secureStorage.write(key: key, value: value);
  }
}
