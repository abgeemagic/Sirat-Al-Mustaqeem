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
    apiKey: 'AIzaSyC4_RS9KvfqRl_rcU5eEZ-7leYzJbs6w4Q',
    appId: '1:958498435991:web:726220658b6a802db20ad2',
    messagingSenderId: '958498435991',
    projectId: 'final-9979b',
    authDomain: 'final-9979b.firebaseapp.com',
    storageBucket: 'final-9979b.firebasestorage.app',
    measurementId: 'G-RG9KSH506S',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3Oi5WgSaXJZeJRtLUX2ksmIIc70z_bLU',
    appId: '1:958498435991:android:20bb33d3acab79afb20ad2',
    messagingSenderId: '958498435991',
    projectId: 'final-9979b',
    storageBucket: 'final-9979b.firebasestorage.app',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyASNsGD-qTz1gMiHAQdG9tlA9gGro_BGb8',
    appId: '1:958498435991:ios:0de2baf0cdb4eb79b20ad2',
    messagingSenderId: '958498435991',
    projectId: 'final-9979b',
    storageBucket: 'final-9979b.firebasestorage.app',
    iosBundleId: 'com.example.molvi',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyASNsGD-qTz1gMiHAQdG9tlA9gGro_BGb8',
    appId: '1:958498435991:ios:0de2baf0cdb4eb79b20ad2',
    messagingSenderId: '958498435991',
    projectId: 'final-9979b',
    storageBucket: 'final-9979b.firebasestorage.app',
    iosBundleId: 'com.example.molvi',
  );
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC4_RS9KvfqRl_rcU5eEZ-7leYzJbs6w4Q',
    appId: '1:958498435991:web:baf05c99365caf1db20ad2',
    messagingSenderId: '958498435991',
    projectId: 'final-9979b',
    authDomain: 'final-9979b.firebaseapp.com',
    storageBucket: 'final-9979b.firebasestorage.app',
    measurementId: 'G-1GVG941FB5',
  );
}
