/// Profile Setup Screen — Name, age, photo
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/user_profile.dart';
import 'package:safereach/providers/profile_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedLanguage = 'en';
  UserRole _selectedRole = UserRole.user;

  @override
  void initState() {
    super.initState();
    // Parse query params from route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      setState(() {
        _selectedLanguage = uri.queryParameters['lang'] ?? 'en';
        _selectedRole = UserRole.values.firstWhere(
          (r) => r.name == uri.queryParameters['role'],
          orElse: () => UserRole.user,
        );
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.welcome),
          tooltip: 'Go back',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                _buildProgress(1, 6),
                const SizedBox(height: 24),

                // Step title
                Semantics(
                  header: true,
                  child: Text(
                    'Tell us about yourself',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This helps us personalize your emergency profile',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Photo placeholder
                Center(
                  child: Semantics(
                    label: 'Profile photo. Tap to add photo',
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        // Photo picker placeholder
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo picker coming soon')),
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: SafeReachTheme.surfaceMedium,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: SafeReachTheme.accentBlue.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 36,
                          color: SafeReachTheme.accentBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Add Photo (Optional)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 32),

                // Name field
                Semantics(
                  label: 'Full name input field',
                  textField: true,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Age field
                Semantics(
                  label: 'Age input field',
                  textField: true,
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'Enter your age',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final age = int.tryParse(value);
                        if (age == null || age < 1 || age > 150) {
                          return 'Please enter a valid age';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // Continue button
                Semantics(
                  label: 'Continue to accessibility setup',
                  button: true,
                  child: SizedBox(
                    height: 56,
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
      ),
    );
  }

  Widget _buildProgress(int current, int total) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $current of $total',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${((current / total) * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
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

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final age = int.tryParse(_ageController.text.trim());

      ref.read(profileProvider.notifier).createProfile(
            name: name,
            role: _selectedRole,
            age: age,
            preferredLanguage: _selectedLanguage,
          );

      context.go(AppRoutes.accessibilitySetup);
    }
  }
}
