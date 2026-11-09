import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // Fallback defaults matching the project configuration
  static const String _defaultApiKey = 'AIzaSyBp9HjrKXVX7Z7KrHLTViWzWTIzX5YkA24';
  static const String _defaultAppId = '1:814646172972:web:7658a11e95e725dec42089';
  static const String _defaultProjectId = 'todo-list-5042b';
  static const String _defaultSenderId = '814646172972';
  static const String _defaultAuthDomain = 'todo-list-5042b.firebaseapp.com';
  static const String _defaultStorageBucket = 'todo-list-5042b.firebasestorage.app';
  static const String _defaultMeasurementId = 'G-V1K9K5ZR9K';

  static Future<void> initialize() async {
    // Try multiple possible paths for .env asset
    bool loaded = false;
    for (final fileName in [".env", "assets/.env", "assets/env"]) {
      try {
        await dotenv.load(fileName: fileName);
        loaded = true;
        break;
      } catch (_) {}
    }

    String apiKey = _defaultApiKey;
    String appId = _defaultAppId;
    String projectId = _defaultProjectId;
    String messagingSenderId = _defaultSenderId;
    String? authDomain = _defaultAuthDomain;
    String? storageBucket = _defaultStorageBucket;
    String? measurementId = _defaultMeasurementId;

    if (loaded && dotenv.isInitialized) {
      final envApiKey = dotenv.maybeGet('FIREBASE_API_KEY');
      if (envApiKey != null && envApiKey.isNotEmpty && !envApiKey.contains('your_firebase_api_key')) {
        apiKey = envApiKey;
      }
      final envAppId = dotenv.maybeGet('FIREBASE_APP_ID');
      if (envAppId != null && envAppId.isNotEmpty) appId = envAppId;

      final envProjId = dotenv.maybeGet('FIREBASE_PROJECT_ID');
      if (envProjId != null && envProjId.isNotEmpty) projectId = envProjId;

      final envSenderId = dotenv.maybeGet('FIREBASE_MESSAGING_SENDER_ID');
      if (envSenderId != null && envSenderId.isNotEmpty) messagingSenderId = envSenderId;

      final envAuthDomain = dotenv.maybeGet('FIREBASE_AUTH_DOMAIN');
      if (envAuthDomain != null && envAuthDomain.isNotEmpty) authDomain = envAuthDomain;

      final envStorageBucket = dotenv.maybeGet('FIREBASE_STORAGE_BUCKET');
      if (envStorageBucket != null && envStorageBucket.isNotEmpty) storageBucket = envStorageBucket;

      final envMeasId = dotenv.maybeGet('FIREBASE_MEASUREMENT_ID');
      if (envMeasId != null && envMeasId.isNotEmpty) measurementId = envMeasId;
    }

    final hasValidCredentials = apiKey.isNotEmpty &&
        appId.isNotEmpty &&
        projectId.isNotEmpty &&
        !apiKey.contains('your_firebase_api_key');

    if (!hasValidCredentials) {
      debugPrint("ℹ️ Firebase credentials not provided. Running in Offline-First Local Mode.");
      _isInitialized = false;
      return;
    }

    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          authDomain: authDomain,
          storageBucket: storageBucket,
          measurementId: measurementId.isNotEmpty ? measurementId : null,
        ),
      );

      // Enable offline persistence for Firestore
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

      _isInitialized = true;
      debugPrint("✅ Firebase initialized successfully with offline persistence for project $projectId.");
    } catch (e) {
      debugPrint("⚠️ Firebase initialization note: $e. Falling back to local offline-first mode.");
      _isInitialized = false;
    }
  }
}
