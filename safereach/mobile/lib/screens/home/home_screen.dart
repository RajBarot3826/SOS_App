/// Home Screen — Main SOS screen with giant emergency button
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/constants.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/accessibility_profile.dart';
import 'package:safereach/models/incident.dart';
import 'package:safereach/models/user_profile.dart';
import 'package:safereach/providers/profile_provider.dart';
import 'package:safereach/providers/sos_provider.dart';
import 'package:safereach/providers/accessibility_provider.dart';
import 'package:safereach/services/shake_detection_service.dart';
import 'package:safereach/services/voice_recognition_service.dart';
import 'package:safereach/services/fall_detection_service.dart';
import 'package:safereach/services/firestore_service.dart';
import 'package:safereach/services/notification_service.dart';

import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _selectedMessageIndex = 0;
  bool _isVoiceListening = false;
  


  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBackgroundServices();
    });
  }



  Future<void> _initBackgroundServices() async {
    // Proactively request critical permissions so the user isn't prompted during an emergency
    await [
      Permission.sms,
      Permission.location,
      Permission.microphone,
    ].request();

    final profile = ref.read(profileProvider);
    if (profile == null) return;
    final methods = profile.accessibilityProfile.enabledSOSMethods;

    if (methods.contains(SOSActivationMethod.shake)) {
      ref.read(shakeDetectionServiceProvider).start(
        onShakeDetected: () => _triggerSOS(method: SOSActivationMethod.shake),
      );
    }
    
    if (methods.contains(SOSActivationMethod.voice) && !profile.accessibilityProfile.disabilityTypes.contains(DisabilityType.speech)) {
      final voiceService = ref.read(voiceRecognitionServiceProvider);
      voiceService.startListening(
        onHotwordDetected: () => _triggerSOS(method: SOSActivationMethod.voice),
        customHotword: profile.accessibilityProfile.customVoiceCommand,
        locale: profile.preferredLanguage,
      ).then((_) {
        if (mounted) setState(() => _isVoiceListening = voiceService.isListening);
      });
    }

    ref.read(fallDetectionServiceProvider).start(
      onFallDetected: (event) => _showFallDetectionDialog(),
      onFallConfirmed: () => _triggerSOS(method: SOSActivationMethod.autoDetect, message: 'Fall Detected! Please help.'),
    );
  }

  void _showFallDetectionDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: SafeReachTheme.darkSurface,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: SafeReachTheme.warningOrange),
            SizedBox(width: 8),
            Text('Fall Detected!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'We detected a possible fall. Are you okay?\n\nIf you do not respond, an SOS alert will be sent automatically.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              ref.read(fallDetectionServiceProvider).dismissFall();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: SafeReachTheme.safeGreen, foregroundColor: Colors.white),
            child: const Text('I\'M OKAY'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _triggerSOS(method: SOSActivationMethod.autoDetect, message: 'Fall Detected! Please help.');
            },
            style: ElevatedButton.styleFrom(backgroundColor: SafeReachTheme.sosRed, foregroundColor: Colors.white),
            child: const Text('SEND SOS NOW'),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _pulseController.dispose();
    // Note: Do not stop services in dispose if they should run in background,
    // but since this is the main screen, we stop them here for simplicity in this demo.
    // In a real app, these would be detached background services.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final sosStatus = ref.watch(sosProvider);
    final simplified = ref.watch(simplifiedUIProvider);
    final buttonSize = ref.watch(sosButtonSizeProvider);
    final handPref = ref.watch(handPreferenceProvider);

    // Auto-navigate to countdown/active screens
    if (sosStatus.state == SOSState.countdown) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.countdown));
    } else if (sosStatus.state == SOSState.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.activeEmergency));
    }

    return Scaffold(
      backgroundColor: SafeReachTheme.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(profile?.name ?? 'User'),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status indicator
                  _buildLocationBadge(),
                  const SizedBox(height: 8),
                  if (_isVoiceListening)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic, color: SafeReachTheme.accentBlue, size: 16),
                        SizedBox(width: 4),
                        Text('Listening for voice SOS...', style: TextStyle(color: SafeReachTheme.accentBlue, fontSize: 12)),
                      ],
                    ),
                  const SizedBox(height: 32),

                  // SOS BUTTON
                  _buildSOSButton(buttonSize, handPref),

                  const SizedBox(height: 24),

                  // Quick message selector
                  _buildQuickMessage(),
                ],
              ),
            ),

            // Bottom navigation
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $userName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: SafeReachTheme.textPrimary)),
              const Text('You are protected', style: TextStyle(fontSize: 14, color: SafeReachTheme.safeGreen, fontWeight: FontWeight.w500)),
            ],
          ),
          const Spacer(),
          Semantics(
            label: 'Settings',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: SafeReachTheme.textSecondary),
              onPressed: () => context.go(AppRoutes.settings),
            ),
          ),
          Semantics(
            label: 'Profile',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: SafeReachTheme.textSecondary),
              onPressed: () => context.go(AppRoutes.profile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBadge() {
    return Semantics(
      label: 'Location status: GPS available',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: SafeReachTheme.locationLiveGPS.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SafeReachTheme.locationLiveGPS.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🟢', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Text('GPS Ready', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SafeReachTheme.safeGreen)),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton(double size, HandPreference handPref) {
    Alignment alignment;
    switch (handPref) {
      case HandPreference.left: alignment = Alignment.centerLeft; break;
      case HandPreference.right: alignment = Alignment.centerRight; break;
      case HandPreference.center: alignment = Alignment.center; break;
    }

    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: handPref == HandPreference.center ? 0 : 40),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: Semantics(
            label: 'Emergency SOS Button. Double tap to trigger emergency alert.',
            button: true,
            child: GestureDetector(
              onTap: () => _triggerSOS(),
              onLongPress: () => _triggerSOS(method: SOSActivationMethod.longPress),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
                  ),
                  boxShadow: [
                    BoxShadow(color: SafeReachTheme.sosRed.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 5),
                    BoxShadow(color: SafeReachTheme.sosRed.withValues(alpha: 0.2), blurRadius: 60, spreadRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_rounded, color: Colors.white, size: 36),
                    const SizedBox(height: 4),
                    const Text('SOS', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    Text('TAP OR HOLD', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMessage() {
    final messages = ['Medical Emergency', 'Unsafe Situation', 'Need Mobility Help', 'I Am Lost', 'Cannot Speak'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text('Quick Message', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final isActive = _selectedMessageIndex == i;
                return Semantics(
                  label: '${messages[i]}${isActive ? ", selected" : ""}',
                  button: true,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMessageIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? SafeReachTheme.primaryBlue : SafeReachTheme.surfaceMedium,
                        borderRadius: BorderRadius.circular(20),
                        border: isActive ? null : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Text(messages[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : SafeReachTheme.textSecondary)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final profile = ref.watch(profileProvider);
    final isAdminOrResponder = profile?.role == UserRole.admin || profile?.role == UserRole.responder;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'Home', true, () {}),
          if (isAdminOrResponder)
            _buildNavItem(Icons.local_police_outlined, 'Admin', false, () => context.go(AppRoutes.responderHome)),
          _buildNavItem(Icons.history, 'History', false, () => context.go(AppRoutes.incidentHistory)),
          _buildNavItem(Icons.qr_code_scanner, 'Scan QR', false, () => context.go(AppRoutes.qrScanner)),
          _buildNavItem(Icons.person_outline, 'Profile', false, () => context.go(AppRoutes.profile)),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isActive ? SafeReachTheme.primaryBlue : SafeReachTheme.textSecondary, size: 24),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? SafeReachTheme.primaryBlue : SafeReachTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerSOS({SOSActivationMethod method = SOSActivationMethod.oneTap, String? message}) {
    final messages = AppConstants.predefinedMessages;
    final lang = ref.read(profileProvider)?.preferredLanguage ?? 'en';
    final emergencyMessage = message ?? (_selectedMessageIndex < messages.length
        ? messages[_selectedMessageIndex][lang] ?? messages[_selectedMessageIndex]['en']!
        : 'I need help!');

    ref.read(sosProvider.notifier).triggerSOS(
      method: method,
      type: IncidentType.values[min(_selectedMessageIndex, IncidentType.values.length - 1)],
      message: emergencyMessage,
    );
  }
}
