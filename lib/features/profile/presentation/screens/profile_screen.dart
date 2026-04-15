import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/bloc.dart';

/// Profile screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _keyAutoApply = 'auto_apply_enabled';
  bool _autoApplyEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadAutoApplySetting();
  }

  Future<void> _loadAutoApplySetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoApplyEnabled = prefs.getBool(_keyAutoApply) ?? false;
    });
  }

  Future<void> _setAutoApply(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoApply, value);
    setState(() => _autoApplyEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Profile'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.goNamed(AppRouter.notificationSettings),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(context, user),
                  const SizedBox(height: 24),

                  if (user.candidates != null && user.candidates!.length > 1) ...[
                    _buildSectionHeader('Switch Profile'),
                    const SizedBox(height: 16),
                    _buildProfileSwitcher(context, user),
                    const SizedBox(height: 24),
                  ],

                  _buildSectionHeader('My Resume'),
                  const SizedBox(height: 16),
                  _buildResumeCard(context),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Account'),
                  const SizedBox(height: 16),
                  _buildAccountOptions(context),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Auto-Apply'),
                  const SizedBox(height: 16),
                  _buildAutoApplyCard(context),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Support'),
                  const SizedBox(height: 16),
                  _buildSupportOptions(context),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      onPressed: () => _showLogoutConfirmationDialog(context),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        } else if (state is AuthLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Profile')),
            body: _buildProfileSkeleton(),
          );
        } else {
          Future.microtask(() => context.goNamed(AppRouter.login));
          return Scaffold(
            appBar: AppBar(title: const Text('My Profile')),
            body: _buildProfileSkeleton(),
          );
        }
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: user.photoUrl != null &&
                        !user.photoUrl!.contains('ui-avatars.com')
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null ||
                        user.photoUrl!.contains('ui-avatars.com')
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Photo upload coming soon')),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.headline ?? user.role ?? 'Ajiriwa User',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(user.email, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => context.goNamed(AppRouter.resumeEditPersonal),
          child: const Text('Edit Profile'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildProfileSwitcher(BuildContext context, User user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: user.candidates!.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final candidate = user.candidates![index];
          final isSelected = candidate['id'] == user.selectedCandidateId;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.grey.shade100,
              child: Icon(
                Icons.person,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
            title: Text(
              candidate['label'] ?? 'CV #${candidate['id']}',
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            subtitle: candidate['title'] != null ? Text(candidate['title']) : null,
            trailing: isSelected
                ? Icon(Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: isSelected
                ? null
                : () => context
                    .read<AuthBloc>()
                    .add(SwitchCandidateEvent(candidate['id'])),
          );
        },
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('View Resume'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(AppRouter.resumeView),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Resume'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(AppRouter.resumeEdit),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Upload Documents'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(AppRouter.resumeEditAwards),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOptions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Personal Information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(AppRouter.resumeEditPersonal),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(AppRouter.changePassword),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(AppRouter.notificationSettings),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoApplyCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Auto-Apply Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Switch(
                  value: _autoApplyEnabled,
                  onChanged: _setAutoApply,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _autoApplyEnabled
                  ? "Auto-Apply is enabled. We'll automatically apply to jobs that match your criteria."
                  : 'Auto-Apply is disabled. Enable it to automatically apply to matching jobs.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Auto-apply configuration coming soon')),
                );
              },
              child: const Text('Configure Auto-Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOptions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help Center'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _launchUrl('https://ajiriwa.net/help'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Contact Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _launchUrl('mailto:support@ajiriwa.net'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Ajiriwa'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Ajiriwa',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      children: [
        const Text(
          'Ajiriwa is a job board platform connecting job seekers with employers across Africa.',
        ),
        const SizedBox(height: 8),
        const Text('Visit us at ajiriwa.net'),
      ],
    );
  }

  Widget _buildProfileSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 180,
                        height: 20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(
                        width: 140,
                        height: 14,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            ...List.generate(
              4,
              (index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 100,
                      height: 18,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 16),
                  Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12))),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutEvent());
              Future.delayed(const Duration(milliseconds: 100), () {
                context.goNamed(AppRouter.login);
              });
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
