import 'package:flutter/foundation.dart';
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
  final FirebaseAuth? _firebaseAuth =
      FirebaseConfig.isInitialized ? FirebaseAuth.instance : null;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  AuthService() {
    if (FirebaseConfig.isInitialized && _firebaseAuth != null) {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        _currentUser = _fromFirebaseUser(user);
      }
    } else {
      _currentUser = AppUser(
        uid: 'guest_local_user',
        displayName: 'Offline Builder',
        email: 'local@builder.app',
        isGuest: true,
      );
    }
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
    if (!FirebaseConfig.isInitialized || _firebaseAuth == null) {
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

      final UserCredential userCredential = kIsWeb
          ? await _firebaseAuth.signInWithPopup(googleProvider)
          : await _firebaseAuth.signInWithProvider(googleProvider);

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
    if (FirebaseConfig.isInitialized && _firebaseAuth != null) {
      await _firebaseAuth.signOut();
    }
    _currentUser = AppUser(
      uid: 'guest_local_user',
      displayName: 'Offline Builder',
      email: 'local@builder.app',
      isGuest: true,
    );
  }
}

