import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth? _injectedAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _injectedAuth = firebaseAuth;

  FirebaseAuth get _firebaseAuth => _injectedAuth ?? FirebaseAuth.instance;

  Stream<User?> get user {
    try {
      return _firebaseAuth.authStateChanges();
    } catch (e) {
      return Stream.value(null);
    }
  }

  Future<User?> signUp({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Sign out immediately to prevent auto-login
      await _firebaseAuth.signOut();
      return credential.user;
    } catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  Future<User?> signIn({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Akun tidak ditemukan.';
        case 'wrong-password':
          return 'Password salah.';
        case 'email-already-in-use':
          return 'Email sudah terdaftar.';
        case 'weak-password':
          return 'Password terlalu lemah.';
        default:
          return e.message ?? 'Terjadi kesalahan autentikasi.';
      }
    }
    return e.toString();
  }
}
