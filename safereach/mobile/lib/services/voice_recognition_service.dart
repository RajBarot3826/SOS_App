/// Voice Recognition Service — On-device speech recognition for SOS trigger
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:safereach/config/constants.dart';

class VoiceRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  Timer? _restartTimer;
  void Function()? _onHotwordDetected;
  String _customHotword = '';
  String _lastRecognizedText = '';
  String _localeId = 'en_US';

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;
  String get lastRecognizedText => _lastRecognizedText;

  /// Initialize speech recognition engine
  Future<bool> initialize() async {
    _isInitialized = await _speech.initialize(
      onStatus: _onStatus,
      onError: (error) => _onError(error),
      debugLogging: false,
    );
    return _isInitialized;
  }

  /// Start listening for hotword triggers
  Future<void> startListening({
    required void Function() onHotwordDetected,
    String? customHotword,
    String locale = 'en_US',
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    _onHotwordDetected = onHotwordDetected;
    _customHotword = customHotword?.toLowerCase() ?? '';
    _localeId = locale;
    _resumeListening();
  }

  void _resumeListening() {
    if (!_isInitialized || _isListening) return;

    _speech.listen(
      onResult: _onSpeechResult,
      localeId: _localeId,
      listenMode: stt.ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
      listenFor: const Duration(seconds: 30),
    );
    _isListening = true;
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords.toLowerCase().trim();
    _lastRecognizedText = text;

    if (text.isEmpty) return;

    // Check against all default voice commands
    for (final command in AppConstants.defaultVoiceCommands) {
      if (text.contains(command.toLowerCase())) {
        _triggerHotword();
        return;
      }
    }

    // Check custom hotword
    if (_customHotword.isNotEmpty && text.contains(_customHotword)) {
      _triggerHotword();
      return;
    }
  }

  void _triggerHotword() {
    _isListening = false;
    _speech.stop();
    _onHotwordDetected?.call();

    // Auto-restart after 5 seconds (in case of false trigger + cancel)
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(seconds: 5), () {
      _resumeListening();
    });
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      // Auto-restart listening after a brief pause
      _restartTimer?.cancel();
      _restartTimer = Timer(const Duration(seconds: 1), () {
        _resumeListening();
      });
    }
  }

  void _onError(dynamic error) {
    _isListening = false;
    // Retry after 3 seconds on error
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(seconds: 3), () {
      _resumeListening();
    });
  }

  /// Map language codes to locale IDs
  static String localeForLanguage(String langCode) {
    switch (langCode) {
      case 'hi':
        return 'hi_IN';
      case 'gu':
        return 'gu_IN';
      case 'en':
      default:
        return 'en_US';
    }
  }

  /// Stop listening entirely
  void stop() {
    _isListening = false;
    _speech.stop();
    _restartTimer?.cancel();
  }

  void dispose() {
    stop();
    _speech.cancel();
  }
}

// Riverpod provider
final voiceRecognitionServiceProvider = Provider<VoiceRecognitionService>((ref) {
  final service = VoiceRecognitionService();
  ref.onDispose(() => service.dispose());
  return service;
});
