/// Profile Screen — View and edit profile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    if (profile == null) return const Scaffold(body: Center(child: Text('No profile found')));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
          tooltip: 'Back to Home',
        ),
        title: const Text('My Profile'), 
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.go(AppRoutes.settings), tooltip: 'Settings'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Name
            CircleAvatar(radius: 40, backgroundColor: SafeReachTheme.accentBlue.withValues(alpha: 0.1), child: Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: SafeReachTheme.accentBlue))),
            const SizedBox(height: 12),
            Text(profile.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            Text('Role: ${profile.role.name.toUpperCase()}', style: TextStyle(color: SafeReachTheme.textSecondary)),
            const SizedBox(height: 24),

            _buildSection(context, 'Accessibility Profile', Icons.accessibility, [
              ...profile.accessibilityProfile.disabilityTypes.map((d) => d.name),
            ].join(', ')),

            _buildActionTile(context, 'Emergency Contacts', Icons.contacts, '${profile.emergencyContacts.length} contacts', () => context.go(AppRoutes.editContacts)),
            _buildActionTile(context, 'Emergency Messages', Icons.message, '${profile.customEmergencyMessages.length + 7} messages', () => context.go(AppRoutes.editMessages)),
            _buildActionTile(context, 'Safe Locations', Icons.location_on, '${profile.safeLocations.length} saved', () {}),
            _buildActionTile(context, 'Medical Info', Icons.medical_information, profile.medicalInfo.hasConsented ? 'Configured' : 'Not set', () {}),
            _buildActionTile(context, 'Incident History', Icons.history, '', () => context.go(AppRoutes.incidentHistory)),
            _buildActionTile(context, 'Responder Dashboard', Icons.admin_panel_settings, 'Live Tracking Demo', () => context.go(AppRoutes.responderHome)),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.settings),
                icon: const Icon(Icons.settings),
                label: const Text('Settings & Privacy'),
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: SafeReachTheme.accentBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: TextStyle(fontSize: 13, color: SafeReachTheme.textSecondary)),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: SafeReachTheme.accentBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(fontSize: 13, color: SafeReachTheme.textSecondary)) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
