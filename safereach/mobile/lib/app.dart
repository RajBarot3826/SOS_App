/// SafeReach App Root Widget
/// Handles theming, localization, and routing
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/providers/accessibility_provider.dart';

class SafeReachApp extends ConsumerWidget {
  const SafeReachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final darkTheme = ref.watch(appDarkThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'SafeReach',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('gu'),
      ],
      routerConfig: appRouter,
      builder: (context, child) {
        // Apply global accessibility overrides
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(ref.watch(fontScaleProvider)),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
