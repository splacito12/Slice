import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signup(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("🔥 AUTH ERROR CODE: ${e.code}");
      log("🔥 AUTH ERROR MESSAGE: ${e.message}");
      return null;
    } catch (e) {
      log("UNKNOWN ERROR: $e");
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("AUTH ERROR CODE: ${e.code}");
      log("AUTH ERROR MESSAGE: ${e.message}");
      return null;
    } catch (e) {
      log("UNKNOWN ERROR: $e");
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Logout error: $e");
    }
  }
}
