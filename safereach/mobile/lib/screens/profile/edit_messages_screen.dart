/// Edit Messages Screen — Manage emergency messages
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/constants.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/providers/profile_provider.dart';

class EditMessagesScreen extends ConsumerStatefulWidget {
  const EditMessagesScreen({super.key});
  @override
  ConsumerState<EditMessagesScreen> createState() => _EditMessagesScreenState();
}

class _EditMessagesScreenState extends ConsumerState<EditMessagesScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final lang = profile?.preferredLanguage ?? 'en';
    final customMessages = profile?.customEmergencyMessages ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.profile),
          tooltip: 'Back to Profile',
        ),
        title: const Text('Emergency Messages'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Predefined Messages', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...AppConstants.predefinedMessages.map((m) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              leading: const Icon(Icons.message_outlined, color: SafeReachTheme.accentBlue, size: 20),
              title: Text(m[lang] ?? m['en']!, style: const TextStyle(fontSize: 14)),
            ),
          )),
          const SizedBox(height: 24),
          Text('Custom Messages (${customMessages.length}/10)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...customMessages.asMap().entries.map((e) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              leading: const Icon(Icons.edit_note, color: SafeReachTheme.safeGreen, size: 20),
              title: Text(e.value, style: const TextStyle(fontSize: 14)),
              trailing: IconButton(icon: const Icon(Icons.delete_outline, color: SafeReachTheme.sosRed, size: 20), onPressed: () => ref.read(profileProvider.notifier).removeCustomMessage(e.key)),
            ),
          )),
          const SizedBox(height: 12),
          if (customMessages.length < 10) ...[
            TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Add custom message', hintText: 'Type your emergency message...'), maxLines: 2),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () { if (_controller.text.trim().isNotEmpty) { ref.read(profileProvider.notifier).addCustomMessage(_controller.text.trim()); _controller.clear(); } },
              icon: const Icon(Icons.add), label: const Text('Add Message'),
            ),
          ],
        ],
      ),
    );
  }
}
