import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui';

import 'package:aptos_connect/src/model/provider.dart';
import 'package:aptos_connect/src/model/wallet_request.dart';
import 'package:aptos_connect/src/model/wallet_response.dart';
import 'package:aptos_connect/src/transport/transport.dart';
import 'package:aptos_core/aptos_core.dart';
import 'package:web/web.dart' as web;

class WebTransportConfig {
  final String baseUrl;

  WebTransportConfig({required this.baseUrl});
}

class PromptUnauthorizedError implements Exception {}

class PromptMessage {
  final String type;
  final Map<String, dynamic>? serializedValue;

  static const approvalResponse = 'PromptApprovalResponse';
  static const unauthorizedError = 'PromptUnauthorizedError';
  static const pingRequest = 'PromptOpenerPingRequest';

  static const _kMessageType = '__messageType';
  static const _kSerializedValue = 'serializedValue';

  static const _kData = 'data';

  PromptMessage({required this.type, required this.serializedValue});

  String toJson() {
    return jsonEncode({
      _kMessageType: type,
      if (serializedValue != null) _kSerializedValue: serializedValue,
    });
  }

  static PromptMessage? fromJson(dynamic value) {
    if (value == null) {
      return null;
    }
    final type = value[_kMessageType];
    final serializedValue =
        value[_kSerializedValue] == null
            ? null
            : Map<String, dynamic>.from(value[_kSerializedValue]);
    return PromptMessage(type: type, serializedValue: serializedValue);
  }

  WalletResponse<T>? deserializeWalletResponse<T>(BCSSerializer<T> serializer) {
    if (type != approvalResponse) {
      return null;
    }
    if (serializedValue == null) {
      return null;
    }
    final List<int> byteList = List<int>.from(serializedValue![_kData]);
    return WalletResponseSerializer(
      serializer,
    ).deserialize(Uint8List.fromList(byteList));
  }
}

const defaultPromptSize = Size(465, 695);

class WebTransport implements Transport {
  final WebTransportConfig _config;

  WebTransport(this._config);

  web.Window _openPrompt(Uri url, [Size size = defaultPromptSize]) {
    final height = size.height;
    final width = size.width;

    final options = {
      'height': height,
      'left':
          web.window.screenLeft + ((web.window.outerWidth - width) / 2).round(),
      'popup': true,
      'top':
          web.window.screenTop +
          ((web.window.outerHeight - height) / 2).round(),
      'width': width,
    };

    final strOptions = options.entries
        .map((entry) => '${entry.key}=${jsonEncode(entry.value)}')
        .join(', ');

    final promptWindow = web.window.open(url.toString(), '', strOptions);

    if (promptWindow == null) {
      throw Exception("Couldn't open prompt");
    }

    return promptWindow;
  }

  @override
  Future<WalletResponse<T>> performWalletRequest<T>(
    WalletRequest request,
    BCSSerializer<T> tSerializer, {
    AptosProvider? provider,
  }) async {
    final Completer<WalletResponse<T>> completer =
        Completer<WalletResponse<T>>();

    final encodedRequest = request.encodeToBcsUrlBase64();
    final url = Uri.parse(_config.baseUrl).replace(
      path: 'prompt',
      queryParameters: {
        'request': encodedRequest,
        if (provider != null) 'provider': provider.name,
      },
    );
    final promptWindow = _openPrompt(url);

    final timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
      if (promptWindow.closed && !completer.isCompleted) {
        completer.complete(WalletResponse(approved: false, value: null));
      }
    });

    final messageSubscription = web.window.onMessage.listen((
      web.MessageEvent event,
    ) {
      if (event.origin != _config.baseUrl) {
        return;
      }
      final data = event.data.dartify();
      if (data == null) {
        return;
      }
      final promptResponse = PromptMessage.fromJson(data);
      if (promptResponse == null) {
        return;
      }
      switch (promptResponse.type) {
        case PromptMessage.approvalResponse:
          if (!completer.isCompleted) {
            completer.complete(
              promptResponse.deserializeWalletResponse(tSerializer),
            );
          }
        case PromptMessage.unauthorizedError:
          if (!completer.isCompleted) {
            completer.completeError(PromptUnauthorizedError());
          }
        case PromptMessage.pingRequest:
          promptWindow.postMessage(
            PromptMessage(
              type: 'PromptOpenerPingResponse',
              serializedValue: null,
            ).toJson().toJS,
            _config.baseUrl.toJS,
          );
      }
    });

    return completer.future.whenComplete(() {
      timer.cancel();
      messageSubscription.cancel();
    });
  }
}

/*
Approval example {"serializedValue":{"data":[1,160,218,162,232,141,106,79,241,1,154,70,40,118,165,95,147,211,18,127,202,118,40,26,36,163,221,253,246,71,227,91,103,2,3,27,104,116,116,112,115,58,47,47,97,99,99,111,117,110,116,115,46,103,111,111,103,108,101,46,99,111,109,32,31,83,189,180,211,212,242,25,76,59,100,132,12,3,254,179,188,130,50,115,253,85,49,205,209,200,150,63,195,85,186,0,0,0]},"__messageType":"PromptApprovalResponse"}
* */
