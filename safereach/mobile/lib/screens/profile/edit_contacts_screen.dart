/// Edit Contacts Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/constants.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/emergency_contact.dart';
import 'package:safereach/providers/profile_provider.dart';

class EditContactsScreen extends ConsumerStatefulWidget {
  const EditContactsScreen({super.key});

  @override
  ConsumerState<EditContactsScreen> createState() => _EditContactsScreenState();
}

class _EditContactsScreenState extends ConsumerState<EditContactsScreen> {
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();
  String _rel = 'Parent';
  static const _uuid = Uuid();

  @override
  void dispose() { _nameC.dispose(); _phoneC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(profileProvider)?.emergencyContacts ?? [];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.profile),
          tooltip: 'Back to Profile',
        ),
        title: const Text('Emergency Contacts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...contacts.asMap().entries.map((e) {
            final c = e.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: SafeReachTheme.accentBlue.withValues(alpha: 0.1), child: Text('P${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.w700, color: SafeReachTheme.accentBlue))),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${c.displayPhone} · ${c.relationship}'),
                trailing: IconButton(icon: const Icon(Icons.delete_outline, color: SafeReachTheme.sosRed), onPressed: () => ref.read(profileProvider.notifier).removeEmergencyContact(c.id)),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text('Add Contact', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 12),
          TextField(controller: _phoneC, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined), prefixText: '+91 '), keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: _rel, decoration: const InputDecoration(labelText: 'Relationship'), items: AppConstants.relationships.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(), onChanged: (v) => setState(() => _rel = v ?? 'Parent')),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: () {
            if (_nameC.text.trim().isNotEmpty && _phoneC.text.trim().isNotEmpty) {
              ref.read(profileProvider.notifier).addEmergencyContact(EmergencyContact(id: _uuid.v4(), name: _nameC.text.trim(), phone: _phoneC.text.trim(), relationship: _rel, priority: contacts.length));
              _nameC.clear(); _phoneC.clear();
            }
          }, icon: const Icon(Icons.add), label: const Text('Add Contact')),
        ],
      ),
    );
  }
}
