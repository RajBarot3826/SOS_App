/// SafeReach App Routing Configuration
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/screens/splash/splash_screen.dart';
import 'package:safereach/screens/onboarding/welcome_screen.dart';
import 'package:safereach/screens/onboarding/profile_setup_screen.dart';
import 'package:safereach/screens/onboarding/accessibility_setup_screen.dart';
import 'package:safereach/screens/onboarding/sos_method_setup_screen.dart';
import 'package:safereach/screens/onboarding/contacts_setup_screen.dart';
import 'package:safereach/screens/onboarding/medical_info_screen.dart';
import 'package:safereach/screens/onboarding/safe_locations_screen.dart';
import 'package:safereach/screens/home/home_screen.dart';
import 'package:safereach/screens/home/qr_scanner_screen.dart';
import 'package:safereach/screens/emergency/countdown_screen.dart';
import 'package:safereach/screens/emergency/active_emergency_screen.dart';
import 'package:safereach/screens/emergency/incident_timeline_screen.dart';
import 'package:safereach/screens/responder/responder_home_screen.dart';
import 'package:safereach/screens/responder/alert_detail_screen.dart';
import 'package:safereach/screens/profile/profile_screen.dart';
import 'package:safereach/screens/profile/edit_contacts_screen.dart';
import 'package:safereach/screens/profile/edit_messages_screen.dart';
import 'package:safereach/screens/profile/settings_screen.dart';
import 'package:safereach/screens/history/incident_history_screen.dart';
import 'package:safereach/screens/history/incident_detail_screen.dart';

import 'package:safereach/screens/auth/phone_login_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String welcome = '/welcome';
  static const String profileSetup = '/onboarding/profile';
  static const String accessibilitySetup = '/onboarding/accessibility';
  static const String sosMethodSetup = '/onboarding/sos-methods';
  static const String contactsSetup = '/onboarding/contacts';
  static const String medicalInfo = '/onboarding/medical';
  static const String safeLocations = '/onboarding/locations';
  static const String home = '/home';
  static const String qrScanner = '/home/qr-scanner';
  static const String countdown = '/emergency/countdown';
  static const String activeEmergency = '/emergency/active';
  static const String incidentTimeline = '/emergency/timeline';
  static const String responderHome = '/responder';
  static const String alertDetail = '/responder/alert';
  static const String profile = '/profile';
  static const String editContacts = '/profile/contacts';
  static const String editMessages = '/profile/messages';
  static const String settings = '/settings';
  static const String incidentHistory = '/history';
  static const String incidentDetail = '/history/detail';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const PhoneLoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.profileSetup,
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.accessibilitySetup,
      builder: (context, state) => const AccessibilitySetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.sosMethodSetup,
      builder: (context, state) => const SOSMethodSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.contactsSetup,
      builder: (context, state) => const ContactsSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.medicalInfo,
      builder: (context, state) => const MedicalInfoScreen(),
    ),
    GoRoute(
      path: AppRoutes.safeLocations,
      builder: (context, state) => const SafeLocationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.qrScanner,
      builder: (context, state) => const QRScannerScreen(),
    ),
    GoRoute(
      path: AppRoutes.countdown,
      builder: (context, state) => const CountdownScreen(),
    ),
    GoRoute(
      path: AppRoutes.activeEmergency,
      builder: (context, state) => const ActiveEmergencyScreen(),
    ),
    GoRoute(
      path: AppRoutes.incidentTimeline,
      builder: (context, state) {
        final incidentId = state.uri.queryParameters['id'] ?? '';
        return IncidentTimelineScreen(incidentId: incidentId);
      },
    ),
    GoRoute(
      path: AppRoutes.responderHome,
      builder: (context, state) => const ResponderHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.alertDetail,
      builder: (context, state) {
        final incidentId = state.uri.queryParameters['id'] ?? '';
        return AlertDetailScreen(incidentId: incidentId);
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.editContacts,
      builder: (context, state) => const EditContactsScreen(),
    ),
    GoRoute(
      path: AppRoutes.editMessages,
      builder: (context, state) => const EditMessagesScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.incidentHistory,
      builder: (context, state) => const IncidentHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.incidentDetail,
      builder: (context, state) {
        final incidentId = state.uri.queryParameters['id'] ?? '';
        return IncidentDetailScreen(incidentId: incidentId);
      },
    ),
  ],
);
