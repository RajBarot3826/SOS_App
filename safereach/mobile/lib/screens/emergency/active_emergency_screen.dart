/// Active Emergency Screen — Live SOS dashboard with contact status, timeline, call, and resolve
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/incident.dart';
import 'package:safereach/models/user_profile.dart';
import 'package:safereach/providers/profile_provider.dart';
import 'package:safereach/providers/sos_provider.dart';
import 'package:safereach/services/sms_service.dart';

class ActiveEmergencyScreen extends ConsumerStatefulWidget {
  const ActiveEmergencyScreen({super.key});

  @override
  ConsumerState<ActiveEmergencyScreen> createState() => _ActiveEmergencyScreenState();
}

class _ActiveEmergencyScreenState extends ConsumerState<ActiveEmergencyScreen>
    with TickerProviderStateMixin {
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;
  late AnimationController _headerPulse;
  late Animation<double> _headerPulseAnim;

  @override
  void initState() {
    super.initState();
    _headerPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _headerPulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _headerPulse, curve: Curves.easeInOut),
    );
    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final incident = ref.read(sosProvider).activeIncident;
      if (incident != null && mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(incident.createdAt);
        });
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _headerPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sosStatus = ref.watch(sosProvider);
    final incident = sosStatus.activeIncident;

    if (sosStatus.state == SOSState.idle || sosStatus.state == SOSState.cancelled || sosStatus.state == SOSState.resolved) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.home));
      return const SizedBox.shrink();
    }

    if (incident == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _elapsed = DateTime.now().difference(incident.createdAt);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: SafeArea(
          child: Column(
            children: [
              // Emergency header with pulse animation
              _buildHeader(incident),

              // Status message
              if (sosStatus.statusMessage != null)
                _buildStatusBanner(sosStatus.statusMessage!),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emergency contacts
                      _buildSectionTitle('Emergency Contacts', Icons.people),
                      const SizedBox(height: 8),
                      ...incident.contactAlerts.map((alert) => _buildContactCard(alert)),

                      const SizedBox(height: 20),

                      // Timeline
                      _buildSectionTitle('Timeline', Icons.timeline),
                      const SizedBox(height: 8),
                      ...incident.timeline.reversed.map((entry) => _buildTimelineEntry(entry)),

                      const SizedBox(height: 16),

                      // Emergency message
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.message, size: 16, color: SafeReachTheme.accentBlue.withValues(alpha: 0.7)),
                                const SizedBox(width: 6),
                                Text('Message Sent', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              incident.emergencyMessage,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80), // Space for bottom bar
                    ],
                  ),
                ),
              ),

              // Bottom action bar
              _buildBottomBar(incident),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Incident incident) {
    return AnimatedBuilder(
      animation: _headerPulseAnim,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SafeReachTheme.sosRed.withValues(alpha: 0.8 + (0.2 * _headerPulseAnim.value)),
                SafeReachTheme.sosRedDark,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: SafeReachTheme.sosRed.withValues(alpha: 0.3 * _headerPulseAnim.value),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.emergency, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          liveRegion: true,
                          child: const Text(
                            'EMERGENCY ACTIVE',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Elapsed: ${_formatDuration(_elapsed)}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  // Call 112 button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(smsServiceProvider).callEmergency('112');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.call, color: SafeReachTheme.sosRed, size: 18),
                              const SizedBox(width: 4),
                              Text('112', style: TextStyle(color: SafeReachTheme.sosRed, fontWeight: FontWeight.w800, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Location badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        incident.location.badge,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: SafeReachTheme.safeGreen.withValues(alpha: 0.12),
      child: Semantics(
        liveRegion: true,
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: SafeReachTheme.safeGreen, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: SafeReachTheme.safeGreen, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: SafeReachTheme.accentBlue),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildContactCard(ContactAlert alert) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (alert.isOnTheWay) {
      statusColor = SafeReachTheme.safeGreen;
      statusText = 'On the way';
      statusIcon = Icons.directions_run;
    } else if (alert.isAcknowledged) {
      statusColor = SafeReachTheme.accentBlue;
      statusText = 'Acknowledged';
      statusIcon = Icons.check_circle;
    } else if (alert.isDelivered) {
      statusColor = SafeReachTheme.warningOrange;
      statusText = 'Delivered, waiting...';
      statusIcon = Icons.hourglass_top;
    } else {
      statusColor = SafeReachTheme.textSecondary;
      statusText = 'Sending...';
      statusIcon = Icons.send;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: statusColor, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.12),
              radius: 20,
              child: Text(
                'P${alert.priority + 1}',
                style: TextStyle(fontWeight: FontWeight.w700, color: statusColor, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.contactName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            // Call contact button
            Container(
              decoration: BoxDecoration(
                color: SafeReachTheme.safeGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.call, color: SafeReachTheme.safeGreen, size: 20),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(smsServiceProvider).callEmergency(alert.contactPhone);
                },
                tooltip: 'Call ${alert.contactName}',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: const EdgeInsets.all(8),
              ),
            ),
            // Demo actions for non-acknowledged contacts
            if (alert.isAcknowledged && !alert.isOnTheWay) ...[
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: SafeReachTheme.accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.directions_run, color: SafeReachTheme.accentBlue, size: 20),
                  onPressed: () => ref.read(sosProvider.notifier).responderOnTheWay(alert.contactId),
                  tooltip: '${alert.contactName} on the way',
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineEntry(TimelineEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SafeReachTheme.accentBlue,
                  boxShadow: [
                    BoxShadow(color: SafeReachTheme.accentBlue.withValues(alpha: 0.4), blurRadius: 6),
                  ],
                ),
              ),
              Container(width: 2, height: 28, color: SafeReachTheme.accentBlue.withValues(alpha: 0.2)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.event, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                if (entry.actorName != null)
                  Text(entry.actorName!, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                if (entry.details != null)
                  Text(entry.details!, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
                Text(_formatTime(entry.timestamp), style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Incident incident) {
    final profile = ref.watch(profileProvider);
    final bool isAdminOrResponder = profile?.role == UserRole.admin || profile?.role == UserRole.responder;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(
        children: [
          // Cancel SOS
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => _showCancelDialog(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: SafeReachTheme.warningOrange,
                  side: const BorderSide(color: SafeReachTheme.warningOrange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ),
          if (isAdminOrResponder) ...[
            const SizedBox(width: 10),
            // Simulate Acknowledge (for demo)
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (incident.contactAlerts.isNotEmpty) {
                      final unacknowledged = incident.contactAlerts.where((c) => !c.isAcknowledged).toList();
                      if (unacknowledged.isNotEmpty) {
                        ref.read(sosProvider.notifier).acknowledgeAlert(unacknowledged.first.contactId);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: SafeReachTheme.accentBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ack', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Mark Safe / Resolve
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(sosProvider.notifier).resolveIncident(resolvedBy: 'User');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: SafeReachTheme.safeGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Safe', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2333),
        title: const Text('Cancel SOS?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to cancel the active emergency alert? This will notify your contacts.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Active'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(sosProvider.notifier).cancelActiveSOS(reason: 'Cancelled by user');
            },
            style: ElevatedButton.styleFrom(backgroundColor: SafeReachTheme.sosRed, foregroundColor: Colors.white),
            child: const Text('Cancel SOS'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m}m ${s}s';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
