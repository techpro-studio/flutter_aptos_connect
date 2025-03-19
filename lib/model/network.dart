
class NetworkEnum {
  final String _key;

  const NetworkEnum._(this._key);

  static const mainNet = NetworkEnum._("mainnet");
  static const testNet = NetworkEnum._("testnet");
  static const devNet = NetworkEnum._("devnet");
  static const local = NetworkEnum._("local");
  static const custom = NetworkEnum._("custom");

  static List<NetworkEnum> options = [mainNet, testNet, devNet, local, custom];


  static NetworkEnum? parse(String key) {
    final query = options.where((e) => e._key == key);
    if (query.isEmpty) {
      return null;
    }
    return query.first;
  }

  @override
  String toString() {
    return _key;
  }

}