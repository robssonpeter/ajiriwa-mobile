import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';

/// Notification Settings Screen - allows users to configure their notification preferences
class NotificationSettingsScreen extends StatefulWidget {
  /// Constructor
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Notification settings
  bool _jobAlerts = true;
  bool _applicationUpdates = true;
  bool _messages = true;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to profile page
            context.goNamed(AppRouter.profile);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage your notification preferences',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Job Alerts
            _buildNotificationOption(
              title: 'Job Alerts',
              subtitle: 'Receive notifications about new job opportunities that match your profile',
              value: _jobAlerts,
              onChanged: (value) {
                setState(() {
                  _jobAlerts = value;
                });
              },
            ),

            const Divider(),

            // Application Updates
            _buildNotificationOption(
              title: 'Application Updates',
              subtitle: 'Get notified about changes to your job applications',
              value: _applicationUpdates,
              onChanged: (value) {
                setState(() {
                  _applicationUpdates = value;
                });
              },
            ),

            const Divider(),

            // Messages
            _buildNotificationOption(
              title: 'Messages',
              subtitle: 'Receive notifications for new messages from employers',
              value: _messages,
              onChanged: (value) {
                setState(() {
                  _messages = value;
                });
              },
            ),

            const Divider(),

            // Marketing Emails
            _buildNotificationOption(
              title: 'Marketing Emails',
              subtitle: 'Receive promotional emails about Ajiriwa services and features',
              value: _marketingEmails,
              onChanged: (value) {
                setState(() {
                  _marketingEmails = value;
                });
              },
            ),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save notification settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification settings saved'),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
