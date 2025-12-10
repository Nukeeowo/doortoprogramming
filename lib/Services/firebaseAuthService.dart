import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> registerUser(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Register Error: $e"); 
      return null;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    print("--- ATTEMPTING LOGIN FOR: $email ---"); 
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("--- LOGIN SUCCESSFUL ---"); 
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("--- FIREBASE AUTH ERROR ---");
      print("Code: ${e.code}"); 
      print("Message: ${e.message}");
      return null;
    } catch (e) {
      print("--- GENERAL ERROR ---");
      print(e.toString());
      return null;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Reset Error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}