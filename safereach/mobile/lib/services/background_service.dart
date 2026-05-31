import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

import 'package:safereach/config/constants.dart';
// Note: You would normally inject the real SMS/SOS trigger logic here,
// but for an isolated background service, we might need a simpler
// standalone implementation or initialize Hive/Riverpod inside the isolate.

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  if (await service.isRunning()) {
    return;
  }

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'safereach_foreground', // id
    'SafeReach Background Service', // name
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'safereach_foreground',
      initialNotificationTitle: 'SafeReach is active',
      initialNotificationContent: 'Monitoring for SOS triggers',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Background Shake Detection Logic
  final List<DateTime> _shakeTimestamps = [];
  double _threshold = AppConstants.shakeSensitivityMedium; // Default

  accelerometerEventStream(samplingPeriod: const Duration(milliseconds: 50)).listen((AccelerometerEvent event) {
    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    final userAcceleration = (magnitude - 9.8).abs();

    if (userAcceleration > _threshold) {
      final now = DateTime.now();
      _shakeTimestamps.removeWhere((t) => now.difference(t).inMilliseconds > AppConstants.shakeTimeWindowMs);
      _shakeTimestamps.add(now);

      if (_shakeTimestamps.length >= AppConstants.shakeCountThreshold) {
        _shakeTimestamps.clear();
        
        // TRIGGER SOS
        print("BACKGROUND SHAKE DETECTED! Triggering SOS...");
        // In a complete implementation, this would either use a local DB to find contacts
        // and send SMS using telephony directly from this isolate, or communicate with
        // the foreground if active.
        
        // Bring app to foreground (Android) or send notification
        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        flutterLocalNotificationsPlugin.show(
          id: 999,
          title: 'SOS Triggered!',
          body: 'Shake detected in background',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'safereach_foreground',
              'SafeReach Background Service',
              importance: Importance.high,
              priority: Priority.high,
              icon: 'ic_launcher',
            ),
          ),
        );
      }
    }
  });

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Periodic task to keep alive
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          id: 888,
          title: 'SafeReach is active',
          body: 'Monitoring for SOS triggers...',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'safereach_foreground',
              'SafeReach Background Service',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }
  });
}
