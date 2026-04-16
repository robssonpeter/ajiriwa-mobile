import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/bloc.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/jobs/presentation/screens/jobs_screen.dart';
import '../../features/jobs/presentation/screens/job_view_screen.dart';
import '../../features/jobs/presentation/bloc/bloc.dart';
import '../../features/applications/presentation/screens/applications_screen.dart';
import '../../features/applications/presentation/screens/application_details_screen.dart';
import '../../features/saved_jobs/presentation/screens/saved_jobs_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/resume/presentation/screens/resume_edit_screen.dart';
import '../../features/resume/presentation/screens/resume_edit_personal_screen.dart';
import '../../features/resume/presentation/screens/resume_edit_career_screen.dart';
import '../../features/resume/presentation/screens/resume_edit_experience_screen.dart';
import '../../features/resume/presentation/screens/resume_edit_education_screen.dart';
import '../../features/resume/presentation/screens/resume_edit_language_screen.dart';
import '../../features/resume/presentation/screens/resume_edit_skills_screen.dart';
import '../../features/resume/presentation/screens/resume_edit_awards_screen.dart';
import '../../features/resume/presentation/screens/resume_edit_reference_screen.dart';
import '../../features/resume/presentation/screens/resume_view_screen.dart';
import '../../features/resume/presentation/bloc/bloc.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/cv_optimization/presentation/screens/cv_optimization_screen.dart';
import '../../features/cv_optimization/presentation/screens/subscription_screen.dart';
import '../../features/cv_optimization/presentation/bloc/cv_optimization_bloc.dart';
import '../../features/job_alerts/presentation/screens/job_alerts_screen.dart';
import '../../features/jobs/presentation/screens/pre_apply_analysis_screen.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/onboarding/presentation/screens/cv_choice_screen.dart';
import '../../features/onboarding/presentation/screens/cv_success_screen.dart';
import '../../features/onboarding/presentation/screens/cv_upload_screen.dart';
import '../di/injection_container.dart' as di;
import '../widgets/main_screen.dart';

