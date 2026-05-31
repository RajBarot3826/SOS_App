/// Responder Home Screen — View and respond to incoming alerts
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/incident.dart';
import 'package:safereach/providers/profile_provider.dart';
import 'package:safereach/services/firestore_service.dart';
import 'package:safereach/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ResponderHomeScreen extends ConsumerStatefulWidget {
  const ResponderHomeScreen({super.key});

  @override
  ConsumerState<ResponderHomeScreen> createState() => _ResponderHomeScreenState();
}

class _ResponderHomeScreenState extends ConsumerState<ResponderHomeScreen> {
  int _lastAlertCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
          tooltip: 'Back to Home',
        ),
        title: const Text('Responder Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () => context.go(AppRoutes.profile), tooltip: 'Profile'),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().streamAllActiveIncidents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading live alerts'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeDocs = snapshot.data?.docs ?? [];
          
          // Trigger notification if a NEW alert arrived
          if (activeDocs.length > _lastAlertCount) {
             _lastAlertCount = activeDocs.length;
             // Delay to avoid build phase issues
             Future.microtask(() {
                ref.read(notificationServiceProvider).notifySosAlert(
                  userName: "Firebase Trigger",
                  message: "Live SOS Tracking Activated!"
                );
             });
          } else if (activeDocs.length < _lastAlertCount) {
             _lastAlertCount = activeDocs.length; // Handle resolved alerts
          }
          
          if (activeDocs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle_outline, size: 64, color: SafeReachTheme.safeGreen),
                const SizedBox(height: 16),
                const Text('No active alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('All clear!', style: TextStyle(color: SafeReachTheme.textSecondary)),
              ]),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('LIVE FIRESTORE ALERTS (${activeDocs.length})', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SafeReachTheme.sosRed, letterSpacing: 1)),
              const SizedBox(height: 8),
              ...activeDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildFirestoreAlertCard(context, doc.id, data);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFirestoreAlertCard(BuildContext context, String docId, Map<String, dynamic> data) {
    final phone = data['phoneNumber'] ?? 'Unknown User';
    final geo = data['currentLocation'] as GeoPoint?;
    final time = data['startTime'] as Timestamp?;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SafeReachTheme.sosRed, width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FirestoreLiveTrackingScreen(
              docId: docId,
              phone: phone,
            ),
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emergency, color: SafeReachTheme.sosRed, size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Text(phone, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                  _buildStatusBadge(IncidentStatus.sent),
                ],
              ),
              const SizedBox(height: 8),
              Text('Live SOS Triggered via Firebase!', style: TextStyle(color: SafeReachTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: SafeReachTheme.textSecondary),
                  const SizedBox(width: 4),
                  if (geo != null) Text('LIVE GPS (${geo.latitude.toStringAsFixed(4)}, ${geo.longitude.toStringAsFixed(4)})', style: TextStyle(fontSize: 11, color: SafeReachTheme.textSecondary)),
                  const Spacer(),
                  if (time != null) Text('${time.toDate().hour.toString().padLeft(2, '0')}:${time.toDate().minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11, color: SafeReachTheme.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(IncidentStatus status) {
    Color color;
    String label;
    switch (status) {
      case IncidentStatus.created: color = SafeReachTheme.statusCreated; label = 'Created';
      case IncidentStatus.sent: color = SafeReachTheme.statusSent; label = 'Sent';
      case IncidentStatus.delivered: color = SafeReachTheme.statusDelivered; label = 'Delivered';
      case IncidentStatus.acknowledged: color = SafeReachTheme.statusAcknowledged; label = 'Ack\'d';
      case IncidentStatus.responderAssigned: color = SafeReachTheme.statusAcknowledged; label = 'Assigned';
      case IncidentStatus.helpOnTheWay: color = SafeReachTheme.statusOnTheWay; label = 'On Way';
      case IncidentStatus.resolved: color = SafeReachTheme.statusResolved; label = 'Resolved';
      case IncidentStatus.cancelled: color = SafeReachTheme.statusCancelled; label = 'Cancelled';
      case IncidentStatus.falseAlert: color = SafeReachTheme.statusFalseAlert; label = 'False';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class FirestoreLiveTrackingScreen extends StatelessWidget {
  final String docId;
  final String phone;

  const FirestoreLiveTrackingScreen({super.key, required this.docId, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Tracking: $phone'), backgroundColor: SafeReachTheme.sosRed, foregroundColor: Colors.white),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirestoreService().streamIncident(docId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text('Incident ended.'));
          
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final geo = data['currentLocation'] as GeoPoint?;
          final battery = data['batteryLevel'] ?? 'Unknown';
          final userName = data['userName'] ?? 'Unknown User';
          final emergencyType = (data['emergencyType'] ?? 'MEDICAL EMERGENCY').toString().toUpperCase();
          final emergencyMessage = data['emergencyMessage'] ?? 'I need help!';
          final disabilities = (data['disabilities'] as List<dynamic>?)?.cast<String>() ?? [];
          final medicalInfo = data['medicalInfo'] as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(radius: 24, backgroundColor: Colors.redAccent, child: Icon(Icons.person, color: Colors.white)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                Text('$phone • $emergencyType', style: const TextStyle(fontSize: 12, color: SafeReachTheme.sosRed, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ],
                        ),
                        if (emergencyMessage.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('"$emergencyMessage"', style: const TextStyle(fontStyle: FontStyle.italic)),
                        ],
                        if (disabilities.isNotEmpty && disabilities.first != 'none') ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6, runSpacing: 6,
                            children: disabilities.map((d) => Chip(
                              label: Text(d, style: const TextStyle(fontSize: 11)),
                              backgroundColor: SafeReachTheme.warningYellow.withValues(alpha: 0.2),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                        ],
                        if (medicalInfo.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          if (medicalInfo['bloodGroup'] != null && medicalInfo['bloodGroup'].toString().isNotEmpty) Text('Blood Group: ${medicalInfo['bloodGroup']}', style: const TextStyle(fontSize: 14)),
                          if (medicalInfo['allergies'] != null && medicalInfo['allergies'].toString().isNotEmpty) Text('Allergies: ${medicalInfo['allergies']}', style: const TextStyle(fontSize: 14)),
                          if (medicalInfo['medicalConditions'] != null && medicalInfo['medicalConditions'].toString().isNotEmpty) Text('Conditions: ${medicalInfo['medicalConditions']}', style: const TextStyle(fontSize: 14)),
                        ],
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Device Battery: ', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('$battery%', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Live Map View
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.satellite_alt, color: SafeReachTheme.safeGreen),
                            SizedBox(width: 8),
                            Text('LIVE TRACKING ACTIVE', style: TextStyle(fontWeight: FontWeight.w700, color: SafeReachTheme.safeGreen)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () async {
                            if (geo != null) {
                              final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${geo.latitude},${geo.longitude}');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            }
                          },
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: SafeReachTheme.accentBlue, width: 2),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.map, size: 48, color: SafeReachTheme.accentBlue),
                                  const SizedBox(height: 8),
                                  if (geo != null) Text('${geo.latitude.toStringAsFixed(6)}, ${geo.longitude.toStringAsFixed(6)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(color: SafeReachTheme.accentBlue, borderRadius: BorderRadius.circular(20)),
                                    child: const Text('TAP TO OPEN GOOGLE MAPS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
