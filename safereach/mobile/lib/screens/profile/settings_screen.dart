/// Settings Screen — Full app configuration and privacy controls
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/constants.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/accessibility_profile.dart';
import 'package:safereach/providers/profile_provider.dart';
import 'package:safereach/providers/accessibility_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final ap = ref.watch(accessibilityProfileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.profile),
          tooltip: 'Back to Profile',
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── SOS Configuration ─────────────────────────────
          _sectionCard(
            context,
            title: 'SOS Configuration',
            icon: Icons.sos,
            children: [
              _switchTile(
                'Shake to SOS',
                Icons.vibration,
                ap.isShakeSOSEnabled,
                (value) {
                  final p = ref.read(profileProvider);
                  if (p == null) return;
                  final methods = List<SOSActivationMethod>.from(ap.enabledSOSMethods);
                  if (value) {
                    if (!methods.contains(SOSActivationMethod.shake)) {
                      methods.add(SOSActivationMethod.shake);
                    }
                  } else {
                    methods.remove(SOSActivationMethod.shake);
                  }
                  final updated = ap.copyWith(enabledSOSMethods: methods);
                  ref.read(profileProvider.notifier).updateAccessibilityProfile(updated);
                },
              ),
              _switchTile(
                'Voice SOS',
                Icons.mic,
                ap.isVoiceSOSEnabled,
                (value) {
                  final p = ref.read(profileProvider);
                  if (p == null) return;
                  final methods = List<SOSActivationMethod>.from(ap.enabledSOSMethods);
                  if (value) {
                    if (!methods.contains(SOSActivationMethod.voice)) {
                      methods.add(SOSActivationMethod.voice);
                    }
                  } else {
                    methods.remove(SOSActivationMethod.voice);
                  }
                  final updated = ap.copyWith(enabledSOSMethods: methods);
                  ref.read(profileProvider.notifier).updateAccessibilityProfile(updated);
                },
              ),
              _switchTile(
                'Silent SOS Mode',
                Icons.volume_off,
                ap.silentModeEnabled,
                (value) {
                  final p = ref.read(profileProvider);
                  if (p == null) return;
                  final updated = ap.copyWith(silentModeEnabled: value);
                  ref.read(profileProvider.notifier).updateAccessibilityProfile(updated);
                },
              ),
              Semantics(
                label: 'Countdown Duration: ${ap.countdownSeconds} seconds',
                child: ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Countdown Duration'),
                  subtitle: Slider(
                    value: ap.countdownSeconds.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: '${ap.countdownSeconds}s',
                    activeColor: SafeReachTheme.accentBlue,
                    onChanged: (v) {
                      final p = ref.read(profileProvider);
                      if (p == null) return;
                      final updated = ap.copyWith(countdownSeconds: v.round());
                      ref.read(profileProvider.notifier).updateAccessibilityProfile(updated);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Accessibility ─────────────────────────────────
          _sectionCard(
            context,
            title: 'Accessibility',
            icon: Icons.accessibility_new,
            children: [
              _switchTile(
                'High Contrast Mode',
                Icons.contrast,
                ap.highContrastEnabled,
                (value) {
                  final p = ref.read(profileProvider);
                  if (p == null) return;
                  final updated = ap.copyWith(highContrastEnabled: value);
                  ref.read(profileProvider.notifier).updateAccessibilityProfile(updated);
                },
              ),
              _switchTile(
                'Voice Guidance',
                Icons.record_voice_over,
                ap.voiceGuidanceEnabled,
                (value) {
                  final p = ref.read(profileProvider);
                  if (p == null) return;
                  final updated = ap.copyWith(voiceGuidanceEnabled: value);
                  ref.read(profileProvider.notifier).updateAccessibilityProfile(updated);
                },
              ),
              _switchTile(
                'Pictogram Mode',
                Icons.image,
                ap.pictogramModeEnabled,
                (value) {
                  final p = ref.read(profileProvider);
                  if (p == null) return;
                  final updated = ap.copyWith(pictogramModeEnabled: value);
                  ref.read(profileProvider.notifier).updateAccessibilityProfile(updated);
                },
              ),
              _switchTile(
                'Simplified UI',
                Icons.dashboard_customize,
                ap.simplifiedUIEnabled,
                (value) {
                  final p = ref.read(profileProvider);
                  if (p == null) return;
                  final updated = ap.copyWith(simplifiedUIEnabled: value);
                  ref.read(profileProvider.notifier).updateAccessibilityProfile(updated);
                },
              ),
              Semantics(
                label: 'Font Scale: ${(ap.fontScale * 100).round()} percent',
                child: ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Font Scale'),
                  subtitle: Slider(
                    value: ap.fontScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: '${(ap.fontScale * 100).round()}%',
                    activeColor: SafeReachTheme.accentBlue,
                    onChanged: (v) {
                      final p = ref.read(profileProvider);
                      if (p == null) return;
                      final updated = ap.copyWith(fontScale: double.parse(v.toStringAsFixed(2)));
                      ref.read(profileProvider.notifier).updateAccessibilityProfile(updated);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Language ──────────────────────────────────────
          _sectionCard(
            context,
            title: 'Language',
            icon: Icons.language,
            children: [
              ...AppConstants.supportedLanguages.map((lang) => RadioListTile<String>(
                title: Text('${lang['nativeName']} (${lang['name']})'),
                value: lang['code']!,
                groupValue: profile?.preferredLanguage ?? 'en',
                onChanged: (v) { if (v != null) ref.read(profileProvider.notifier).updateLanguage(v); },
              )),
            ],
          ),
          const SizedBox(height: 12),

          // ── Privacy & Data ────────────────────────────────
          _sectionCard(
            context,
            title: 'Privacy & Data',
            icon: Icons.shield_outlined,
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: SafeReachTheme.accentBlue),
                title: const Text('Data Policy'),
                subtitle: const Text('Location shared only during active emergencies. All data encrypted locally.'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined, color: SafeReachTheme.warningOrange),
                title: const Text('Delete All Incidents'),
                onTap: () => _confirmAction(context, 'Delete all incident history?', () {
                  ref.read(storageServiceProvider).deleteAllIncidents();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All incidents deleted')));
                }),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: SafeReachTheme.sosRed),
                title: const Text('Delete All Data & Account', style: TextStyle(color: SafeReachTheme.sosRed)),
                onTap: () => _confirmAction(context, 'Delete ALL data? This cannot be undone.', () {
                  ref.read(profileProvider.notifier).deleteAllData();
                  context.go(AppRoutes.welcome);
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── About ─────────────────────────────────────────
          _sectionCard(
            context,
            title: 'About',
            icon: Icons.info_outline,
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('SafeReach v1.0.0'),
                subtitle: Text('Inclusive AI-Enabled SOS Platform'),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Wraps a settings section inside a styled Card with a header row.
  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SafeReachTheme.accentBlue.withValues(alpha: 0.08),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: SafeReachTheme.accentBlue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SafeReachTheme.accentBlue,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// Material 3 styled switch tile with proper track colors.
  Widget _switchTile(String title, IconData icon, bool value, ValueChanged<bool>? onChanged) {
    return Semantics(
      label: '$title: ${value ? 'enabled' : 'disabled'}',
      toggled: value,
      child: SwitchListTile(
        secondary: Icon(icon),
        title: Text(title),
        value: value,
        onChanged: onChanged ?? (_) {},
        activeColor: SafeReachTheme.accentBlue,
        activeTrackColor: SafeReachTheme.accentBlue.withValues(alpha: 0.4),
        inactiveThumbColor: SafeReachTheme.textLight,
        inactiveTrackColor: SafeReachTheme.surfaceMedium,
      ),
    );
  }

  void _confirmAction(BuildContext context, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: SafeReachTheme.sosRed, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
