/// SOS Method Setup Screen — Configure activation methods
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/constants.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/accessibility_profile.dart';
import 'package:safereach/providers/profile_provider.dart';

class SOSMethodSetupScreen extends ConsumerStatefulWidget {
  const SOSMethodSetupScreen({super.key});

  @override
  ConsumerState<SOSMethodSetupScreen> createState() => _SOSMethodSetupScreenState();
}

class _SOSMethodSetupScreenState extends ConsumerState<SOSMethodSetupScreen> {
  final Set<String> _selectedMethods = {'one_tap'};
  double _countdownSeconds = 5;
  ShakeSensitivity _shakeSensitivity = ShakeSensitivity.medium;
  final _voiceCommandController = TextEditingController(text: 'Help me');

  @override
  void dispose() {
    _voiceCommandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Methods'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.accessibilitySetup),
          tooltip: 'Go back',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                    _buildProgress(3, 6),
                    const SizedBox(height: 24),
                    Semantics(
                      header: true,
                      child: Text('How to Trigger SOS', style: Theme.of(context).textTheme.headlineMedium),
                    ),
                    const SizedBox(height: 8),
                    Text('Select one or more methods. One-Tap is always enabled.', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),

                    ...AppConstants.sosMethods.map((method) {
                      final id = method['id'] as String;
                      final isSelected = _selectedMethods.contains(id);
                      final isOneTap = id == 'one_tap';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Semantics(
                          label: '${method['label']}. ${method['description']}${isSelected ? ", enabled" : ""}',
                          button: true,
                          child: InkWell(
                            onTap: isOneTap ? null : () {
                              setState(() {
                                if (isSelected) {
                                  _selectedMethods.remove(id);
                                } else {
                                  _selectedMethods.add(id);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? SafeReachTheme.accentBlue.withValues(alpha: 0.08) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? SafeReachTheme.accentBlue : Colors.grey.withValues(alpha: 0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(method['icon'] as IconData, color: isSelected ? SafeReachTheme.accentBlue : SafeReachTheme.textSecondary, size: 28),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(method['label'] as String, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? SafeReachTheme.accentBlue : SafeReachTheme.textPrimary)),
                                        Text(method['description'] as String, style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isSelected,
                                    onChanged: isOneTap ? null : (val) {
                                      setState(() {
                                        if (val) { _selectedMethods.add(id); } else { _selectedMethods.remove(id); }
                                      });
                                    },
                                    activeColor: SafeReachTheme.accentBlue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                    // Countdown slider
                    Text('Countdown Duration', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Time before SOS is sent (0 = instant)', style: Theme.of(context).textTheme.bodySmall),
                    Row(
                      children: [
                        Text('${_countdownSeconds.round()}s', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: SafeReachTheme.accentBlue)),
                        Expanded(
                          child: Semantics(
                            label: 'Countdown duration ${_countdownSeconds.round()} seconds',
                            slider: true,
                            child: Slider(
                              value: _countdownSeconds,
                              min: 0, max: 10, divisions: 10,
                              label: '${_countdownSeconds.round()}s',
                              activeColor: SafeReachTheme.accentBlue,
                              onChanged: (v) => setState(() => _countdownSeconds = v),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Shake sensitivity (conditional)
                    if (_selectedMethods.contains('shake')) ...[
                      const SizedBox(height: 20),
                      Text('Shake Sensitivity', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: ShakeSensitivity.values.map((s) {
                          final isActive = _shakeSensitivity == s;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Semantics(
                                label: '${s.name} shake sensitivity${isActive ? ", selected" : ""}',
                                button: true,
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _shakeSensitivity = s),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isActive ? SafeReachTheme.accentBlue : SafeReachTheme.surfaceMedium,
                                    foregroundColor: isActive ? Colors.white : SafeReachTheme.textPrimary,
                                    elevation: isActive ? 2 : 0,
                                  ),
                                  child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Custom voice command (conditional)
                    if (_selectedMethods.contains('voice')) ...[
                      const SizedBox(height: 20),
                      Text('Custom Voice Command', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _voiceCommandController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Help me, Bachao',
                          prefixIcon: Icon(Icons.mic),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                    
                    // Continue button
                    SizedBox(
                      height: 56, width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onContinue,
                        style: ElevatedButton.styleFrom(backgroundColor: SafeReachTheme.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded)]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProgress(int current, int total) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Step $current of $total', style: Theme.of(context).textTheme.bodySmall),
        Text('${((current / total) * 100).round()}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: current / total, minHeight: 6, backgroundColor: SafeReachTheme.surfaceMedium, valueColor: const AlwaysStoppedAnimation<Color>(SafeReachTheme.accentBlue))),
    ]);
  }

  void _onContinue() {
    final methods = _selectedMethods.map((id) {
      switch (id) {
        case 'one_tap': return SOSActivationMethod.oneTap;
        case 'shake': return SOSActivationMethod.shake;
        case 'voice': return SOSActivationMethod.voice;
        case 'long_press': return SOSActivationMethod.longPress;
        case 'gesture': return SOSActivationMethod.gesture;
        case 'power_button': return SOSActivationMethod.powerButton;
        case 'widget': return SOSActivationMethod.widget;
        case 'wearable': return SOSActivationMethod.wearable;
        case 'silent': return SOSActivationMethod.silent;
        case 'auto_detect': return SOSActivationMethod.autoDetect;
        default: return SOSActivationMethod.oneTap;
      }
    }).toList();

    final profile = ref.read(profileProvider);
    if (profile != null) {
      final updated = profile.accessibilityProfile.copyWith(
        enabledSOSMethods: methods,
        countdownSeconds: _countdownSeconds.round(),
        shakeSensitivity: _shakeSensitivity,
        customVoiceCommand: _voiceCommandController.text.trim().isNotEmpty ? _voiceCommandController.text.trim() : 'help me',
        silentModeEnabled: _selectedMethods.contains('silent'),
      );
      ref.read(profileProvider.notifier).updateAccessibilityProfile(updated);
    }
    context.go(AppRoutes.contactsSetup);
  }
}
