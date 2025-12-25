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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyADZhgdSifelVUJDDCc_tNDc8Y1PIUmQ-Q',
    appId: '1:218419493577:web:2dd49ed7112e52b602eb18',
    messagingSenderId: '218419493577',
    projectId: 'iot-vaccine-monitor',
    authDomain: 'iot-vaccine-monitor.firebaseapp.com',
    databaseURL: 'https://iot-vaccine-monitor-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'iot-vaccine-monitor.firebasestorage.app',
    measurementId: 'G-D9PS4W0PZN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADZhgdSifelVUJDDCc_tNDc8Y1PIUmQ-Q',
    appId: '1:218419493577:web:2dd49ed7112e52b602eb18',
    messagingSenderId: '218419493577',
    projectId: 'iot-vaccine-monitor',
    databaseURL: 'https://iot-vaccine-monitor-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'iot-vaccine-monitor.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADZhgdSifelVUJDDCc_tNDc8Y1PIUmQ-Q',
    appId: '1:218419493577:web:2dd49ed7112e52b602eb18',
    messagingSenderId: '218419493577',
    projectId: 'iot-vaccine-monitor',
    databaseURL: 'https://iot-vaccine-monitor-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'iot-vaccine-monitor.firebasestorage.app',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'com.example.iotvaccine',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyADZhgdSifelVUJDDCc_tNDc8Y1PIUmQ-Q',
    appId: '1:218419493577:web:2dd49ed7112e52b602eb18',
    messagingSenderId: '218419493577',
    projectId: 'iot-vaccine-monitor',
    databaseURL: 'https://iot-vaccine-monitor-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'iot-vaccine-monitor.firebasestorage.app',
    iosClientId: 'YOUR-MACOS-CLIENT-ID',
    iosBundleId: 'com.example.iotvaccine',
  );
} 