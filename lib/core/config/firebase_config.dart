import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // Web defaults
  static const String _webApiKey = 'AIzaSyBp9HjrKXVX7Z7KrHLTViWzWTIzX5YkA24';
  static const String _webAppId = '1:814646172972:web:7658a11e95e725dec42089';

  // Android defaults (from google-services.json)
  static const String _androidApiKey = 'AIzaSyD7ZpmhkjF9NrMRFmdgytAuvkEGO5Pmw4o';
  static const String _androidAppId = '1:814646172972:android:1d5429ff8e6deb89c42089';

  static const String _defaultProjectId = 'todo-list-5042b';
  static const String _defaultSenderId = '814646172972';
  static const String _defaultAuthDomain = 'todo-list-5042b.firebaseapp.com';
  static const String _defaultStorageBucket = 'todo-list-5042b.firebasestorage.app';
  static const String _defaultMeasurementId = 'G-V1K9K5ZR9K';

  static bool _isValidCredential(String? val) {
    if (val == null || val.trim().isEmpty) return false;
    final lower = val.toLowerCase();
    return !lower.contains('your_') && !lower.contains('example') && !lower.contains('here');
  }

  static Future<void> initialize() async {
    // If Firebase is already initialized natively (e.g. by Google Services on Android)
    if (Firebase.apps.isNotEmpty) {
      _isInitialized = true;
      _configureFirestore();
      debugPrint("✅ Firebase was already initialized natively.");
      return;
    }

    // Try multiple possible paths for .env asset
    bool loaded = false;
    for (final fileName in [".env", "assets/.env", "assets/env"]) {
      try {
        await dotenv.load(fileName: fileName);
        loaded = true;
        break;
      } catch (_) {}
    }

    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    String apiKey = isAndroid ? _androidApiKey : _webApiKey;
    String appId = isAndroid ? _androidAppId : _webAppId;
    String projectId = _defaultProjectId;
    String messagingSenderId = _defaultSenderId;
    String? authDomain = isAndroid ? null : _defaultAuthDomain;
    String? storageBucket = _defaultStorageBucket;
    String? measurementId = isAndroid ? null : _defaultMeasurementId;

    if (loaded && dotenv.isInitialized) {
      if (isAndroid) {
        final envAndroidApiKey = dotenv.maybeGet('FIREBASE_ANDROID_API_KEY');
        if (_isValidCredential(envAndroidApiKey)) {
          apiKey = envAndroidApiKey!;
        }
        final envAndroidAppId = dotenv.maybeGet('FIREBASE_ANDROID_APP_ID');
        if (_isValidCredential(envAndroidAppId)) {
          appId = envAndroidAppId!;
        }
      } else {
        final envApiKey = dotenv.maybeGet('FIREBASE_API_KEY');
        if (_isValidCredential(envApiKey)) {
          apiKey = envApiKey!;
        }
        final envAppId = dotenv.maybeGet('FIREBASE_APP_ID');
        if (_isValidCredential(envAppId)) {
          appId = envAppId!;
        }
      }

      final envProjId = dotenv.maybeGet('FIREBASE_PROJECT_ID');
      if (_isValidCredential(envProjId)) projectId = envProjId!;

      final envSenderId = dotenv.maybeGet('FIREBASE_MESSAGING_SENDER_ID');
      if (_isValidCredential(envSenderId)) messagingSenderId = envSenderId!;

      final envAuthDomain = dotenv.maybeGet('FIREBASE_AUTH_DOMAIN');
      if (_isValidCredential(envAuthDomain)) authDomain = envAuthDomain;

      final envStorageBucket = dotenv.maybeGet('FIREBASE_STORAGE_BUCKET');
      if (_isValidCredential(envStorageBucket)) storageBucket = envStorageBucket;

      final envMeasId = dotenv.maybeGet('FIREBASE_MEASUREMENT_ID');
      if (_isValidCredential(envMeasId)) measurementId = envMeasId;
    }

    try {
      if (Firebase.apps.isEmpty) {
        if (kIsWeb) {
          await Firebase.initializeApp(
            options: FirebaseOptions(
              apiKey: apiKey,
              appId: appId,
              messagingSenderId: messagingSenderId,
              projectId: projectId,
              authDomain: authDomain,
              storageBucket: storageBucket,
              measurementId: (measurementId != null && measurementId.isNotEmpty) ? measurementId : null,
            ),
          );
        } else {
          await Firebase.initializeApp(
            options: FirebaseOptions(
              apiKey: apiKey,
              appId: appId,
              messagingSenderId: messagingSenderId,
              projectId: projectId,
              storageBucket: storageBucket,
            ),
          );
        }
      }

      _configureFirestore();
      _isInitialized = Firebase.apps.isNotEmpty;
      debugPrint("✅ Firebase initialized successfully with offline persistence for project $projectId.");
    } catch (e) {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        _configureFirestore();
        debugPrint("✅ Firebase default app available after: $e");
      } else {
        debugPrint("⚠️ Firebase initialization note: $e. Falling back to local offline-first mode.");
        _isInitialized = false;
      }
    }
  }

  static void _configureFirestore() {
    try {
      if (kIsWeb) {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
        );
      } else {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
    } catch (e) {
      debugPrint("Firestore settings note: $e");
    }
  }
}
