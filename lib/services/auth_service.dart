import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseService _firebaseService = FirebaseService();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        final newUser = UserModel(
          email: email,
          username: name,
          imageUrl: '',
          isActive: true,
          isEmailVerified: false,
          createdAt: DateTime.now(),
          currency: 'INR',
        );
        await _firebaseService.updateUser(user.uid, newUser);
      }
      return result;
    } catch (e) {
      print('Error during Email Sign-Up: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error during Email Sign-In: $e');
      rethrow;
    }
  }

  // Sign in or Sign up with Google
  Future<UserCredential?> signInWithGoogle({bool isSignUp = false}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        final existingUser = await _firebaseService.getUser(user.uid);
        
        if (existingUser == null) {
          if (isSignUp) {
            // Register the new user
            final newUser = UserModel(
              email: user.email ?? '',
              username: user.displayName ?? '',
              imageUrl: user.photoURL ?? '',
              isActive: true,
              isEmailVerified: user.emailVerified,
              createdAt: DateTime.now(),
              currency: 'INR',
            );
            await _firebaseService.updateUser(user.uid, newUser);
          } else {
            // Not a sign-up request, and user doesn't exist
            await signOut();
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No account found for this Google account. Please sign up first.',
            );
          }
        }
      }
      return result;
    } catch (e) {
      print('Error during Google Auth: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
