//firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCLb6dBou3P1AugU02MoXsIPi8dinUdp1A',
    appId: '1:686578650289:web:382b7c185170400e3e6690',
    messagingSenderId: '686578650289',
    projectId: 'detection-88022',
    authDomain: 'detection-88022.firebaseapp.com',
    storageBucket: 'detection-88022.firebasestorage.app',
    measurementId: 'G-86E98HM29F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCIrZRQrMA0eQoKT6lpCTquoYM0ft71xSE',
    appId: '1:686578650289:android:8dd4a2258c8b55313e6690',
    messagingSenderId: '686578650289',
    projectId: 'detection-88022',
    storageBucket: 'detection-88022.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTAn1KbYsYmpPyI02ZC8KGY5zYBu5RwL4',
    appId: '1:686578650289:ios:2bc3bce39b8cbacb3e6690',
    messagingSenderId: '686578650289',
    projectId: 'detection-88022',
    storageBucket: 'detection-88022.firebasestorage.app',
    iosBundleId: 'com.narxoz.testSignLang',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCTAn1KbYsYmpPyI02ZC8KGY5zYBu5RwL4',
    appId: '1:686578650289:ios:2bc3bce39b8cbacb3e6690',
    messagingSenderId: '686578650289',
    projectId: 'detection-88022',
    storageBucket: 'detection-88022.firebasestorage.app',
    iosBundleId: 'com.narxoz.testSignLang',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCLb6dBou3P1AugU02MoXsIPi8dinUdp1A',
    appId: '1:686578650289:web:6903957e55d4fc343e6690',
    messagingSenderId: '686578650289',
    projectId: 'detection-88022',
    authDomain: 'detection-88022.firebaseapp.com',
    storageBucket: 'detection-88022.firebasestorage.app',
    measurementId: 'G-EE982757L7',
  );
}
