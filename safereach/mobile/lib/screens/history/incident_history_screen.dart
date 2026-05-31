/// Incident History Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/incident.dart';
import 'package:safereach/providers/profile_provider.dart';

class IncidentHistoryScreen extends ConsumerWidget {
  const IncidentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidents = ref.watch(storageServiceProvider).getAllIncidents();
    return Scaffold(
      appBar: AppBar(title: const Text('Incident History')),
      body: incidents.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.history, size: 56, color: SafeReachTheme.textLight),
              SizedBox(height: 12),
              Text('No incidents yet', style: TextStyle(fontSize: 16, color: SafeReachTheme.textSecondary)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final i = incidents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(i.isActive ? Icons.emergency : Icons.check_circle, color: i.isActive ? SafeReachTheme.sosRed : SafeReachTheme.safeGreen),
                    title: Text(i.emergencyMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${i.status.name} · ${i.createdAt.day}/${i.createdAt.month}/${i.createdAt.year} ${i.createdAt.hour.toString().padLeft(2, '0')}:${i.createdAt.minute.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('${AppRoutes.incidentDetail}?id=${i.id}'),
                  ),
                );
              },
            ),
    );
  }
}
