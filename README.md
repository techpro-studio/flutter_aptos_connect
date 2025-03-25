**Aptos Connect package.**

Port was done from:

Mobile -> https://www.npmjs.com/package/@aptos-connect/react-native-dapp-sdk 

Web -> https://www.npmjs.com/package/@identity-connect/dapp-sdk

Implemented functionality:

    1. Connect wallet 
    2. Sign message

Remaining to implement:

    1. Sign a transaction
    2. Sign and submit a transaction.


Feel free to contribute with remaining fuctionality.

Package has been built the way you can inject components. Also default factories exist in factory folder.


To reduce amount of dependencies, KVStorage is abstract and Web Implementation exists only. 


Here is an example how it could be used with default factories:

**Mobile**:

```dart

// it should be implementation of KVStorage
final storage = SecureStorage();

final mobileFactory = AptosConnectClientFactoryIO(
          dAppName: 'App',
          dAppImageUrl:
              'https://avatars.githubusercontent.com/u/183836391?s=400&u=1ffaf9cebe6f1630901bfc4784e80f6855d1f785&v=4',
          storage: storage,
);

final client = mobileFactory.make();


```

**Web**

```dart
final client  = AptosConnectClientFactoryWeb(
          dAppName: 'App',
          dAppImageUrl:
              'https://avatars.githubusercontent.com/u/183836391?s=400&u=1ffaf9cebe6f1630901bfc4784e80f6855d1f785&v=4',
).make();

```

Inside factories there is default assembly of AptosConnectClient. If you need to inject custom components with your own object lifecycle feel free to instantiate AptosConnectClient on your own. 

once AptosConnectClient built you can use it for implemented functions.

```dart

  client.connect(AptosProvider.google);
  
  //or
  
  client.connect(AptosProvider.apple);
  
  // or 
  
  client.signMessage(SigningMessageRequest.fromStringAndNowNonce('Salam'));
```



