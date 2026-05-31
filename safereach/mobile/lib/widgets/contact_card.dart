/// Contact Card Widget — Emergency contact with status indicators
library;

import 'package:flutter/material.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/emergency_contact.dart';

class ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final int priority;
  final bool isDelivered;
  final bool isAcknowledged;
  final bool isOnTheWay;
  final String? eta;
  final VoidCallback? onCall;
  final VoidCallback? onRemove;
  final bool showStatus;

  const ContactCard({
    super.key,
    required this.contact,
    required this.priority,
    this.isDelivered = false,
    this.isAcknowledged = false,
    this.isOnTheWay = false,
    this.eta,
    this.onCall,
    this.onRemove,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${contact.name}, priority ${priority + 1}, ${contact.relationship}${showStatus ? ', status: ${_statusLabel}' : ''}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOnTheWay
              ? const BorderSide(color: SafeReachTheme.safeGreen, width: 1.5)
              : isAcknowledged
                  ? const BorderSide(color: SafeReachTheme.accentBlue, width: 1)
                  : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Priority badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _priorityColor.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Text(
                    'P${priority + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: _priorityColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      '${contact.displayPhone} · ${contact.relationship}',
                      style: TextStyle(fontSize: 12, color: SafeReachTheme.textSecondary),
                    ),
                  ],
                ),
              ),

              // Status indicator (during emergency)
              if (showStatus) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor),
                      ),
                    ],
                  ),
                ),
              ],

              // Actions
              if (onCall != null)
                IconButton(
                  icon: const Icon(Icons.phone, color: SafeReachTheme.safeGreen),
                  onPressed: onCall,
                  tooltip: 'Call ${contact.name}',
                ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: SafeReachTheme.sosRed),
                  onPressed: onRemove,
                  tooltip: 'Remove ${contact.name}',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _priorityColor {
    switch (priority) {
      case 0: return SafeReachTheme.sosRed;
      case 1: return SafeReachTheme.warningOrange;
      default: return SafeReachTheme.accentBlue;
    }
  }

  String get _statusLabel {
    if (isOnTheWay) return eta != null ? 'ETA $eta' : 'On Way';
    if (isAcknowledged) return 'Ack\'d';
    if (isDelivered) return 'Sent';
    return 'Pending';
  }

  Color get _statusColor {
    if (isOnTheWay) return SafeReachTheme.safeGreen;
    if (isAcknowledged) return SafeReachTheme.accentBlue;
    if (isDelivered) return SafeReachTheme.warningOrange;
    return SafeReachTheme.textSecondary;
  }

  IconData get _statusIcon {
    if (isOnTheWay) return Icons.directions_run;
    if (isAcknowledged) return Icons.check;
    if (isDelivered) return Icons.send;
    return Icons.hourglass_empty;
  }
}
