/// Incident Timeline Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/providers/profile_provider.dart';

class IncidentTimelineScreen extends ConsumerWidget {
  final String incidentId;
  const IncidentTimelineScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final incident = storage.getIncident(incidentId);

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Timeline')),
      body: incident == null
          ? const Center(child: Text('Incident not found'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: incident.timeline.length,
              itemBuilder: (context, index) {
                final entry = incident.timeline[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: SafeReachTheme.accentBlue)),
                        if (index < incident.timeline.length - 1) Container(width: 2, height: 40, color: SafeReachTheme.accentBlue.withValues(alpha: 0.3)),
                      ]),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.event, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                if (entry.actorName != null) ...[const SizedBox(height: 4), Text('By: ${entry.actorName}', style: Theme.of(context).textTheme.bodySmall)],
                                if (entry.details != null) ...[const SizedBox(height: 4), Text(entry.details!, style: Theme.of(context).textTheme.bodySmall)],
                                const SizedBox(height: 6),
                                Text('${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11, color: SafeReachTheme.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
