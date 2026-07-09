import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_check_in.dart';
import '../providers/meal_check_provider.dart';

/// Settings screen with meal check-in testing
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App settings section
          const Text(
            'App Settings',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  subtitle: const Text('Meal check-in reminders'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement notification toggle
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: const Text('English'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement language selection
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Testing section (ONLY for development)
          const Text(
            'Testing (Dev Only)',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 16),

          Card(
            color: AppColors.warning.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meal Check-In Testing',
                    style: AppTextStyles.body1Medium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manually trigger meal check-ins to test the system',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trigger buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _triggerCheckIn(
                          context,
                          ref,
                          MealPeriod.breakfast,
                        ),
                        icon: const Icon(Icons.wb_sunny, size: 18),
                        label: const Text('Breakfast'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade900,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _triggerCheckIn(
                          context,
                          ref,
                          MealPeriod.lunch,
                        ),
                        icon: const Icon(Icons.lunch_dining, size: 18),
                        label: const Text('Lunch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.blue.shade900,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _triggerCheckIn(
                          context,
                          ref,
                          MealPeriod.dinner,
                        ),
                        icon: const Icon(Icons.dinner_dining, size: 18),
                        label: const Text('Dinner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade100,
                          foregroundColor: Colors.purple.shade900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info card
          Card(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'How It Works',
                        style: AppTextStyles.body1Medium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI checks in at:\n'
                    '• 9:00am (breakfast)\n'
                    '• 12:30pm (lunch)\n'
                    '• 7:00pm (dinner)\n\n'
                    'If you haven\'t logged a meal, you\'ll get a friendly reminder.',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // About section
          const Text(
            'About',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Version'),
                  subtitle: Text('1.0.0 (MVP)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show privacy policy
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show terms
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

  void _triggerCheckIn(
    BuildContext context,
    WidgetRef ref,
    MealPeriod period,
  ) {
    ref.read(mealCheckNotifierProvider.notifier).triggerManualCheckIn(period);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Triggered ${period.displayName} check-in. Check Chat tab.',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    // Navigate to chat tab
    Navigator.of(context).pushNamed('/chat');
  }
}
