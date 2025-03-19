import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:aptos_connect/bcs/serializer.dart';
import 'package:aptos_connect/crypto/crypto_client.dart';
import 'package:aptos_connect/model/provider.dart';
import 'package:aptos_connect/model/wallet_request.dart';
import 'package:aptos_connect/transport/transport.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:uuid/uuid.dart';

// class AptosConnectionObject<T> {
//   final Completer<T> _completer = Completer();
//   final String _connectUrl;
//   final String _domain;
//
//   AptosConnectionObject._({required String connectUrl, required String domain})
//     : _connectUrl = connectUrl,
//       _domain = domain;
//
//   Future<T> waitResult() {
//     return _completer.future;
//   }
//
//   Future<void> _pageHandler(
//     InAppWebViewController controller,
//     WebUri? url,
//   ) async {
//     if (url != null) {
//       print("PAGE HANDLER APTOS CONNECT: $url");
//     }
//   }
//
//   void close() {
//     _completer.complete();
//   }
//
//   InAppWebView buildWebView() {
//     return InAppWebView(
//       initialSettings: InAppWebViewSettings(
//         javaScriptEnabled: true,
//         javaScriptCanOpenWindowsAutomatically: true,
//         supportMultipleWindows: true,
//         allowUniversalAccessFromFileURLs: true,
//         clearCache: true,
//         userAgent:
//             'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
//         clearSessionCache: true,
//         // useShouldOverrideUrlLoading: true,
//       ),
//       initialUrlRequest: URLRequest(
//         url: WebUri(_connectUrl),
//         headers: {
//           'Referer': _domain,
//           'Sec-Fetch-Dest': 'document',
//           'Sec-Fetch-Mode': 'navigate',
//           'Sec-Fetch-Site': 'same-origin',
//         },
//       ),
//       onLoadStop: _pageHandler,
//     );
//   }
// }

class AptosConnectBrowser extends InAppBrowser {
  @override
  void onLoadStart(WebUri? url) {
    super.onLoadStart(url);
    print("Aptos connect onLoadStart: $url");
  }
}

class AptosConnectOutsideBrowser extends ChromeSafariBrowser {
  @override
  void onInitialLoadDidRedirect(WebUri? url) {
    super.onInitialLoadDidRedirect(url);
    print("Aptos connect onLoadStart: $url");
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
  Future performWalletRequest(
    WalletRequest request, {
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

    final browser = AptosConnectOutsideBrowser();

    await browser.open(url: WebUri(uri.toString()));
  }
}
