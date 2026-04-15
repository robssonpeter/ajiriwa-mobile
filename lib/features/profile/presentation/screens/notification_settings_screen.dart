import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/navigation/app_router.dart';

/// Notification Settings Screen - allows users to configure their notification preferences
class NotificationSettingsScreen extends StatefulWidget {
  /// Constructor
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const _keyJobAlerts = 'notif_job_alerts';
  static const _keyAppUpdates = 'notif_application_updates';
  static const _keyMessages = 'notif_messages';
  static const _keyMarketing = 'notif_marketing_emails';

  bool _jobAlerts = true;
  bool _applicationUpdates = true;
  bool _messages = true;
  bool _marketingEmails = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jobAlerts = prefs.getBool(_keyJobAlerts) ?? true;
      _applicationUpdates = prefs.getBool(_keyAppUpdates) ?? true;
      _messages = prefs.getBool(_keyMessages) ?? true;
      _marketingEmails = prefs.getBool(_keyMarketing) ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyJobAlerts, _jobAlerts);
    await prefs.setBool(_keyAppUpdates, _applicationUpdates);
    await prefs.setBool(_keyMessages, _messages);
    await prefs.setBool(_keyMarketing, _marketingEmails);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings saved')),
      );
      context.goNamed(AppRouter.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(AppRouter.profile),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage your notification preferences',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  _buildNotificationOption(
                    title: 'Job Alerts',
                    subtitle:
                        'Receive notifications about new job opportunities that match your profile',
                    value: _jobAlerts,
                    onChanged: (v) => setState(() => _jobAlerts = v),
                  ),
                  const Divider(),

                  _buildNotificationOption(
                    title: 'Application Updates',
                    subtitle:
                        'Get notified about changes to your job applications',
                    value: _applicationUpdates,
                    onChanged: (v) => setState(() => _applicationUpdates = v),
                  ),
                  const Divider(),

                  _buildNotificationOption(
                    title: 'Messages',
                    subtitle:
                        'Receive notifications for new messages from employers',
                    value: _messages,
                    onChanged: (v) => setState(() => _messages = v),
                  ),
                  const Divider(),

                  _buildNotificationOption(
                    title: 'Marketing Emails',
                    subtitle:
                        'Receive promotional emails about Ajiriwa services and features',
                    value: _marketingEmails,
                    onChanged: (v) => setState(() => _marketingEmails = v),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
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
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
