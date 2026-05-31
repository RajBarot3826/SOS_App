import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/services/firebase_auth_service.dart';
import 'package:safereach/screens/auth/otp_verification_screen.dart';
import 'package:safereach/providers/profile_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _verifyPhone() {
    if (_phoneController.text.trim().length < 10) {
      setState(() => _errorMessage = 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // DEMO BYPASS: We are bypassing Firebase Phone Auth since the region is blocked.
    // It will fake a 1.5 second loading screen and jump straight into the app.
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (mounted) {
        final storage = ref.read(storageServiceProvider);
        await storage.setSetting('demo_logged_in', true);
        setState(() => _isLoading = false);
        context.go('/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.security, size: 64, color: SafeReachTheme.primaryBlue),
            const SizedBox(height: 24),
            const Text(
              'Enter your phone number',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'We will send you an OTP to verify your account and enable emergency tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+91 ',
                errorText: _errorMessage,
                errorMaxLines: 4, // allow error text to wrap
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyPhone,
              style: ElevatedButton.styleFrom(
                backgroundColor: SafeReachTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Send OTP', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
