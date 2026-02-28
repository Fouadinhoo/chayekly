import 'package:firebase_core/firebase_core.dart';


class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyA7IauGKjepMXsEcG7kvptK5B9EGMVqBqk",
    appId: "1:1089212131211:web:f451c0dbf63a726225318e",
    messagingSenderId: "1089212131211",
    projectId: "chayekly",
    authDomain: "chayekly.firebaseapp.com",
    storageBucket: 'chayekly.appspot.com',
    measurementId: "G-JGXPXDB1XT"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA7IauGKjepMXsEcG7kvptK5B9EGMVqBqk',
    appId: "1:1089212131211:android:14136e18dd5978fa25318e",
    messagingSenderId: "1089212131211",
    projectId: "chayekly",
    storageBucket: 'chayekly.appspot.com',
  );
}