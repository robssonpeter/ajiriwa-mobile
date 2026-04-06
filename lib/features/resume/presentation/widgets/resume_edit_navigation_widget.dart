import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_router.dart';

/// A widget that provides navigation between resume edit screens
class ResumeEditNavigationWidget extends StatelessWidget {
  /// The current screen name
  final String currentScreen;

  /// Constructor
  const ResumeEditNavigationWidget({
    Key? key,
    required this.currentScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      tooltip: 'Navigate to section',
      onSelected: (String routeName) {
        if (routeName != currentScreen) {
          context.goNamed(routeName);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: AppRouter.resumeEditPersonal,
          child: Text('Personal Information'),
        ),
        const PopupMenuItem<String>(
          value: AppRouter.resumeEditCareer,
          child: Text('Career Objective'),
        ),
        const PopupMenuItem<String>(
          value: AppRouter.resumeEditExperience,
          child: Text('Work Experience'),
        ),
        const PopupMenuItem<String>(
          value: AppRouter.resumeEditEducation,
          child: Text('Education'),
        ),
        const PopupMenuItem<String>(
          value: AppRouter.resumeEditLanguage,
          child: Text('Languages'),
        ),
        const PopupMenuItem<String>(
          value: AppRouter.resumeEditSkills,
          child: Text('Skills'),
        ),
        const PopupMenuItem<String>(
          value: AppRouter.resumeEditAwards,
          child: Text('Awards'),
        ),
        const PopupMenuItem<String>(
          value: AppRouter.resumeEditReference,
          child: Text('References'),
        ),
      ],
    );
  }
}