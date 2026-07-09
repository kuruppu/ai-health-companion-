import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {

  const LoadingIndicator({
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
    super.key,
  });
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
}

class LoadingOverlay extends StatelessWidget {

  const LoadingOverlay({this.message, super.key});
  final String? message;

  @override
  Widget build(BuildContext context) => Container(
      color: AppColors.overlay,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LoadingIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
}
