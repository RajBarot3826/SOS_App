/// SafeReach — Inclusive AI-Enabled SOS & Assistive Safety Platform
/// Main entry point
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safereach/app.dart';
import 'package:safereach/services/storage_service.dart';
import 'package:safereach/providers/profile_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safereach/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase before background service
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  
  await initializeBackgroundService();

  // Lock to portrait mode for consistent SOS accessibility
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
  ));

  // Initialize storage
  final storageService = StorageService();
  await storageService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const SafeReachApp(),
    ),
  );
}
