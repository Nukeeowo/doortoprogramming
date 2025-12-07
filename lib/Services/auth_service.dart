import 'package:firebase_auth/firebase_auth.dart';
import 'firestoreService.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Stream to listen to auth state changes (Logged in / Logged out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create the user document in Firestore immediately after registration
      if (result.user != null) {
        await _firestoreService.saveNewUserProfile(result.user!.uid, email);
      }
      
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign In
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Reset Password
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }
}