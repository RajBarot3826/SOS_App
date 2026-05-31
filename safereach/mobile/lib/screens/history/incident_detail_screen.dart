/// Incident Detail Screen — Historical incident view
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/providers/profile_provider.dart';

class IncidentDetailScreen extends ConsumerWidget {
  final String incidentId;
  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incident = ref.watch(storageServiceProvider).getIncident(incidentId);
    if (incident == null) return Scaffold(appBar: AppBar(title: const Text('Incident')), body: const Center(child: Text('Not found')));

    return Scaffold(
      appBar: AppBar(title: Text('Incident ${incidentId.substring(0, 8)}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Status: ${incident.status.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Type: ${incident.type.name}', style: TextStyle(color: SafeReachTheme.textSecondary)),
              Text('Method: ${incident.activationMethod.name}', style: TextStyle(color: SafeReachTheme.textSecondary)),
              Text('Created: ${incident.createdAt}', style: TextStyle(color: SafeReachTheme.textSecondary, fontSize: 12)),
              if (incident.resolvedAt != null) Text('Resolved: ${incident.resolvedAt}', style: TextStyle(color: SafeReachTheme.safeGreen, fontSize: 12)),
            ]))),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Message', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(incident.emergencyMessage),
            ]))),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Location', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(incident.location.badge),
              Text('${incident.location.latitude}, ${incident.location.longitude}', style: TextStyle(fontSize: 12, color: SafeReachTheme.textSecondary)),
            ]))),
            const SizedBox(height: 12),
            Text('Timeline', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...incident.timeline.map((e) => Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: SafeReachTheme.accentBlue)),
                title: Text(e.event, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text([if (e.actorName != null) e.actorName!, if (e.details != null) e.details!].join(' - '), style: TextStyle(fontSize: 12, color: SafeReachTheme.textSecondary)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
