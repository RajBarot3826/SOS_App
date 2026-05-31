/// Accessibility Setup Screen — Multi-select disability profile with live UI preview
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/constants.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/accessibility_profile.dart';
import 'package:safereach/providers/profile_provider.dart';

class AccessibilitySetupScreen extends ConsumerStatefulWidget {
  const AccessibilitySetupScreen({super.key});

  @override
  ConsumerState<AccessibilitySetupScreen> createState() =>
      _AccessibilitySetupScreenState();
}

class _AccessibilitySetupScreenState
    extends ConsumerState<AccessibilitySetupScreen> {
  final Set<String> _selectedTypes = {'none'};
  FeedbackMode _feedbackMode = FeedbackMode.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.profileSetup),
          tooltip: 'Go back',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                    _buildProgress(2, 6),
                    const SizedBox(height: 24),

                    Semantics(
                      header: true,
                      child: Text(
                        'Your Accessibility Needs',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select all that apply. The app will automatically adapt to your needs.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Accessibility options grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: AppConstants.accessibilityOptions.length,
                      itemBuilder: (context, index) {
                        final option = AppConstants.accessibilityOptions[index];
                        final id = option['id'] as String;
                        final isSelected = _selectedTypes.contains(id);
                        final icon = option['icon'] as IconData;
                        final label = option['label'] as String;

                        return Semantics(
                          label: '$label${isSelected ? ", selected" : ""}',
                          button: true,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (id == 'none') {
                                  _selectedTypes.clear();
                                  _selectedTypes.add('none');
                                } else {
                                  _selectedTypes.remove('none');
                                  if (isSelected) {
                                    _selectedTypes.remove(id);
                                    if (_selectedTypes.isEmpty) {
                                      _selectedTypes.add('none');
                                    }
                                  } else {
                                    _selectedTypes.add(id);
                                  }
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? SafeReachTheme.accentBlue.withValues(alpha: 0.1)
                                    : Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? SafeReachTheme.accentBlue
                                      : Colors.grey.withValues(alpha: 0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: SafeReachTheme.accentBlue.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    icon,
                                    size: 32,
                                    color: isSelected
                                        ? SafeReachTheme.accentBlue
                                        : SafeReachTheme.textSecondary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected
                                          ? SafeReachTheme.accentBlue
                                          : SafeReachTheme.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Feedback Mode Selection
                    Semantics(
                      header: true,
                      child: Text(
                        'Alert Feedback Mode',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How should the app alert you?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ..._buildFeedbackOptions(),

                    const SizedBox(height: 16),

                    // Live preview of adaptations
                    if (!_selectedTypes.contains('none')) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: SafeReachTheme.safeGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: SafeReachTheme.safeGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome,
                                    color: SafeReachTheme.safeGreen, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Auto-Adaptations Applied',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: SafeReachTheme.safeGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ..._getAdaptationDescriptions(),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 40),
                    
                    // Continue button
                    Semantics(
                      label: 'Continue to SOS method setup',
                      button: true,
                      child: SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SafeReachTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildFeedbackOptions() {
    final options = [
      (FeedbackMode.sound, Icons.volume_up, 'Sound', 'Audio alerts and notifications'),
      (FeedbackMode.vibration, Icons.vibration, 'Vibration', 'Haptic feedback only'),
      (FeedbackMode.visualFlash, Icons.flash_on, 'Visual Flash', 'Screen flash alerts'),
      (FeedbackMode.all, Icons.tune, 'All Three', 'Sound + Vibration + Flash'),
    ];

    return options.map((opt) {
      final isSelected = _feedbackMode == opt.$1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Semantics(
          label: '${opt.$3} feedback mode${isSelected ? ", selected" : ""}',
          button: true,
          child: InkWell(
            onTap: () => setState(() => _feedbackMode = opt.$1),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? SafeReachTheme.accentBlue.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? SafeReachTheme.accentBlue
                      : Colors.grey.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(opt.$2, color: isSelected ? SafeReachTheme.accentBlue : SafeReachTheme.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt.$3, style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? SafeReachTheme.accentBlue : SafeReachTheme.textPrimary,
                        )),
                        Text(opt.$4, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: SafeReachTheme.accentBlue),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _getAdaptationDescriptions() {
    final descriptions = <String>[];
    for (final id in _selectedTypes) {
      switch (id) {
        case 'visual':
          descriptions.add('✓ Voice guidance enabled');
          descriptions.add('✓ High-contrast mode activated');
          descriptions.add('✓ Font size increased to 130%');
        case 'lowvision':
          descriptions.add('✓ High-contrast mode activated');
          descriptions.add('✓ Font size increased to 120%');
        case 'hearing':
          descriptions.add('✓ Vibration-only feedback mode');
        case 'cognitive':
          descriptions.add('✓ Pictogram mode enabled');
          descriptions.add('✓ Simplified interface');
        case 'elderly':
          descriptions.add('✓ Larger text and buttons');
          descriptions.add('✓ Voice guidance enabled');
          descriptions.add('✓ Simplified interface');
        case 'physical':
        case 'temporary':
          descriptions.add('✓ Extra-large touch targets (64dp+)');
          descriptions.add('✓ Font size increased');
        case 'neurological':
          descriptions.add('✓ Simplified interface');
      }
    }
    return descriptions
        .toSet()
        .map((d) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(d, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SafeReachTheme.safeGreen,
                  )),
            ))
        .toList();
  }

  void _onContinue() {
    final disabilityTypes = _selectedTypes.map((id) {
      switch (id) {
        case 'physical': return DisabilityType.physical;
        case 'visual': return DisabilityType.visual;
        case 'lowvision': return DisabilityType.lowVision;
        case 'hearing': return DisabilityType.hearing;
        case 'speech': return DisabilityType.speech;
        case 'cognitive': return DisabilityType.cognitive;
        case 'neurological': return DisabilityType.neurological;
        case 'elderly': return DisabilityType.elderly;
        case 'temporary': return DisabilityType.temporary;
        default: return DisabilityType.none;
      }
    }).toList();

    final profile = AccessibilityProfile(
      disabilityTypes: disabilityTypes,
      feedbackMode: _feedbackMode,
    );

    ref.read(profileProvider.notifier).updateAccessibilityProfile(profile);
    context.go(AppRoutes.sosMethodSetup);
  }

  Widget _buildProgress(int current, int total) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step $current of $total', style: Theme.of(context).textTheme.bodySmall),
            Text('${((current / total) * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 6,
            backgroundColor: SafeReachTheme.surfaceMedium,
            valueColor: const AlwaysStoppedAnimation<Color>(SafeReachTheme.accentBlue),
          ),
        ),
      ],
    );
  }
}
