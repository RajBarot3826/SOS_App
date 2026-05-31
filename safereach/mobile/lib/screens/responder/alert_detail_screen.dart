/// Alert Detail Screen — Responder view of an incident
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/providers/profile_provider.dart';
import 'package:safereach/providers/sos_provider.dart';

class AlertDetailScreen extends ConsumerWidget {
  final String incidentId;
  const AlertDetailScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final incident = storage.getIncident(incidentId);

    if (incident == null) {
      return Scaffold(appBar: AppBar(title: const Text('Alert Detail')), body: const Center(child: Text('Incident not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Alert: ${incident.userName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 24, backgroundColor: SafeReachTheme.accentBlue.withValues(alpha: 0.1), child: Text(incident.userName[0], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: SafeReachTheme.accentBlue))),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(incident.userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            Text(incident.type.name.toUpperCase(), style: TextStyle(fontSize: 12, color: SafeReachTheme.sosRed, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ],
                    ),
                    if (incident.userDisabilities.isNotEmpty && incident.userDisabilities.first != 'none') ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: incident.userDisabilities.map((d) => Chip(
                          label: Text(d, style: const TextStyle(fontSize: 11)),
                          backgroundColor: SafeReachTheme.warningYellow.withValues(alpha: 0.2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Emergency message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emergency Message', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: SafeReachTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Text(incident.emergencyMessage, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: SafeReachTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Text(incident.location.badge, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('${incident.location.latitude.toStringAsFixed(6)}, ${incident.location.longitude.toStringAsFixed(6)}', style: TextStyle(fontSize: 12, color: SafeReachTheme.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Timeline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Timeline', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: SafeReachTheme.textSecondary)),
                    const SizedBox(height: 12),
                    ...incident.timeline.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(margin: const EdgeInsets.only(top: 4), width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: SafeReachTheme.accentBlue)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e.event, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          if (e.details != null) Text(e.details!, style: TextStyle(fontSize: 12, color: SafeReachTheme.textSecondary)),
                        ])),
                      ]),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Responder actions
            if (incident.isActive) ...[
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(sosProvider.notifier).resolveIncident(resolvedBy: 'Responder');
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark Resolved', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: SafeReachTheme.safeGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(sosProvider.notifier).markFalseAlert();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Mark False Alert'),
                  style: OutlinedButton.styleFrom(foregroundColor: SafeReachTheme.textSecondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
