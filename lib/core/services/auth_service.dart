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
  static bool _googleSignInInitialized = false;

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
        // Native Android/iOS Google Sign In (in-app bottom sheet dialog)
        try {
          if (!_googleSignInInitialized) {
            await GoogleSignIn.instance.initialize(
              serverClientId: '814646172972-8jj81obfe51ts414vfj1vbdmlr9gaqe1.apps.googleusercontent.com',
            );
            _googleSignInInitialized = true;
          }

          final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();
          final String? idToken = account.authentication.idToken;

          if (idToken != null && idToken.isNotEmpty) {
            final AuthCredential credential = GoogleAuthProvider.credential(idToken: idToken);
            userCredential = await auth.signInWithCredential(credential);
          } else {
            // Fallback if idToken not returned
            final GoogleAuthProvider googleProvider = GoogleAuthProvider();
            googleProvider.addScope('email');
            googleProvider.addScope('profile');
            userCredential = await auth.signInWithProvider(googleProvider);
          }
        } catch (e) {
          debugPrint("In-app GoogleSignIn note: $e. Falling back to signInWithProvider...");
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
      if (!kIsWeb && _googleSignInInitialized) {
        await GoogleSignIn.instance.signOut();
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

