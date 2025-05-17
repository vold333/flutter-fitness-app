import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      return null;
    }
  }

  static Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      return null;
    }
  }
}
