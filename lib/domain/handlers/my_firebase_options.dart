import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '',
    appId: '1:249585646098:android:7853e77a3e40571602b6cb',
    messagingSenderId: '249585646098',
    projectId: 'cheify',
    // databaseURL: 'https://onlyu-live-default-rtdb.firebaseio.com',
    storageBucket: 'cheify.appspot.com',
    authDomain: 'cheify.firebaseapp.com',
    measurementId: 'G-SK0FJ6BCPH',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: ' ',
    appId: '1:249585646098:android:7853e77a3e40571602b6cb',
    messagingSenderId: '249585646098',
    projectId: 'cheify',
    // databaseURL: 'https://onlyu-live-default-rtdb.firebaseio.com',
    storageBucket: 'cheify.appspot.com',
    authDomain: 'cheify.firebaseapp.com',
    androidClientId:
        '249585646098-b815s5ntb6b3id373judh6h8d37ocb1d.apps.googleusercontent.com',
    iosClientId:
        '249585646098-b815s5ntb6b3id373judh6h8d37ocb1d.apps.googleusercontent.com',
    iosBundleId: 'org.cheify',
  );
}
