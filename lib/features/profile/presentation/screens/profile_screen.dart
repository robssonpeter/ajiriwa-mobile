import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/bloc.dart';

/// Profile screen - shows the user's profile information and provides access to resume editing and other settings
class ProfileScreen extends StatelessWidget {
  /// Constructor
  const ProfileScreen({Key? key}) : super(key: key);

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
                  onPressed: () {
                    // TODO: Navigate to settings
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  _buildProfileHeader(context, user),
                  const SizedBox(height: 24),

                  // Multi-profile switcher
                  if (user.candidates != null && user.candidates!.length > 1) ...[
                    _buildSectionHeader(context, 'Switch Profile'),
                    const SizedBox(height: 16),
                    _buildProfileSwitcher(context, user),
                    const SizedBox(height: 24),
                  ],

                  // Resume section
                  _buildSectionHeader(context, 'My Resume'),
                  const SizedBox(height: 16),
                  _buildResumeCard(context),
                  const SizedBox(height: 24),

                  // Account section
                  _buildSectionHeader(context, 'Account'),
                  const SizedBox(height: 16),
                  _buildAccountOptions(context),
                  const SizedBox(height: 24),

                  // Auto-apply section
                  _buildSectionHeader(context, 'Auto-Apply'),
                  const SizedBox(height: 16),
                  _buildAutoApplyCard(context),
                  const SizedBox(height: 24),

                  // Support section
                  _buildSectionHeader(context, 'Support'),
                  const SizedBox(height: 16),
                  _buildSupportOptions(context),
                  const SizedBox(height: 32),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      onPressed: () {
                        _showLogoutConfirmationDialog(context);
                      },
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
            body: _buildProfileSkeleton(context),
          );
        } else {
          // If not authenticated, navigate to login screen
          // Use Future.microtask to ensure navigation happens after the build is complete
          Future.microtask(() => context.goNamed(AppRouter.login));
          // Show loading indicator instead of "Not authenticated" text
          return Scaffold(
            appBar: AppBar(title: const Text('My Profile')),
            body: _buildProfileSkeleton(context),
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
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
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
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      // TODO: Implement photo upload
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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.headline ?? user.role ?? 'Ajiriwa User',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            // Navigate to personal information editing screen
            context.goNamed(AppRouter.resumeEditPersonal);
          },
          child: const Text('Edit Profile'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
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
        separatorBuilder: (context, index) => const Divider(height: 1),
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
                ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: isSelected ? null : () {
              context.read<AuthBloc>().add(SwitchCandidateEvent(candidate['id']));
            },
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
            onTap: () {
              // Navigate to resume view screen
              context.goNamed(AppRouter.resumeView);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Resume'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to resume edit screen
              context.goNamed(AppRouter.resumeEdit);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Upload Documents'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to resume edit awards screen for document uploads
              context.goNamed(AppRouter.resumeEditAwards);
            },
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
            onTap: () {
              // Navigate to personal information editing screen
              context.goNamed(AppRouter.resumeEditPersonal);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to change password screen
              context.goNamed(AppRouter.changePassword);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to notification settings
              context.goNamed(AppRouter.notificationSettings);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAutoApplyCard(BuildContext context) {
    // Sample data - in a real app, this would come from an API
    final bool isAutoApplyEnabled = true;

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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Switch(
                  value: isAutoApplyEnabled,
                  onChanged: (value) {
                    // TODO: Toggle auto-apply
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isAutoApplyEnabled
                  ? 'Auto-Apply is enabled. We\'ll automatically apply to jobs that match your criteria.'
                  : 'Auto-Apply is disabled. Enable it to automatically apply to matching jobs.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to auto-apply settings
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
            onTap: () {
              // TODO: Navigate to help center
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Contact Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to contact support
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Ajiriwa'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to about
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header skeleton
            Row(
              children: [
                Container(width: 80, height: 80, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 180, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(width: 140, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Section skeletons
            ...List.generate(4, (index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 18, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 16),
                Container(width: double.infinity, height: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                const SizedBox(height: 24),
              ],
            )),
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
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();

              // Dispatch logout event to the AuthBloc
              context.read<AuthBloc>().add(LogoutEvent());

              // Navigate to login screen after a short delay to allow the AuthBloc to process the logout event
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