/// Navigation routes for the app
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  // Route names
  static const String dashboard = 'dashboard';
  static const String jobs = 'jobs';
  static const String jobView = 'job_view';
  static const String applications = 'applications';
  static const String applicationView = 'application_view';
  static const String savedJobs = 'saved-jobs';
  static const String profile = 'profile';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';

  // Resume editing route names
  static const String resumeEdit = 'resume-edit';
  static const String resumeEditPersonal = 'resume-edit-personal';
  static const String resumeEditCareer = 'resume-edit-career';
  static const String resumeEditExperience = 'resume-edit-experience';
  static const String resumeEditEducation = 'resume-edit-education';
  static const String resumeEditLanguage = 'resume-edit-language';
  static const String resumeEditSkills = 'resume-edit-skills';
  static const String resumeEditAwards = 'resume-edit-awards';
  static const String resumeEditReference = 'resume-edit-reference';
  static const String resumeView = 'resume-view';

  // Settings route names
  static const String notificationSettings = 'notification-settings';
  static const String changePassword = 'change-password';
  static const String cvOptimization = 'cv-optimization';
  static const String subscription = 'subscription';
  static const String jobAlerts = 'job-alerts';
  static const String preApplyAnalysis = 'pre-apply-analysis';
  static const String onboardingChoice = 'onboarding-choice';
  static const String onboardingUpload = 'onboarding-upload';
  static const String onboardingSuccess = 'onboarding-success';

  // Route paths
  static const String dashboardPath = '/dashboard';
  static const String jobsPath = '/jobs';
  static const String jobViewPath = '/job/:slug';
  static const String applicationsPath = '/applications';
  static const String applicationViewPath = '/application/:id';
  static const String savedJobsPath = '/saved-jobs';
  static const String profilePath = '/profile';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';

  // Resume editing route paths
  static const String resumeEditPath = '/resume/edit';
  static const String resumeEditPersonalPath = '/resume/edit/personal';
  static const String resumeEditCareerPath = '/resume/edit/career';
  static const String resumeEditExperiencePath = '/resume/edit/experience';
  static const String resumeEditEducationPath = '/resume/edit/education';
  static const String resumeEditLanguagePath = '/resume/edit/language';
  static const String resumeEditSkillsPath = '/resume/edit/skills';
  static const String resumeEditAwardsPath = '/resume/edit/awards';
  static const String resumeEditReferencePath = '/resume/edit/reference';
  static const String resumeViewPath = '/resume/view';

  // Settings route paths
  static const String notificationSettingsPath = '/settings/notifications';
  static const String changePasswordPath = '/settings/change-password';
  static const String cvOptimizationPath = '/cv-optimization';
  static const String subscriptionPath = '/subscription';
  static const String jobAlertsPath = '/job-alerts';
  static const String preApplyAnalysisPath = '/pre-apply-analysis';
  static const String onboardingChoicePath = '/onboarding/cv-choice';
  static const String onboardingUploadPath = '/onboarding/cv-upload';
  static const String onboardingSuccessPath = '/onboarding/cv-success';

  // Tab indices for bottom navigation
  static const int dashboardTabIndex = 0;
  static const int jobsTabIndex = 1;
  static const int applicationsTabIndex = 2;
  static const int savedJobsTabIndex = 3;
  static const int profileTabIndex = 4;

  /// Create the GoRouter configuration
  static GoRouter get router => GoRouter(
        initialLocation: dashboardPath,
        routes: [
          // Main scaffold with bottom navigation
          ShellRoute(
            builder: (context, state, child) => MainScreen(
              location: state.uri.toString(),
              child: child,
            ),
            routes: [
              // Dashboard tab
              GoRoute(
                path: dashboardPath,
                name: dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
              // Jobs tab
              GoRoute(
                path: jobsPath,
                name: jobs,
                builder: (context, state) => const JobsScreen(),
              ),
              // Applications tab
              GoRoute(
                path: applicationsPath,
                name: applications,
                builder: (context, state) => const ApplicationsScreen(),
              ),
              // Applications tab
              GoRoute(
                path: applicationViewPath,
                name: applicationView,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  // Provide the JobBloc to the ApplicationDetailsScreen
                  return BlocProvider(
                    create: (context) => di.sl<JobBloc>(),
                    child: ApplicationDetailsScreen(
                      jobDetails: null, // This will be loaded in the screen based on the application ID
                      applicationId: int.parse(id),
                    ),
                  );
                },
              ),
              // Saved Jobs tab
              GoRoute(
                path: savedJobsPath,
                name: savedJobs,
                builder: (context, state) => const SavedJobsScreen(),
              ),
              // Profile tab
              GoRoute(
                path: profilePath,
                name: profile,
                builder: (context, state) => const ProfileScreen(),
              ),

              // Resume editing routes
              // Main resume edit route (redirects to personal by default)
              GoRoute(
                path: resumeEditPath,
                name: resumeEdit,
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => di.sl<ResumeBloc>(),
                    child: const ResumeEditScreen(),
                  );
                },
              ),

              // Personal information edit route
              GoRoute(
                path: resumeEditPersonalPath,
                name: resumeEditPersonal,
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => di.sl<ResumeBloc>(),
                    child: const ResumeEditPersonalScreen(),
                  );
                },
              ),

              // Career information edit route
              GoRoute(
                path: resumeEditCareerPath,
                name: resumeEditCareer,
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => di.sl<ResumeBloc>(),
                    child: const ResumeEditCareerScreen(),
                  );
                },
              ),

              // Experience edit route
              GoRoute(
                path: resumeEditExperiencePath,
                name: resumeEditExperience,
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => di.sl<ResumeBloc>(),
                    child: const ResumeEditExperienceScreen(),
                  );
                },
              ),

              // Education edit route
              GoRoute(
                path: resumeEditEducationPath,
                name: resumeEditEducation,
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => di.sl<ResumeBloc>(),
                    child: const ResumeEditEducationScreen(),
                  );
                },
              ),

              // Language edit route
              GoRoute(
                path: resumeEditLanguagePath,
                name: resumeEditLanguage,
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => di.sl<ResumeBloc>(),
                    child: const ResumeEditLanguageScreen(),
                  );
                },
              ),

              // Skills edit route
              GoRoute(
                path: resumeEditSkillsPath,
                name: resumeEditSkills,
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => di.sl<ResumeBloc>(),
                    child: const ResumeEditSkillsScreen(),
                  );
                },
              ),

              // Awards edit route
              GoRoute(
                path: resumeEditAwardsPath,
                name: resumeEditAwards,
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => di.sl<ResumeBloc>(),
                    child: const ResumeEditAwardsScreen(),
                  );
                },
              ),

              // Reference edit route
              GoRoute(
                path: resumeEditReferencePath,
                name: resumeEditReference,
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => di.sl<ResumeBloc>(),
                    child: const ResumeEditReferenceScreen(),
                  );
                },
              ),

              // Resume view route
              GoRoute(
                path: resumeViewPath,
                name: resumeView,
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => di.sl<ResumeBloc>(),
                    child: const ResumeViewScreen(),
                  );
                },
              ),
            ],
          ),
          // Authentication routes (outside the main shell)
          GoRoute(
            path: loginPath,
            name: login,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: registerPath,
            name: register,
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: forgotPasswordPath,
            name: forgotPassword,
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          // Job view route
          GoRoute(
            path: jobViewPath,
            name: jobView,
            builder: (context, state) {
              final slug = state.pathParameters['slug']!;
              // Provide the JobBloc to the JobViewScreen
              return BlocProvider(
                create: (context) => di.sl<JobBloc>(),
                child: JobViewScreen(slug: slug),
              );
            },
          ),

          // Notification settings route
          GoRoute(
            path: notificationSettingsPath,
            name: notificationSettings,
            builder: (context, state) {
              return const NotificationSettingsScreen();
            },
          ),

          // Change password route
          GoRoute(
            path: changePasswordPath,
            name: changePassword,
            builder: (context, state) {
              return const ChangePasswordScreen();
            },
          ),
          // CV Optimization route
          GoRoute(
            path: cvOptimizationPath,
            name: cvOptimization,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return BlocProvider.value(
                value: di.sl<CvOptimizationBloc>(),
                child: CvOptimizationScreen(
                  jobId: extra?['jobId'] as int?,
                  jobTitle: extra?['jobTitle'] as String?,
                  companyName: extra?['companyName'] as String?,
                ),
              );
            },
          ),
          // Subscription route
          GoRoute(
            path: subscriptionPath,
            name: subscription,
            builder: (context, state) {
              return BlocProvider.value(
                value: di.sl<CvOptimizationBloc>(),
                child: const SubscriptionScreen(),
              );
            },
          ),
          // Job Alerts route
          GoRoute(
            path: jobAlertsPath,
            name: jobAlerts,
            builder: (context, state) => const JobAlertsScreen(),
          ),

          // Onboarding routes
          GoRoute(
            path: onboardingChoicePath,
            name: onboardingChoice,
            builder: (context, state) => const CvChoiceScreen(),
          ),
          GoRoute(
            path: onboardingUploadPath,
            name: onboardingUpload,
            builder: (context, state) {
              final authState = context.read<AuthBloc>().state;
              final candidateId = authState is Authenticated
                  ? (authState.user.candidateDetails?['id'] as int? ??
                      authState.user.selectedCandidateId ??
                      0)
                  : 0;
              return BlocProvider(
                create: (_) => di.sl<OnboardingBloc>(),
                child: CvUploadScreen(candidateId: candidateId),
              );
            },
          ),
          GoRoute(
            path: onboardingSuccessPath,
            name: onboardingSuccess,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return CvSuccessScreen(
                profileCompletion: extra?['profileCompletion'] as int? ?? 0,
              );
            },
          ),
          // Pre-Apply Analysis route
          GoRoute(
            path: preApplyAnalysisPath,
            name: preApplyAnalysis,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return PreApplyAnalysisScreen(
                jobSlug: extra?['jobSlug'] as String? ?? '',
                jobTitle: extra?['jobTitle'] as String? ?? '',
                coverLetter: extra?['coverLetter'] as String?,
                screeningResponses:
                    extra?['screeningResponses'] as Map<String, dynamic>?,
                cvOptimizationId: extra?['cvOptimizationId'] as int?,
              );
            },
          ),
        ],
        redirect: (context, state) {
          final authState = context.read<AuthBloc>().state;

          final isGoingToLogin = state.matchedLocation == loginPath;
          final isGoingToRegister = state.matchedLocation == registerPath;
          final isGoingToForgotPassword = state.matchedLocation == forgotPasswordPath;
          final isOnboarding = state.matchedLocation.startsWith('/onboarding');
          final isAuthenticated = authState is Authenticated;

          // Unauthenticated → login
          if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister && !isGoingToForgotPassword) {
            return loginPath;
          }

          // Authenticated on auth screens → redirect away
          if (authState is Authenticated && (isGoingToLogin || isGoingToRegister)) {
            final completion = authState.user.candidateDetails?['profile_completion'] as int? ?? 0;
            return completion <= 10 ? onboardingChoicePath : dashboardPath;
          }

          // Authenticated, heading to main app — check if onboarding is needed
          if (authState is Authenticated && !isOnboarding) {
            final completion = authState.user.candidateDetails?['profile_completion'] as int? ?? 0;
            // Profile completion of 10 is the default set on register — user hasn't set up yet
            if (completion <= 10 &&
                !isGoingToLogin &&
                !isGoingToRegister &&
                !isGoingToForgotPassword) {
              return onboardingChoicePath;
            }
          }

          return null;
        },
      );

  /// Get the tab index for a given path
  static int getTabIndex(String path) {
    if (path.startsWith(dashboardPath)) return dashboardTabIndex;
    if (path.startsWith(jobsPath)) return jobsTabIndex;
    if (path.startsWith(applicationsPath)) return applicationsTabIndex;
    if (path.startsWith(savedJobsPath)) return savedJobsTabIndex;
    if (path.startsWith(profilePath)) return profileTabIndex;
    // Resume edit routes are associated with the Profile tab
    if (path.startsWith(resumeEditPath)) return profileTabIndex;
    return dashboardTabIndex; // Default to dashboard
  }
}
