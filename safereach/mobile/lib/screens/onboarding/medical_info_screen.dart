/// Medical Info Screen — Optional medical data with consent
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/constants.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/user_profile.dart';
import 'package:safereach/providers/profile_provider.dart';

class MedicalInfoScreen extends ConsumerStatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  ConsumerState<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends ConsumerState<MedicalInfoScreen> {
  bool _hasConsented = false;
  String? _bloodGroup;
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _doctorPhoneController = TextEditingController();

  @override
  void dispose() {
    _allergiesController.dispose();
    _conditionsController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Info'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRoutes.contactsSetup), tooltip: 'Go back'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                    _buildProgress(5, 6),
                    const SizedBox(height: 24),
                    Semantics(header: true, child: Text('Medical Information', style: Theme.of(context).textTheme.headlineMedium)),
                    const SizedBox(height: 8),
                    Text('Optional — shared only during emergencies with your contacts.', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),

                    // Consent toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _hasConsented ? SafeReachTheme.safeGreen.withValues(alpha: 0.08) : SafeReachTheme.surfaceMedium,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _hasConsented ? SafeReachTheme.safeGreen : Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('I consent to storing my medical information', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('Data is encrypted and shared only during emergencies', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Semantics(
                            label: 'Medical data consent${_hasConsented ? ", enabled" : ", disabled"}',
                            child: Switch(
                              value: _hasConsented,
                              onChanged: (v) => setState(() => _hasConsented = v),
                              activeColor: SafeReachTheme.safeGreen,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_hasConsented) ...[
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        value: _bloodGroup,
                        decoration: const InputDecoration(labelText: 'Blood Group', prefixIcon: Icon(Icons.bloodtype_outlined)),
                        items: AppConstants.bloodGroups.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (v) => setState(() => _bloodGroup = v),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _allergiesController,
                        decoration: const InputDecoration(labelText: 'Allergies', hintText: 'e.g. Penicillin, Peanuts', prefixIcon: Icon(Icons.warning_amber_outlined)),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _conditionsController,
                        decoration: const InputDecoration(labelText: 'Medical Conditions', hintText: 'e.g. Diabetes, Asthma', prefixIcon: Icon(Icons.medical_information_outlined)),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _doctorNameController,
                        decoration: const InputDecoration(labelText: 'Doctor Name', prefixIcon: Icon(Icons.person_outline)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _doctorPhoneController,
                        decoration: const InputDecoration(labelText: 'Doctor Phone', prefixIcon: Icon(Icons.phone_outlined), prefixText: '+91 '),
                        keyboardType: TextInputType.phone,
                      ),
                    ],

                    const SizedBox(height: 40),
                    
                    // Continue button
                    Column(
                      children: [
                        SizedBox(
                          height: 56, width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onContinue,
                            style: ElevatedButton.styleFrom(backgroundColor: SafeReachTheme.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded)]),
                          ),
                        ),
                        if (!_hasConsented) ...[
                          const SizedBox(height: 8),
                          TextButton(onPressed: () => context.go(AppRoutes.safeLocations), child: const Text('Skip this step')),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _onContinue() {
    if (_hasConsented) {
      ref.read(profileProvider.notifier).updateMedicalInfo(MedicalInfo(
        bloodGroup: _bloodGroup,
        allergies: _allergiesController.text.trim().isNotEmpty ? _allergiesController.text.trim() : null,
        medicalConditions: _conditionsController.text.trim().isNotEmpty ? _conditionsController.text.trim() : null,
        doctorName: _doctorNameController.text.trim().isNotEmpty ? _doctorNameController.text.trim() : null,
        doctorPhone: _doctorPhoneController.text.trim().isNotEmpty ? _doctorPhoneController.text.trim() : null,
        hasConsented: true,
      ));
    }
    context.go(AppRoutes.safeLocations);
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
