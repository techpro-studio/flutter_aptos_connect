import 'package:aptos_connect/storage/kv_storage.dart';
import 'package:web/web.dart';

class KVStorageWeb implements KVStorage {
  @override
  Future<String?> getValue(String key) async {
    return window.localStorage.getItem(key);
  }

  @override
  Future<void> removeValue(String key) async {
    window.localStorage.removeItem(key);
  }

  @override
  Future<void> setValue(String key, String value) async {
    window.localStorage.setItem(key, value);
  }
}
