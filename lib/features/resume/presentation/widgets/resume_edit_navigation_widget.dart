import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/navigation/app_router.dart';

/// Section definition for resume edit navigation
class _ResumeSection {
  final String routeName;
  final String label;
  final IconData icon;

  const _ResumeSection({
    required this.routeName,
    required this.label,
    required this.icon,
  });
}

const _sections = [
  _ResumeSection(routeName: AppRouter.resumeEditPersonal, label: 'Personal Info', icon: Icons.person_outline),
  _ResumeSection(routeName: AppRouter.resumeEditCareer, label: 'Career Objective', icon: Icons.flag_outlined),
  _ResumeSection(routeName: AppRouter.resumeEditExperience, label: 'Experience', icon: Icons.work_outline),
  _ResumeSection(routeName: AppRouter.resumeEditEducation, label: 'Education', icon: Icons.school_outlined),
  _ResumeSection(routeName: AppRouter.resumeEditSkills, label: 'Skills', icon: Icons.star_outline),
  _ResumeSection(routeName: AppRouter.resumeEditLanguage, label: 'Languages', icon: Icons.language_outlined),
  _ResumeSection(routeName: AppRouter.resumeEditAwards, label: 'Certifications', icon: Icons.workspace_premium_outlined),
  _ResumeSection(routeName: AppRouter.resumeEditReference, label: 'Referees', icon: Icons.people_outline),
];

/// A widget that provides navigation between resume edit screens via a drawer
class ResumeEditNavigationWidget extends StatelessWidget {
  /// The current screen route name
  final String currentScreen;

  /// Constructor
  const ResumeEditNavigationWidget({
    Key? key,
    required this.currentScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      tooltip: 'Sections',
      onPressed: () => _showSectionDrawer(context),
    );
  }

  void _showSectionDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.edit_note, color: primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Profile Builder',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sections.length,
                itemBuilder: (ctx, index) {
                  final section = _sections[index];
                  final isActive = section.routeName == currentScreen;
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isActive ? primary : primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        section.icon,
                        size: 18,
                        color: isActive ? Colors.white : primary,
                      ),
                    ),
                    title: Text(
                      section.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? primary : null,
                      ),
                    ),
                    trailing: isActive
                        ? Icon(Icons.check_circle, color: primary, size: 18)
                        : const Icon(Icons.chevron_right, size: 18),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (section.routeName != currentScreen) {
                        context.goNamed(section.routeName);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// A horizontal section progress stepper shown at the top of edit screens
class ResumeSectionProgressBar extends StatelessWidget {
  /// The current screen route name
  final String currentScreen;

  /// Constructor
  const ResumeSectionProgressBar({Key? key, required this.currentScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final currentIndex = _sections.indexWhere((s) => s.routeName == currentScreen);
    final total = _sections.length;

    return Container(
      color: primary.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentIndex >= 0 ? _sections[currentIndex].label : 'Edit Profile',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
              Text(
                '${currentIndex + 1} of $total',
                style: TextStyle(fontSize: 12, color: primary.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? (currentIndex + 1) / total : 0,
              backgroundColor: primary.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

/// A styled section card wrapper for form content
class ResumeSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResumeSectionCard({Key? key, required this.child, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

/// A styled section header with icon
class ResumeSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const ResumeSectionHeader({
    Key? key,
    required this.title,
    required this.icon,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation buttons (Prev / Next) for resume edit screens
class ResumeNavButtons extends StatelessWidget {
  final String? prevRoute;
  final String? nextRoute;
  final VoidCallback? onSave;
  final bool isSaving;

  const ResumeNavButtons({
    Key? key,
    this.prevRoute,
    this.nextRoute,
    this.onSave,
    this.isSaving = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          if (prevRoute != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.goNamed(prevRoute!),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          if (prevRoute != null && nextRoute != null) const SizedBox(width: 12),
          if (nextRoute != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : () => context.goNamed(nextRoute!),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A skeleton loader for resume edit screens
class ResumeEditSkeleton extends StatelessWidget {
  /// Constructor
  const ResumeEditSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner skeleton
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          // Section header skeleton
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Card skeleton
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
          // Another section header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Another card
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}
