import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/config/firebase_config.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _user;
  AppUser? get user => _user;
  bool get isAuthenticated => _user != null && !_user!.isGuest;
  bool get isGuest => _user?.isGuest ?? true;
  bool get isFirebaseAvailable => FirebaseConfig.isInitialized;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSigningIn = false;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _user = _authService.currentUser;
  }

  Future<bool> signInWithGoogle() async {
    // Prevent multiple concurrent sign-in attempts (causes cancelled-popup-request)
    if (_isSigningIn) {
      debugPrint("Sign-in already in progress, ignoring duplicate call.");
      return false;
    }
    _isSigningIn = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _user = user;
        _isLoading = false;
        _isSigningIn = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Google Sign In Error: $e");
    }

    _isLoading = false;
    _isSigningIn = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _user = _authService.currentUser;
    _isLoading = false;
    notifyListeners();
  }
}

