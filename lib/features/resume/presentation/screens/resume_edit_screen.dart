import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_router.dart';

/// Resume edit screen - main entry point for resume editing
/// This screen redirects to the personal information section by default
class ResumeEditScreen extends StatelessWidget {
  /// Constructor
  const ResumeEditScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Redirect to personal information section
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.goNamed(AppRouter.resumeEditPersonal);
    });

    // Show loading indicator while redirecting
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}