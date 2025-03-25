import 'package:aptos_connect/client/client.dart';
import 'package:aptos_connect/model/provider.dart';
import 'package:aptos_connect/model/signing_message_request.dart';
import 'package:example/connect/factory.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aptos Connect Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
      home: const MyHomePage(title: 'Aptos Connect Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AptosConnectClient client = getAptosClient();

  String? connectedAddress;

  final TextEditingController _signingMessageController =
      TextEditingController();

  @override
  void initState() {
    client.getConnectedAccounts().then(
      (accounts) => setState(() {
        connectedAddress = accounts.firstOrNull?.address.hexAddress();
      }),
    );
    super.initState();
  }

  Future<void> handle() async {
    if (connectedAddress == null) {
      final account = await client.connect(AptosProvider.google);
      setState(() {
        connectedAddress = account?.address.hexAddress();
      });
    } else {
      await client.disconnectAll();
      setState(() {
        connectedAddress = null;
      });
    }
  }

  Future<void> signMessage() async {
    final signedMessage = await client.signMessage(
      SigningMessageRequest.fromStringAndNowNonce(
        _signingMessageController.text.trim(),
      ),
    );
    if (signedMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(signedMessage.fullMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            spacing: 20.0,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(connectedAddress ?? 'N/A'),
              ElevatedButton(
                onPressed: handle,
                child:
                    connectedAddress == null
                        ? Text("Connect Google")
                        : Text('Disconnect'),
              ),
              if (connectedAddress != null)
                TextFormField(
                  controller: _signingMessageController,
                  decoration: InputDecoration(labelText: 'Signing message'),
                ),
              if (connectedAddress != null)
                ElevatedButton(
                  onPressed: signMessage,
                  child: Text("Sign message"),
                ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
