/// Notification Service — In-app notification system (simulating push notifications)
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum NotificationType { alert, acknowledgment, onTheWay, resolved, info, warning }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? incidentId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.incidentId,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        incidentId: incidentId,
      );
}

class NotificationService {
  final FlutterTts _tts = FlutterTts();
  final List<AppNotification> _notifications = [];
  final _controller = StreamController<AppNotification>.broadcast();
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _voiceEnabled = false;

  Stream<AppNotification> get notificationStream => _controller.stream;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Initialize TTS
  Future<void> initialize() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
  }

  /// Configure feedback modes
  void configure({bool? sound, bool? vibration, bool? voice}) {
    if (sound != null) _soundEnabled = sound;
    if (vibration != null) _vibrationEnabled = vibration;
    if (voice != null) _voiceEnabled = voice;
  }

  /// Show a notification
  Future<void> show({
    required String title,
    required String body,
    required NotificationType type,
    String? incidentId,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      incidentId: incidentId,
    );

    _notifications.insert(0, notification);
    _controller.add(notification);

    // Feedback based on type and user preferences
    await _provideFeedback(type, title);
  }

  Future<void> _provideFeedback(NotificationType type, String title) async {
    try {
      // Vibration patterns based on notification type
      if (_vibrationEnabled) {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          switch (type) {
            case NotificationType.alert:
              Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500], intensities: [0, 255, 0, 255, 0, 255]);
            case NotificationType.acknowledgment:
              Vibration.vibrate(duration: 200);
            case NotificationType.onTheWay:
              Vibration.vibrate(pattern: [0, 300, 100, 300]);
            case NotificationType.resolved:
              Vibration.vibrate(duration: 100);
            default:
              Vibration.vibrate(duration: 150);
          }
        }
      }

      // Voice announcement
      if (_voiceEnabled) {
        await _tts.speak(title);
      }
    } catch (e) {
      debugPrint('Feedback error: $e');
    }
  }

  /// Mark notification as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  /// Mark all as read
  void markAllRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
  }

  /// Send SOS alert notification
  Future<void> notifySosAlert({required String userName, required String message}) async {
    await show(
      title: '🚨 SOS Alert from $userName',
      body: message,
      type: NotificationType.alert,
    );
  }

  /// Send acknowledgment notification
  Future<void> notifyAcknowledged({required String responderName}) async {
    await show(
      title: '✓ $responderName acknowledged your alert',
      body: 'Your emergency contact has seen your alert.',
      type: NotificationType.acknowledgment,
    );
  }

  /// Send help on the way notification
  Future<void> notifyHelpOnTheWay({required String responderName, String? eta}) async {
    await show(
      title: '🏃 $responderName is on the way',
      body: eta != null ? 'Estimated arrival: $eta' : 'Help is coming to your location.',
      type: NotificationType.onTheWay,
    );
  }

  /// Send resolved notification
  Future<void> notifyResolved() async {
    await show(
      title: '✅ Emergency Resolved',
      body: 'Your emergency has been marked as resolved.',
      type: NotificationType.resolved,
    );
  }

  void dispose() {
    _controller.close();
    _tts.stop();
  }
}

// Riverpod providers
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(() => service.dispose());
  return service;
});

final notificationStreamProvider = StreamProvider<AppNotification>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.notificationStream;
});

final unreadCountProvider = Provider<int>((ref) {
  ref.watch(notificationStreamProvider);
  return ref.read(notificationServiceProvider).unreadCount;
});
