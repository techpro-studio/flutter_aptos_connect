import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/crypto/crypto_client.dart';
import 'package:aptos_connect/model/provider.dart';
import 'package:aptos_connect/model/serializer.dart';
import 'package:aptos_connect/model/wallet_request.dart';
import 'package:aptos_connect/model/wallet_response.dart';
import 'package:aptos_connect/transport/transport.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:uuid/uuid.dart';

enum AptosConnectBrowserError { cancelled }

class AptosConnectBrowser extends InAppBrowser {
  Completer<String>? _completer = Completer();

  final String redirectUri;

  AptosConnectBrowser(this.redirectUri) : super();

  @override
  void onLoadStart(WebUri? url) {
    if (url == null) return;
    if (!url.toString().startsWith(redirectUri)) {
      return;
    }
    if (_completer == null) {
      return;
    }
    _completer!.complete(url.queryParameters['response']);
    _completer = null;
    close();
  }

  @override
  void onExit() {
    if (_completer != null) {
      // means 0x0 byte.
      _completer!.complete('AA');
      _completer = null;
    }
  }
}

class SignedPopupWalletRequest {
  final WalletRequest body;
  final Uint8List clientIdentityKey;
  final String id;
  final Uint8List signature;
  final int timestamp;

  SignedPopupWalletRequest({
    required this.body,
    required this.clientIdentityKey,
    required this.id,
    required this.signature,
    required this.timestamp,
  });

  static const _kBody = 'body';
  static const _kClientIdentityKey = 'clientIdentityKey';
  static const _kId = 'id';
  static const _kSignature = 'signature';
  static const _kTimestamp = 'timestamp';

  String encode() {
    return base64Encode(
      utf8.encode(
        jsonEncode({
          _kBody: body.encodeToJsonBase64(),
          _kClientIdentityKey: base64.encode(clientIdentityKey),
          _kId: id,
          _kSignature: base64.encode(signature),
          _kTimestamp: timestamp,
        }),
      ),
    );
  }
}

class IOTransportConfig {
  final String baseUrl;
  final String redirectUrl;

  IOTransportConfig({required this.baseUrl, required this.redirectUrl});
}

class IOTransport implements Transport {
  final CryptoClient _cryptoClient;

  final IOTransportConfig _config;

  IOTransport(this._cryptoClient, this._config);

  Uint8List _makePopupWalletRequestChallenge(
    WalletRequest request,
    String id,
    int timestamp,
  ) {
    final serializer = Serializer();
    serializer.serializeStr('SignedPopupWalletRequest');
    serializer.serializeStr(id);
    serializer.serializeU64(BigInt.from(timestamp));
    serializer.serializeBool(false);
    serializer.serializeStr(request.name);
    serializer.serializeU8(request.version);
    serializer.serializeBytes(request.data);
    return serializer.getBytes();
  }

  @override
  Future<WalletResponse<T>> performWalletRequest<T>(
    WalletRequest request,
    BCSSerializer<T> tSerializer, {
    AptosProvider? provider,
  }) async {
    final keyPair = await _cryptoClient.getKeyPair();
    final clientIdentityKey = keyPair.publicKey;
    final requestId = Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final challenge = _makePopupWalletRequestChallenge(request, requestId, now);
    final signature = await _cryptoClient.signMessage(challenge);

    final signedPopupWalletRequest = SignedPopupWalletRequest(
      body: request,
      clientIdentityKey: clientIdentityKey,
      id: requestId,
      signature: signature,
      timestamp: now,
    );

    final encodedSignedPopupWalletRequest = signedPopupWalletRequest.encode();

    final uri = Uri.parse(_config.baseUrl).replace(
      path: "prompt",
      queryParameters: {
        if (provider != null) 'provider': provider.name,
        'redirectUri': _config.redirectUrl,
        'request': encodedSignedPopupWalletRequest,
      },
    );

    final browser = AptosConnectBrowser(_config.redirectUrl);

    await browser.openUrlRequest(
      settings: InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(
          hideUrlBar: true,
          hideCloseButton: false,
          toolbarTopFixedTitle: "Aptos connect",
        ),
        webViewSettings: InAppWebViewSettings(
          userAgent:
              Platform.isIOS
                  ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1'
                  : 'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
        ),
      ),
      urlRequest: URLRequest(url: WebUri(uri.toString())),
    );

    final result = await browser._completer!.future;

    final decoded = base64.decode(base64.normalize(result));

    final walletResponseSerializer = WalletResponseSerializer(tSerializer);

    return walletResponseSerializer.deserialize(decoded);
  }
}
