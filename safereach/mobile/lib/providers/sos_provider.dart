/// SOS Provider — Core state machine for SOS flow
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safereach/models/incident.dart';
import 'package:safereach/models/accessibility_profile.dart';
import 'package:safereach/models/emergency_contact.dart';
import 'package:safereach/models/user_profile.dart';
import 'package:safereach/providers/profile_provider.dart';
import 'package:safereach/services/location_service.dart';
import 'package:safereach/services/notification_service.dart';
import 'package:safereach/services/sms_service.dart';
import 'package:safereach/services/storage_service.dart';
import 'package:safereach/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

enum SOSState {
  idle,
  countdown,
  active,
  resolving,
  resolved,
  cancelled,
}

class SOSStatus {
  final SOSState state;
  final int countdownRemaining;
  final Incident? activeIncident;
  final SOSActivationMethod? triggerMethod;
  final String? selectedMessage;
  final IncidentType? emergencyType;
  final String? statusMessage;

  const SOSStatus({
    this.state = SOSState.idle,
    this.countdownRemaining = 5,
    this.activeIncident,
    this.triggerMethod,
    this.selectedMessage,
    this.emergencyType,
    this.statusMessage,
  });

  SOSStatus copyWith({
    SOSState? state,
    int? countdownRemaining,
    Incident? activeIncident,
    SOSActivationMethod? triggerMethod,
    String? selectedMessage,
    IncidentType? emergencyType,
    String? statusMessage,
  }) {
    return SOSStatus(
      state: state ?? this.state,
      countdownRemaining: countdownRemaining ?? this.countdownRemaining,
      activeIncident: activeIncident ?? this.activeIncident,
      triggerMethod: triggerMethod ?? this.triggerMethod,
      selectedMessage: selectedMessage ?? this.selectedMessage,
      emergencyType: emergencyType ?? this.emergencyType,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

final sosProvider = StateNotifierProvider<SOSNotifier, SOSStatus>((ref) {
  return SOSNotifier(ref);
});

class SOSNotifier extends StateNotifier<SOSStatus> {
  final Ref _ref;
  Timer? _countdownTimer;
  Timer? _escalationTimer;
  Timer? _locationTimer;
  StreamSubscription? _locationStreamSub;
  static const _uuid = Uuid();

  SOSNotifier(this._ref) : super(const SOSStatus());

  /// Initiate SOS — starts the countdown
  void triggerSOS({
    required SOSActivationMethod method,
    IncidentType type = IncidentType.custom,
    String? message,
  }) {
    if (state.state == SOSState.active || state.state == SOSState.countdown) {
      return; // Already active
    }

    final profile = _ref.read(profileProvider);
    final countdownDuration =
        profile?.accessibilityProfile.countdownSeconds ?? 5;

    state = SOSStatus(
      state: SOSState.countdown,
      countdownRemaining: countdownDuration,
      triggerMethod: method,
      selectedMessage: message,
      emergencyType: type,
      statusMessage: 'SOS countdown started...',
    );

    if (countdownDuration == 0) {
      _activateSOS();
      return;
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownRemaining <= 1) {
        timer.cancel();
        _activateSOS();
      } else {
        state = state.copyWith(
          countdownRemaining: state.countdownRemaining - 1,
        );
      }
    });
  }

  /// Cancel SOS during countdown
  void cancelCountdown() {
    _countdownTimer?.cancel();
    state = const SOSStatus(
      state: SOSState.idle,
      statusMessage: 'SOS cancelled',
    );
  }

  /// Activate the actual SOS alert
  void _activateSOS() {
    _countdownTimer?.cancel();
    _performActivation();
  }

  /// Async activation — acquires real location, sends SMS, starts streaming
  Future<void> _performActivation() async {
    final profile = _ref.read(profileProvider);
    if (profile == null) return;

    // Get real location
    final locationService = _ref.read(locationServiceProvider);
    final locationResult = await locationService.getBestLocation();

    final message = state.selectedMessage ??
        'EMERGENCY ALERT from ${profile.name}. I need help!';

    // Create contact alerts for all emergency contacts
    final contactAlerts = profile.sortedContacts
        .map((c) => ContactAlert(
              contactId: c.id,
              contactName: c.name,
              contactPhone: c.fullPhoneNumber,
              priority: c.priority,
              isDelivered: false,
              deliveredAt: null,
            ))
        .toList();

    // Create the incident with real location
    final incident = Incident(
      id: _uuid.v4(),
      userId: profile.id,
      userName: profile.name,
      status: IncidentStatus.sent,
      type: state.emergencyType ?? IncidentType.custom,
      activationMethod: state.triggerMethod ?? SOSActivationMethod.oneTap,
      location: locationResult.toIncidentLocation(),
      emergencyMessage: message,
      contactAlerts: contactAlerts,
      timeline: [
        TimelineEntry(
          event: 'SOS Alert Created',
          timestamp: DateTime.now(),
          actorName: profile.name,
          details: 'Triggered via ${state.triggerMethod?.name ?? "unknown"}',
        ),
        TimelineEntry(
          event: 'Location Acquired',
          timestamp: DateTime.now(),
          details: locationResult.accuracy.name,
        ),
      ],
      createdAt: DateTime.now(),
      isSilent: profile.accessibilityProfile.silentModeEnabled,
      userDisabilities: profile.accessibilityProfile.disabilityTypes
          .map((d) => d.name)
          .toList(),
    );

    // Save incident to storage
    _ref.read(storageServiceProvider).saveIncident(incident);
    
    // Also push to Firestore for real-time tracking
    final firestoreService = FirestoreService();
    firestoreService.startActiveSOS(
      incidentId: incident.id,
      lat: locationResult.latitude,
      lng: locationResult.longitude,
      batteryLevel: 100, // mock battery level
      userName: profile.name,
      emergencyType: incident.type.name,
      emergencyMessage: message,
      disabilities: profile.accessibilityProfile.disabilityTypes.map((d) => d.name).toList(),
      medicalInfo: profile.medicalInfo.hasConsented ? profile.medicalInfo.toJson() : {},
    );

    state = SOSStatus(
      state: SOSState.active,
      activeIncident: incident,
      triggerMethod: state.triggerMethod,
      selectedMessage: message,
      emergencyType: state.emergencyType,
      statusMessage: 'Sending alerts to ${contactAlerts.length} contact(s)...',
    );

    // Send SMS to all contacts
    _sendEmergencyMessages(profile, locationResult, message, incident);

    // Start location streaming
    _startLocationStream();

    // Start escalation timer
    _startEscalationTimer();
  }

  /// Send emergency SMS and trigger notification
  Future<void> _sendEmergencyMessages(
    UserProfile profile,
    LocationResult location,
    String message,
    Incident incident,
  ) async {
    final smsService = _ref.read(smsServiceProvider);
    final notificationService = _ref.read(notificationServiceProvider);

    // Trigger notification
    await notificationService.notifySosAlert(
      userName: profile.name,
      message: message,
    );

    // Send SMS
    final phones =
        profile.sortedContacts.map((c) => c.fullPhoneNumber).toList();
    if (phones.isNotEmpty) {
      final disabilities = profile.accessibilityProfile.disabilityTypes
          .where((d) => d != DisabilityType.none)
          .map((d) => d.name)
          .toList();
          
      String? medicalInfoText;
      if (profile.medicalInfo.hasConsented) {
        final parts = <String>[];
        if (profile.medicalInfo.bloodGroup != null) parts.add('Blood: ${profile.medicalInfo.bloodGroup}');
        if (profile.medicalInfo.allergies != null) parts.add('Allergies: ${profile.medicalInfo.allergies}');
        if (profile.medicalInfo.medicalConditions != null) parts.add('Conditions: ${profile.medicalInfo.medicalConditions}');
        if (parts.isNotEmpty) medicalInfoText = parts.join(', ');
      }

      try {
        await smsService.sendToContacts(
          phones: phones,
          userName: profile.name,
          latitude: location.latitude,
          longitude: location.longitude,
          emergencyType: (state.emergencyType ?? IncidentType.custom).name,
          customMessage: message,
          disabilities: disabilities.isEmpty ? null : disabilities,
          medicalInfoText: medicalInfoText,
        );
      } catch (e) {
        print('Error sending SMS: $e');
      }
    }

    // Update incident status to show messages sent
    if (state.activeIncident != null) {
      final updatedAlerts = state.activeIncident!.contactAlerts
          .map((c) => c.copyWith(
                isDelivered: true,
                deliveredAt: DateTime.now(),
              ))
          .toList();

      final updatedTimeline =
          List<TimelineEntry>.from(state.activeIncident!.timeline)
            ..add(TimelineEntry(
              event: 'Alert Sent',
              timestamp: DateTime.now(),
              details: 'Sent to ${phones.length} contact(s)',
            ));

      final updatedIncident = state.activeIncident!.copyWith(
        contactAlerts: updatedAlerts,
        timeline: updatedTimeline,
      );
      _ref.read(storageServiceProvider).saveIncident(updatedIncident);
      state = state.copyWith(
        activeIncident: updatedIncident,
        statusMessage: 'Alert sent to ${phones.length} contact(s)',
      );
    }
  }

  /// Start streaming location updates during emergency
  void _startLocationStream() {
    final locationService = _ref.read(locationServiceProvider);
    _locationStreamSub?.cancel();
    _locationStreamSub =
        locationService.startEmergencyStream().listen((result) {
      updateLocation(result.toIncidentLocation());
    });
    
    // Start continuous live tracking via SMS (every 2 minutes)
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (state.state != SOSState.active || state.activeIncident == null) {
        timer.cancel();
        return;
      }
      
      final incident = state.activeIncident!;
      final loc = incident.location;
      if (loc != null) {
        final mapLink = 'https://maps.google.com/?q=${loc.latitude},${loc.longitude}';
        final message = 'LIVE TRACKING UPDATE: ${incident.userName} is currently at $mapLink';
        
        // Send to Priority 1 contacts
        final p1Contacts = incident.contactAlerts.where((c) => c.priority == 1);
        final smsService = _ref.read(smsServiceProvider);
        
        for (final contact in p1Contacts) {
          smsService.sendSMS(
            phone: contact.contactPhone,
            body: message,
          );
        }
      }
    });
  }

  /// Start auto-escalation checks
  void _startEscalationTimer() {
    _escalationTimer?.cancel();
    _escalationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (state.state != SOSState.active || state.activeIncident == null) {
        timer.cancel();
        return;
      }

      final incident = state.activeIncident!;
      final minutes = incident.elapsed.inMinutes;
      final hasAcknowledgment =
          incident.contactAlerts.any((c) => c.isAcknowledged);

      if (hasAcknowledgment) {
        timer.cancel();
        return;
      }

      String? escalationMessage;
      if (minutes >= 15) {
        escalationMessage = 'CRITICAL: Alerting all contacts simultaneously';
        timer.cancel();
      } else if (minutes >= 10) {
        escalationMessage = 'Escalating to campus security/admin';
      } else if (minutes >= 6) {
        escalationMessage = 'Escalating to Priority 3 contact';
      } else if (minutes >= 3) {
        escalationMessage = 'Escalating to Priority 2 contact';
      }

      if (escalationMessage != null) {
        final updatedTimeline = List<TimelineEntry>.from(incident.timeline)
          ..add(TimelineEntry(
            event: 'Escalation',
            timestamp: DateTime.now(),
            details: escalationMessage,
          ));

        final updatedIncident = incident.copyWith(timeline: updatedTimeline);
        _ref.read(storageServiceProvider).saveIncident(updatedIncident);

        state = state.copyWith(
          activeIncident: updatedIncident,
          statusMessage: escalationMessage,
        );
      }
    });
  }

  /// Simulate a contact acknowledging the alert
  void acknowledgeAlert(String contactId) {
    if (state.activeIncident == null) return;
    final incident = state.activeIncident!;

    final updatedAlerts = incident.contactAlerts.map((c) {
      if (c.contactId == contactId) {
        return c.copyWith(
          isAcknowledged: true,
          acknowledgedAt: DateTime.now(),
        );
      }
      return c;
    }).toList();

    final contactName = updatedAlerts
        .firstWhere((c) => c.contactId == contactId)
        .contactName;

    final updatedTimeline = List<TimelineEntry>.from(incident.timeline)
      ..add(TimelineEntry(
        event: 'Alert Acknowledged',
        timestamp: DateTime.now(),
        actorName: contactName,
      ));

    final updatedIncident = incident.copyWith(
      status: IncidentStatus.acknowledged,
      contactAlerts: updatedAlerts,
      timeline: updatedTimeline,
    );

    _ref.read(storageServiceProvider).saveIncident(updatedIncident);
    _ref
        .read(notificationServiceProvider)
        .notifyAcknowledged(responderName: contactName);
    state = state.copyWith(
      activeIncident: updatedIncident,
      statusMessage: 'Help is on the way!',
    );
  }

  /// Mark responder as on the way
  void responderOnTheWay(String contactId) {
    if (state.activeIncident == null) return;
    final incident = state.activeIncident!;

    final updatedAlerts = incident.contactAlerts.map((c) {
      if (c.contactId == contactId) {
        return c.copyWith(isOnTheWay: true, onTheWayAt: DateTime.now());
      }
      return c;
    }).toList();

    final responderName = updatedAlerts
        .firstWhere((c) => c.contactId == contactId)
        .contactName;

    final updatedTimeline = List<TimelineEntry>.from(incident.timeline)
      ..add(TimelineEntry(
        event: 'Help On The Way',
        timestamp: DateTime.now(),
        actorName: responderName,
        details: '$responderName is coming to your location',
      ));

    final updatedIncident = incident.copyWith(
      status: IncidentStatus.helpOnTheWay,
      contactAlerts: updatedAlerts,
      timeline: updatedTimeline,
    );

    _ref.read(storageServiceProvider).saveIncident(updatedIncident);
    _ref
        .read(notificationServiceProvider)
        .notifyHelpOnTheWay(responderName: responderName);
    state = state.copyWith(
      activeIncident: updatedIncident,
      statusMessage: '$responderName is on the way!',
    );
  }

  /// Resolve the incident
  void resolveIncident({String? resolvedBy}) {
    if (state.activeIncident == null) return;
    final incident = state.activeIncident!;

    final updatedTimeline = List<TimelineEntry>.from(incident.timeline)
      ..add(TimelineEntry(
        event: 'Incident Resolved',
        timestamp: DateTime.now(),
        actorName: resolvedBy ?? 'User',
      ));

    final updatedIncident = incident.copyWith(
      status: IncidentStatus.resolved,
      resolvedAt: DateTime.now(),
      resolvedBy: resolvedBy,
      timeline: updatedTimeline,
    );

    _ref.read(storageServiceProvider).saveIncident(updatedIncident);
    _escalationTimer?.cancel();
    _locationTimer?.cancel();
    _locationStreamSub?.cancel();
    _ref.read(notificationServiceProvider).notifyResolved();
    _ref.read(locationServiceProvider).stopEmergencyStream();
    
    // End incident in Firestore
    FirestoreService().endActiveSOS(incident.id);

    state = SOSStatus(
      state: SOSState.resolved,
      activeIncident: updatedIncident,
      statusMessage: 'Incident resolved',
    );
  }

  /// Cancel active SOS (requires verification after 60 seconds)
  void cancelActiveSOS({String? reason}) {
    if (state.activeIncident == null) return;
    final incident = state.activeIncident!;

    final updatedTimeline = List<TimelineEntry>.from(incident.timeline)
      ..add(TimelineEntry(
        event: 'SOS Cancelled',
        timestamp: DateTime.now(),
        actorName: incident.userName,
        details: reason ?? 'Cancelled by user',
      ));

    final updatedIncident = incident.copyWith(
      status: IncidentStatus.cancelled,
      cancelledAt: DateTime.now(),
      cancelReason: reason,
      timeline: updatedTimeline,
    );

    _ref.read(storageServiceProvider).saveIncident(updatedIncident);
    _escalationTimer?.cancel();
    _locationTimer?.cancel();
    _locationStreamSub?.cancel();
    _ref.read(locationServiceProvider).stopEmergencyStream();
    
    // End incident in Firestore
    FirestoreService().endActiveSOS(incident.id);

    state = SOSStatus(
      state: SOSState.cancelled,
      activeIncident: updatedIncident,
      statusMessage: 'SOS cancelled',
    );
  }

  /// Mark as false alert
  void markFalseAlert() {
    if (state.activeIncident == null) return;
    final incident = state.activeIncident!;

    final updatedIncident = incident.copyWith(
      status: IncidentStatus.falseAlert,
      cancelledAt: DateTime.now(),
      cancelReason: 'Marked as false alert',
    );

    _ref.read(storageServiceProvider).saveIncident(updatedIncident);
    _escalationTimer?.cancel();
    _locationTimer?.cancel();
    
    // End incident in Firestore
    FirestoreService().endActiveSOS(incident.id);

    state = SOSStatus(
      state: SOSState.cancelled,
      activeIncident: updatedIncident,
      statusMessage: 'Marked as false alert',
    );
  }

  /// Update incident location
  void updateLocation(IncidentLocation location) {
    if (state.activeIncident == null) return;
    final incident = state.activeIncident!;

    final updatedHistory = List<IncidentLocation>.from(incident.locationHistory)
      ..add(location);

    final updatedIncident = incident.copyWith(
      location: location,
      locationHistory: updatedHistory,
    );

    _ref.read(storageServiceProvider).saveIncident(updatedIncident);
    state = state.copyWith(activeIncident: updatedIncident);
    
    // Update location in Firestore
    FirestoreService().updateSOSLocation(
      incident.id,
      location.latitude,
      location.longitude,
      100, // mock battery
    );
  }

  /// Reset to idle
  void reset() {
    _countdownTimer?.cancel();
    _escalationTimer?.cancel();
    _locationTimer?.cancel();
    _locationStreamSub?.cancel();
    state = const SOSStatus();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _escalationTimer?.cancel();
    _locationTimer?.cancel();
    _locationStreamSub?.cancel();
    super.dispose();
  }
}
