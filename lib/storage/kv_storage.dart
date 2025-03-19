abstract class KVStorage {
  Future<String?> getValue(String key);
  Future<void> setValue(String key, String value);
  Future<void> removeValue(String key);
}