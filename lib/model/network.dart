class NetworkEnum {
  final String _key;
  final int chainId;

  const NetworkEnum._(this._key, this.chainId);

  static const mainNet = NetworkEnum._("mainnet", 1);
  static const testNet = NetworkEnum._("testnet", 2);
  static const devNet = NetworkEnum._("devnet", 3);
  static const local = NetworkEnum._("local", 4);
  static const custom = NetworkEnum._("custom", 5);

  static List<NetworkEnum> options = [mainNet, testNet, devNet, local, custom];

  static NetworkEnum? parseKey(String key) {
    final query = options.where((e) => e._key == key);
    if (query.isEmpty) {
      return null;
    }
    return query.first;
  }

  static NetworkEnum? parseChainId(int chainId) {
    final query = options.where((e) => e.chainId == chainId);
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
