/// Safe Locations Screen — Add safe locations (final onboarding step)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/safe_location.dart';
import 'package:safereach/providers/profile_provider.dart';

class SafeLocationsScreen extends ConsumerStatefulWidget {
  const SafeLocationsScreen({super.key});

  @override
  ConsumerState<SafeLocationsScreen> createState() => _SafeLocationsScreenState();
}

class _SafeLocationsScreenState extends ConsumerState<SafeLocationsScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController(text: '23.0225');
  final _lngController = TextEditingController(text: '72.5714');
  String _locationType = 'home';
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  final _locationTypes = [
    {'id': 'home', 'label': 'Home', 'icon': Icons.home},
    {'id': 'college', 'label': 'College', 'icon': Icons.school},
    {'id': 'hostel', 'label': 'Hostel', 'icon': Icons.apartment},
    {'id': 'classroom', 'label': 'Classroom', 'icon': Icons.class_},
    {'id': 'custom', 'label': 'Custom', 'icon': Icons.location_on},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final locations = profile?.safeLocations ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Locations'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRoutes.medicalInfo), tooltip: 'Go back'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                    _buildProgress(6, 6),
                    const SizedBox(height: 24),
                    Semantics(header: true, child: Text('Safe Locations', style: Theme.of(context).textTheme.headlineMedium)),
                    const SizedBox(height: 8),
                    Text('Add places you frequently visit for quick location selection during emergencies.', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),

                    // Saved locations
                    if (locations.isNotEmpty) ...[
                      ...locations.map((loc) {
                        IconData icon = Icons.location_on;
                        for (final t in _locationTypes) {
                          if (t['id'] == loc.type) {
                            icon = t['icon'] as IconData;
                            break;
                          }
                        }
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: SafeReachTheme.accentBlue.withValues(alpha: 0.1),
                              child: Icon(icon, color: SafeReachTheme.accentBlue, size: 22),
                            ),
                            title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(loc.address ?? '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}'),
                            trailing: Semantics(
                              label: 'Remove ${loc.name}',
                              button: true,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: SafeReachTheme.sosRed),
                                onPressed: () => ref.read(profileProvider.notifier).removeSafeLocation(loc.id),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],

                    // Add location form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Add Location', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),

                          // Type selector
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: _locationTypes.map((t) {
                              final isActive = _locationType == t['id'];
                              return Semantics(
                                label: '${t['label']} location type${isActive ? ", selected" : ""}',
                                button: true,
                                child: ChoiceChip(
                                  selected: isActive,
                                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(t['icon'] as IconData, size: 18, color: isActive ? Colors.white : SafeReachTheme.textSecondary),
                                    const SizedBox(width: 6),
                                    Text(t['label'] as String),
                                  ]),
                                  selectedColor: SafeReachTheme.accentBlue,
                                  onSelected: (_) => setState(() => _locationType = t['id'] as String),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Location Name', hintText: 'e.g. My Home, Main Campus', prefixIcon: Icon(Icons.edit_outlined)),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(labelText: 'Address (optional)', prefixIcon: Icon(Icons.location_city_outlined)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: TextFormField(controller: _latController, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                              const SizedBox(width: 12),
                              Expanded(child: TextFormField(controller: _lngController, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _addLocation,
                              icon: const Icon(Icons.add_location_alt),
                              label: const Text('Add Location'),
                              style: OutlinedButton.styleFrom(foregroundColor: SafeReachTheme.accentBlue, side: const BorderSide(color: SafeReachTheme.accentBlue), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Finish Setup button
                    SizedBox(
                      height: 56, width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _finishSetup,
                        style: ElevatedButton.styleFrom(backgroundColor: SafeReachTheme.safeGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 22), SizedBox(width: 8), Text('Finish Setup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _addLocation() {
    if (_formKey.currentState!.validate()) {
      final location = SafeLocation(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        type: _locationType,
        latitude: double.tryParse(_latController.text) ?? 23.0225,
        longitude: double.tryParse(_lngController.text) ?? 72.5714,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      );
      ref.read(profileProvider.notifier).addSafeLocation(location);
      _nameController.clear();
      _addressController.clear();
    }
  }

  void _finishSetup() {
    ref.read(profileProvider.notifier).completeOnboarding();
    context.go(AppRoutes.home);
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
