/// Location Badge Widget — Visual accuracy indicator
library;

import 'package:flutter/material.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/incident.dart';

class LocationBadge extends StatelessWidget {
  final LocationAccuracy accuracy;
  final double? accuracyMeters;
  final String? locationName;
  final bool compact;

  const LocationBadge({
    super.key,
    required this.accuracy,
    this.accuracyMeters,
    this.locationName,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (emoji, label, color) = _getAccuracyInfo();

    return Semantics(
      label: 'Location accuracy: $label${accuracyMeters != null ? ', ${accuracyMeters!.toInt()} meters' : ''}',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(compact ? 8 : 12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: compact ? 12 : 16)),
            SizedBox(width: compact ? 4 : 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                )),
                if (!compact && locationName != null)
                  Text(locationName!, style: TextStyle(
                    fontSize: 10,
                    color: SafeReachTheme.textSecondary,
                  )),
                if (!compact && accuracyMeters != null)
                  Text('±${accuracyMeters!.toInt()}m', style: TextStyle(
                    fontSize: 10,
                    color: SafeReachTheme.textSecondary,
                  )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (String emoji, String label, Color color) _getAccuracyInfo() {
    switch (accuracy) {
      case LocationAccuracy.liveGPS:
        return ('🟢', 'Live GPS', SafeReachTheme.safeGreen);
      case LocationAccuracy.lastKnown:
        return ('🟡', 'Last Known', SafeReachTheme.warningYellow);
      case LocationAccuracy.approximate:
        return ('🟠', 'Approximate', SafeReachTheme.warningOrange);
      case LocationAccuracy.qrCode:
        return ('🔵', 'QR Location', SafeReachTheme.accentBlue);
      case LocationAccuracy.manual:
      case LocationAccuracy.manuallySelected:
        return ('⚪', 'Manual', SafeReachTheme.textSecondary);
    }
  }
}
