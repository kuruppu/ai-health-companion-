import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/chat_message.dart';
import 'voice_input_button.dart';

class ChatInputField extends StatefulWidget {

  const ChatInputField({
    required this.onSendMessage,
    super.key,
  });
  final Future<void> Function(String content, MessageType messageType)
      onSendMessage;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChanged(String text) {
    setState(() {
      _isComposing = text.trim().isNotEmpty;
    });
  }

  Future<void> _handleSubmit() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
      _isComposing = false;
    });

    _controller.clear();

    try {
      await widget.onSendMessage(text, MessageType.text);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _handleVoiceInput(String transcript) async {
    if (transcript.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await widget.onSendMessage(transcript, MessageType.voice);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            // Voice Input Button (PRIMARY - bigger)
            VoiceInputButton(
              onTranscript: _handleVoiceInput,
              isEnabled: !_isSending,
            ),
            const SizedBox(width: 8),
            // Text Input (FALLBACK - smaller)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !_isSending,
                  onChanged: _handleTextChanged,
                  onSubmitted: (_) => _handleSubmit(),
                  textInputAction: TextInputAction.send,
                  maxLines: null,
                  maxLength: 500,
                  style: AppTextStyles.inputText,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTextStyles.inputHint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    counterText: '',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send Button
            IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.send,
                      color: _isComposing
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
              onPressed: _isComposing && !_isSending ? _handleSubmit : null,
            ),
          ],
        ),
      ),
    );
}
