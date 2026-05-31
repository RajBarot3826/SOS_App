/// Incident Card Widget — Compact incident summary for list views
library;

import 'package:flutter/material.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/incident.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onTap;
  final bool showAccessibility;

  const IncidentCard({
    super.key,
    required this.incident,
    this.onTap,
    this.showAccessibility = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Incident: ${incident.emergencyMessage}, status: ${incident.status.name}, by ${incident.userName}',
      button: onTap != null,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: incident.isActive
              ? const BorderSide(color: SafeReachTheme.sosRed, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: name + status badge
                Row(
                  children: [
                    Icon(
                      incident.isActive ? Icons.emergency : Icons.check_circle,
                      color: incident.isActive ? SafeReachTheme.sosRed : SafeReachTheme.safeGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        incident.userName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 8),

                // Message
                Text(
                  incident.emergencyMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: SafeReachTheme.textSecondary),
                ),
                const SizedBox(height: 8),

                // Meta row
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: SafeReachTheme.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      incident.location.badge,
                      style: TextStyle(fontSize: 11, color: SafeReachTheme.textSecondary),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 12, color: SafeReachTheme.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      _formatTime(incident.createdAt),
                      style: TextStyle(fontSize: 11, color: SafeReachTheme.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      incident.activationMethod.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: SafeReachTheme.textLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                // Accessibility needs
                if (showAccessibility &&
                    incident.userDisabilities.isNotEmpty &&
                    incident.userDisabilities.first != 'none') ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: incident.userDisabilities.map((d) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: SafeReachTheme.warningYellow.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: SafeReachTheme.warningYellow,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (label, color) = _statusInfo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  (String, Color) get _statusInfo {
    switch (incident.status) {
      case IncidentStatus.created: return ('Created', SafeReachTheme.statusCreated);
      case IncidentStatus.sent: return ('Sent', SafeReachTheme.statusSent);
      case IncidentStatus.delivered: return ('Delivered', SafeReachTheme.statusDelivered);
      case IncidentStatus.acknowledged: return ('Ack\'d', SafeReachTheme.statusAcknowledged);
      case IncidentStatus.responderAssigned: return ('Assigned', SafeReachTheme.statusAcknowledged);
      case IncidentStatus.helpOnTheWay: return ('On Way', SafeReachTheme.statusOnTheWay);
      case IncidentStatus.resolved: return ('Resolved', SafeReachTheme.statusResolved);
      case IncidentStatus.cancelled: return ('Cancelled', SafeReachTheme.statusCancelled);
      case IncidentStatus.falseAlert: return ('False', SafeReachTheme.statusFalseAlert);
    }
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
