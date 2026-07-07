import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onTranscript;
  final bool isEnabled;

  const VoiceInputButton({
    required this.onTranscript,
    this.isEnabled = true,
    super.key,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isAvailable = false;
  String _transcript = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speech.initialize(
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
          _showError('Microphone error: ${error.errorMsg}');
        }
      },
      onStatus: (status) {
        if (status == 'done' && _isListening) {
          _stopListening();
        }
      },
    );
    setState(() {});
  }

  Future<void> _startListening() async {
    if (!_isAvailable || !widget.isEnabled) {
      return;
    }

    final hasPermission = await _speech.initialize();

    if (!hasPermission) {
      _showError('Microphone permission denied');
      return;
    }

    setState(() {
      _isListening = true;
      _transcript = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcript = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    setState(() {
      _isListening = false;
    });

    if (_transcript.isNotEmpty) {
      widget.onTranscript(_transcript);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.isEnabled ? _startListening : null,
      onLongPressEnd: (_) {
        if (_isListening) {
          _stopListening();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isListening ? 100 : 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: _isListening
              ? LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: _isListening ? null : AppColors.primary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_isListening ? 0.4 : 0.2),
              offset: const Offset(0, 4),
              blurRadius: _isListening ? 16 : 8,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (_isListening)
                  Container(
                    width: 56 + (20 * _animationController.value),
                    height: 56 + (20 * _animationController.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(
                          0.3 * (1 - _animationController.value),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
