import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {

  const EmptyState({
    required this.imagePath,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
    super.key,
  });
  final String imagePath;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
}
