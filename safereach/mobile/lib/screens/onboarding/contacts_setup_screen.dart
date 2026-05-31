/// Contacts Setup Screen — Add emergency contacts (min 2)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:safereach/config/constants.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/emergency_contact.dart';
import 'package:safereach/providers/profile_provider.dart';

class ContactsSetupScreen extends ConsumerStatefulWidget {
  const ContactsSetupScreen({super.key});

  @override
  ConsumerState<ContactsSetupScreen> createState() => _ContactsSetupScreenState();
}

class _ContactsSetupScreenState extends ConsumerState<ContactsSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _relationship = 'Parent';
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final contacts = profile?.emergencyContacts ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRoutes.sosMethodSetup), tooltip: 'Go back'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                    _buildProgress(4, 6),
                    const SizedBox(height: 24),
                    Semantics(header: true, child: Text('Emergency Contacts', style: Theme.of(context).textTheme.headlineMedium)),
                    const SizedBox(height: 8),
                    Text('Add at least 2 contacts who will be alerted during an emergency.', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),

                    // Added contacts list
                    if (contacts.isNotEmpty) ...[
                      ...contacts.asMap().entries.map((entry) {
                        final i = entry.key;
                        final c = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: SafeReachTheme.accentBlue.withValues(alpha: 0.1),
                              child: Text('P${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700, color: SafeReachTheme.accentBlue)),
                            ),
                            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${c.displayPhone} · ${c.relationship}'),
                            trailing: Semantics(
                              label: 'Remove ${c.name}',
                              button: true,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: SafeReachTheme.sosRed),
                                onPressed: () => ref.read(profileProvider.notifier).removeEmergencyContact(c.id),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],

                    // Add contact form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Add Contact', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined), prefixText: '+91 '),
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Enter phone number';
                              if (v.trim().length < 10) return 'Enter valid phone number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _relationship,
                            decoration: const InputDecoration(labelText: 'Relationship', prefixIcon: Icon(Icons.people_outline)),
                            items: AppConstants.relationships.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                            onChanged: (v) => setState(() => _relationship = v ?? 'Parent'),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _addContact,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Contact'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: SafeReachTheme.accentBlue,
                                side: const BorderSide(color: SafeReachTheme.accentBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (contacts.length < 2) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SafeReachTheme.warningOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SafeReachTheme.warningOrange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: SafeReachTheme.warningOrange, size: 20),
                            const SizedBox(width: 8),
                            Text('Add at least ${2 - contacts.length} more contact(s)', style: const TextStyle(color: SafeReachTheme.warningOrange, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Continue button
                    SizedBox(
                      height: 56, width: double.infinity,
                      child: ElevatedButton(
                        onPressed: contacts.length >= 2 ? () => context.go(AppRoutes.medicalInfo) : null,
                        style: ElevatedButton.styleFrom(backgroundColor: SafeReachTheme.primaryBlue, foregroundColor: Colors.white, disabledBackgroundColor: SafeReachTheme.surfaceMedium, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded)]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _addContact() {
    if (_formKey.currentState!.validate()) {
      final profile = ref.read(profileProvider);
      final contact = EmergencyContact(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _relationship,
        priority: profile?.emergencyContacts.length ?? 0,
      );
      ref.read(profileProvider.notifier).addEmergencyContact(contact);
      _nameController.clear();
      _phoneController.clear();
      setState(() => _relationship = 'Parent');
      _formKey.currentState!.reset();
    }
  }

  Widget _buildProgress(int current, int total) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Step $current of $total', style: Theme.of(context).textTheme.bodySmall),
        Text('${((current / total) * 100).round()}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: current / total, minHeight: 6, backgroundColor: SafeReachTheme.surfaceMedium, valueColor: const AlwaysStoppedAnimation<Color>(SafeReachTheme.accentBlue))),
    ]);
  }
}
