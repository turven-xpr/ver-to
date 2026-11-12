import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/firebase_config.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isGuest;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isGuest = false,
  });
}

class AuthService {
  FirebaseAuth? get _firebaseAuth {
    if (FirebaseConfig.isInitialized && Firebase.apps.isNotEmpty) {
      try {
        return FirebaseAuth.instance;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  AuthService() {
    final auth = _firebaseAuth;
    if (auth != null) {
      final user = auth.currentUser;
      if (user != null) {
        _currentUser = _fromFirebaseUser(user);
        return;
      }
    }
    _currentUser = AppUser(
      uid: 'guest_local_user',
      displayName: 'Offline Builder',
      email: 'local@builder.app',
      isGuest: true,
    );
  }

  AppUser _fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName ?? user.email?.split('@').first ?? 'Builder',
      photoUrl: user.photoURL,
      isGuest: false,
    );
  }

  Future<AppUser?> signInWithGoogle() async {
    final auth = _firebaseAuth;
    if (auth == null) {
      debugPrint("Firebase not configured. Running in Guest/Offline mode.");
      _currentUser = AppUser(
        uid: 'guest_local_user',
        displayName: 'Guest Builder',
        isGuest: true,
      );
      return _currentUser;
    }

    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await auth.signInWithPopup(googleProvider);
      } else {
        // Native Android/iOS Google Sign-In bottom sheet dialog
        try {
          final GoogleSignIn googleSignIn = GoogleSignIn(
            scopes: ['email', 'profile'],
            serverClientId: '814646172972-8jj81obfe51ts414vfj1vbdmlr9gaqe1.apps.googleusercontent.com',
          );

          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            // User cancelled the sign-in prompt
            return null;
          }

          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          userCredential = await auth.signInWithCredential(credential);
        } catch (e) {
          debugPrint("Native GoogleSignIn error: $e. Falling back to signInWithProvider...");
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          googleProvider.addScope('email');
          googleProvider.addScope('profile');
          userCredential = await auth.signInWithProvider(googleProvider);
        }
      }

      if (userCredential.user != null) {
        _currentUser = _fromFirebaseUser(userCredential.user!);
        return _currentUser;
      }
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      }
    } catch (_) {}

    final auth = _firebaseAuth;
    if (auth != null) {
      await auth.signOut();
    }
    _currentUser = AppUser(
      uid: 'guest_local_user',
      displayName: 'Offline Builder',
      email: 'local@builder.app',
      isGuest: true,
    );
  }
}

