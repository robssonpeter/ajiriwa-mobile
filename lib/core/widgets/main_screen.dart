import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_router.dart';

/// Main screen with bottom navigation
class MainScreen extends StatelessWidget {
  /// The location from the GoRouter
  final String location;
  
  /// The child widget to display in the body
  final Widget child;

  /// Constructor
  const MainScreen({
    Key? key,
    required this.location,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: AppRouter.getTabIndex(location),
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// Handle bottom navigation item tap
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case AppRouter.dashboardTabIndex:
        context.goNamed(AppRouter.dashboard);
        break;
      case AppRouter.jobsTabIndex:
        context.goNamed(AppRouter.jobs);
        break;
      case AppRouter.applicationsTabIndex:
        context.goNamed(AppRouter.applications);
        break;
      case AppRouter.savedJobsTabIndex:
        context.goNamed(AppRouter.savedJobs);
        break;
      case AppRouter.profileTabIndex:
        context.goNamed(AppRouter.profile);
        break;
    }
  }
}