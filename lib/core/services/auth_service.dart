import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      UserCredential userCredential;
      try {
        userCredential = kIsWeb
            ? await auth.signInWithPopup(googleProvider)
            : await auth.signInWithProvider(googleProvider);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'cancelled-popup-request' ||
            e.code == 'popup-closed-by-user') {
          debugPrint(
              "Popup cancelled/closed (${e.code}). Retrying once after delay...");
          // Small delay then retry once
          await Future.delayed(const Duration(milliseconds: 500));
          userCredential = kIsWeb
              ? await auth.signInWithPopup(googleProvider)
              : await auth.signInWithProvider(googleProvider);
        } else {
          rethrow;
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

