import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Karena kita baru mengkonfigurasi untuk Web, kita akan menggunakan config web
    // sebagai fallback sementara untuk testing di platform lain.
    return web; 
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAWQldvxwDXf9V20S7AWznzap5B5PboHAA',
    appId: '1:81666640549:web:044d8ca1cff48f3f941b4c',
    messagingSenderId: '81666640549',
    projectId: 'lync-7cd15',
    authDomain: 'lync-7cd15.firebaseapp.com',
    storageBucket: 'lync-7cd15.firebasestorage.app',
    measurementId: 'G-Z0N9QQGD38',
  );
}
