import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      // Save user info in Firestore with serverTimestamp
      try {
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await docRef.get();
        
        if (!doc.exists) {
          await docRef.set({
            'uid': user.uid,
            'displayName': user.displayName ?? 'Unknown User',
            'email': user.email,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'lastSeen': FieldValue.serverTimestamp(),
          });
        } else {
          await docRef.update({
            'lastSeen': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print("Firestore write failed: $e");
      }

      return user;
    } catch (e) {
      print("Google Sign-In failed: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      // Update lastSeen before signing out
      if (_auth.currentUser != null) {
        await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Sign out failed: $e");
    }
  }
}
