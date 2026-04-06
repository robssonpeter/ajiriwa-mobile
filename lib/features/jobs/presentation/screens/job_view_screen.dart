import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_theme.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/job_details.dart';
import '../../domain/entities/job_screening.dart';
import '../../presentation/bloc/job_state.dart';
import '../../presentation/bloc/job_event.dart';
import '../bloc/bloc.dart';
import '../widgets/apply_button.dart';
import 'apply_screen.dart';
import 'web_view_screen.dart';

/// Job view screen - displays job details
class JobViewScreen extends StatelessWidget {
  /// Job slug
  final String slug;

  /// Constructor
  const JobViewScreen({
    Key? key,
    required this.slug,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load job details when the screen is built
    context.read<JobBloc>().add(LoadJobDetailsEvent(slug));

    return BlocProvider<ApplyBloc>(
      create: (_) => sl<ApplyBloc>(),
      child: BlocBuilder<JobBloc, JobState>(
        builder: (context, jobState) {
          return BlocConsumer<ApplyBloc, ApplyState>(
            listener: (context, applyState) {
              // Handle apply state changes
              if (applyState is ApplyFlowRequired) {
                _handleApplyFlow(context, applyState);
              } else if (applyState is ApplyFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${applyState.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, applyState) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Job Details'),
                ),
                body: _buildBody(context, jobState),
                // Show the apply button at the bottom of the screen when job details are loaded
                bottomNavigationBar: jobState is JobLoaded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildApplyButtonWithValidation(context, jobState.jobDetails),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => context.push(
                                  AppRouter.cvOptimizationPath,
                                  extra: {
                                    'jobId': jobState.jobDetails.id,
                                    'jobTitle': jobState.jobDetails.title,
                                    'companyName': jobState.jobDetails.company.name,
                                  },
                                ),
                                icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                                label: const Text('Optimize CV for this Job'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  side: const BorderSide(color: AppTheme.primaryColor),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, JobState state) {
    if (state is JobLoading) {
      return _buildSkeletonJobDetails(context);
    } else if (state is JobLoaded) {
      print(state);
      return _buildJobDetails(context, state.jobDetails);
    } else if (state is JobError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<JobBloc>().add(LoadJobDetailsEvent(slug));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      // Initial state, show skeleton loading
      return _buildSkeletonJobDetails(context);
    }
  }

  /// Build skeleton loading UI for job details
  Widget _buildSkeletonJobDetails(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade400,
        highlightColor: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company name and logo
            Row(
              children: [
                // Company logo placeholder
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company name placeholder
                      Container(
                        width: 200,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      // Location placeholder
                      Container(
                        width: 150,
                        height: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Job details card placeholder
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job type row
                    _buildSkeletonDetailRow(),
                    // Deadline row
                    _buildSkeletonDetailRow(),
                    // Salary row (optional)
                    _buildSkeletonDetailRow(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Job description title placeholder
            Container(
              width: 150,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 8),

            // Job description content placeholder - multiple paragraph lines
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Paragraph 1
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),

                  // Paragraph 2
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),

                  // Bullet points
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4, right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4, right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4, right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Paragraph 3
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build skeleton detail row for job details card
  Widget _buildSkeletonDetailRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label placeholder
          Container(
            width: 100,
            height: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          // Value placeholder
          Expanded(
            child: Container(
              height: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetails(BuildContext context, JobDetails jobDetails) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job title
          /*Text(
            jobDetails.title,
            style: const TextStyle(
              fontSize: 28, // Increased from 24
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),*/

          // Company name and location
          Row(
            children: [
              _buildCompanyLogo(jobDetails.company),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobDetails.company.name,
                      style: const TextStyle(
                        fontSize: 20, // Increased from 16
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      jobDetails.location,
                      style: TextStyle(
                        fontSize: 16, // Added font size
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),/**/
            ],
          ),
          const SizedBox(height: 16),

          // Job details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //_buildDetailRow('Location', jobDetails.location),
                  _buildDetailRow('Job Type', jobDetails.type.name),
                  _buildDetailRow('Deadline', jobDetails.deadline),
                  //_buildDetailRow('Deadline', jobDetails.applyMethod),
                  if (jobDetails.minSalary != null || jobDetails.maxSalary != null)
                    _buildDetailRow(
                      'Salary',
                      _formatSalary(jobDetails.minSalary, jobDetails.maxSalary),
                    ),
                  //_buildDetailRow('Required Education', jobDetails.requiredEducation ?? 'Not specified'),
                  //_buildDetailRow('Skills', jobDetails.skills),
                ],
              ),
            ),
          ),
          //const SizedBox(height: 16),

          // Job description
          const Text(
            'Job Description',
            style: TextStyle(
              fontSize: 24, // Increased from 18
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Use flutter_html to render HTML content
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Html(
              data: jobDetails.description,
              onLinkTap: (String? url, Map<String, String> attributes, dom.Element? element) {
                if (url != null) {
                  _launchUrl(url);
                }
              },
              style: {
                "body": Style(
                  fontSize: FontSize(18.0), // 1.5x from 14.0
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "h1": Style(
                  fontSize: FontSize(25.0), // 1.5x from 20.0
                  fontWeight: FontWeight.bold,
                ),
                "h2": Style(
                  fontSize: FontSize(23.0), // 1.5x from 18.0
                  fontWeight: FontWeight.bold,
                ),
                "p": Style(
                  margin: Margins.only(bottom: 20), // Increased for better spacing
                  fontSize: FontSize(18.0), // 1.5x from 14.0
                ),
                "ul": Style(
                  margin: Margins.only(bottom: 20), // Increased for better spacing
                ),
                "li": Style(
                  margin: Margins.only(bottom: 10), // Increased for better spacing
                  fontSize: FontSize(18.0), // 1.5x from 14.0
                ),
              },
            ),
          ),
          const SizedBox(height: 24),

          // Padding at the bottom to ensure content isn't hidden behind the fixed apply button
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // Increased padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, // Increased width for labels
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0, // Increased font size
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16.0, // Increased font size
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSalary(int? minSalary, int? maxSalary) {
    if (minSalary != null && maxSalary != null) {
      return '$minSalary - $maxSalary';
    } else if (minSalary != null) {
      return 'From $minSalary';
    } else if (maxSalary != null) {
      return 'Up to $maxSalary';
    } else {
      return 'Not specified';
    }
  }

  Widget _buildCompanyLogo(CompanyDetails company) {
    final logoUrl = company.logoUrl ?? company.logo;

    if (logoUrl == null) {
      // Display a placeholder if no logo URL is available
      return CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        radius: 24,
        child: Text(
          company.name.isNotEmpty ? company.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // Display the company logo
      return CircleAvatar(
        backgroundColor: Colors.white,
        radius: 24,
        backgroundImage: NetworkImage(logoUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // Handle image loading errors
          print('Error loading company logo: $exception');
        },
      );
    }
  }

  /// Launches a URL in an in-app webview
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      )) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Show a snackbar or dialog to inform the user that the URL could not be launched
    }
  }

  /// Handle different apply flows based on the state
  void _handleApplyFlow(BuildContext context, ApplyFlowRequired state) {
    print('_handleApplyFlow called with state mode: ${state.mode}');

    final jobId = context.read<JobBloc>().state is JobLoaded
        ? (context.read<JobBloc>().state as JobLoaded).jobDetails.id
        : 0;

    print('JobId: $jobId');

    if (jobId == 0) {
      print('Error: Job details not loaded');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Job details not loaded'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("the state variable is right below here");
    print(state);

    switch (state.mode) {
      case 'ajiriwa':
        print('Calling _showAjiriwaApplyFlow');
        _showAjiriwaApplyFlow(context, jobId, state.screening);
        break;
      case 'external_url':
        print('Calling _showExternalUrlApplyFlow');
        _showExternalUrlApplyFlow(context, jobId);
        break;
      case 'instructions':
        print('Calling _showInstructionsApplyFlow');
        _showInstructionsApplyFlow(context, jobId);
        break;
      case 'email':
        print('Calling _showEmailApplyFlow');
        _showEmailApplyFlow(context, jobId);
        break;
      default:
        print('Unknown apply mode: ${state.mode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unknown apply mode: ${state.mode}'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  /// Show Ajiriwa in-app application flow
  void _showAjiriwaApplyFlow(BuildContext context, int jobId, JobScreening? screening) {
    // We don't need to check if screening is null anymore
    // The screening questions will be loaded in the ApplyScreen if needed

    final jobDetails = context.read<JobBloc>().state is JobLoaded
        ? (context.read<JobBloc>().state as JobLoaded).jobDetails
        : null;

    if (jobDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Job details not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Capture the ApplyBloc instance before navigating
    final applyBloc = BlocProvider.of<ApplyBloc>(context);

    // Get the selected candidate ID if available
    int? selectedCandidateId;
    final applyState = applyBloc.state;
    if (applyState is CandidatesLoaded) {
      selectedCandidateId = applyState.selectedCandidateId;
    }

    // Navigate to the Apply screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: applyBloc,
          child: ApplyScreen(
            slug: jobDetails.slug,
            applicationMethod: 'ajiriwa',
            screening: screening,
            candidateId: selectedCandidateId,
          ),
        ),
      ),
    );
  }

  /// Show external URL application flow
  void _showExternalUrlApplyFlow(BuildContext context, int jobId) {
    print('_showExternalUrlApplyFlow called with jobId: $jobId');

    final jobDetails = context.read<JobBloc>().state is JobLoaded
        ? (context.read<JobBloc>().state as JobLoaded).jobDetails
        : null;

    print('JobDetails: $jobDetails');
    print('ApplicationUrl: ${jobDetails?.applicationUrl}');
    print('ApplyMethod: ${jobDetails?.applyMethod}');

    if (jobDetails == null || jobDetails.applicationUrl == null) {
      print('Error: Application URL not available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Application URL not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get the ApplyBloc
    final applyBloc = context.read<ApplyBloc>();

    // Get the selected candidate ID if available
    int? selectedCandidateId;
    final applyState = applyBloc.state;
    if (applyState is CandidatesLoaded) {
      selectedCandidateId = applyState.selectedCandidateId;
    }

    // Record external click before opening URL
    print('Recording external click');
    applyBloc.add(ApplyExternalClickRecorded(jobId, candidateId: selectedCandidateId));

    // Record apply intent and navigate directly to WebViewScreen
    print('Recording apply intent');
    applyBloc.add(
      ApplyExternalIntentRecorded(
        jobId: jobId,
        mode: 'external_url',
        candidateId: selectedCandidateId,
      ),
    );

    // Navigate to WebViewScreen with jobId
    // We'll pass the applicationId as null for now, and the WebViewScreen will handle it
    print('Navigating to WebViewScreen with URL: ${jobDetails.applicationUrl!}');
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: applyBloc, // Pass the same ApplyBloc instance
            child: WebViewScreen(
              url: jobDetails.applicationUrl!,
              title: 'Job Application',
              jobId: jobId,
              applicationId: null, // We don't have the applicationId yet
            ),
          ),
        ),
      );
      print('Navigation to WebViewScreen completed');
    } catch (e) {
      print('Error navigating to WebViewScreen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show instructions-based application flow
  void _showInstructionsApplyFlow(BuildContext context, int jobId) {
    final jobDetails = context.read<JobBloc>().state is JobLoaded
        ? (context.read<JobBloc>().state as JobLoaded).jobDetails
        : null;

    if (jobDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Job details not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show a bottom sheet with instructions
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Application Instructions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Show job description as instructions
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5, // Limit height to 50% of screen
              ),
              child: SingleChildScrollView(
                child: Html(
                  data: jobDetails.description,
                  onLinkTap: (String? url, Map<String, String> attributes, dom.Element? element) {
                    if (url != null) {
                      _launchUrl(url);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Get the ApplyBloc
                final applyBloc = context.read<ApplyBloc>();

                // Get the selected candidate ID if available
                int? selectedCandidateId;
                final applyState = applyBloc.state;
                if (applyState is CandidatesLoaded) {
                  selectedCandidateId = applyState.selectedCandidateId;
                }

                // Record apply intent
                applyBloc.add(
                  ApplyExternalIntentRecorded(
                    jobId: jobId,
                    mode: 'instructions',
                    notes: 'Applied via instructions',
                    candidateId: selectedCandidateId,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('I followed the instructions'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build apply button with validation
  Widget _buildApplyButtonWithValidation(BuildContext context, JobDetails jobDetails) {
    // Validate job details
    if (jobDetails.id <= 0) {
      // Invalid job ID, show error button
      return SizedBox(
        width: double.infinity,
        height: 56.0,
        child: ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            backgroundColor: Colors.grey.shade300,
          ),
          child: const Text(
            'Error: Invalid Job ID',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    // Job details are valid, use the ApplyButton widget
    return ApplyButton(jobDetails: jobDetails);
  }

  /// Show email application flow
  void _showEmailApplyFlow(BuildContext context, int jobId) {
    final jobDetails = context.read<JobBloc>().state is JobLoaded
        ? (context.read<JobBloc>().state as JobLoaded).jobDetails
        : null;

    if (jobDetails == null || jobDetails.applicationEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Application email not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Capture the ApplyBloc instance before navigating
    final applyBloc = BlocProvider.of<ApplyBloc>(context);

    // Get the selected candidate ID if available
    int? selectedCandidateId;
    final applyState = applyBloc.state;
    if (applyState is CandidatesLoaded) {
      selectedCandidateId = applyState.selectedCandidateId;
    }

    // Navigate directly to the Apply screen without showing a dialog
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: applyBloc,
          child: ApplyScreen(
            slug: jobDetails.slug,
            applicationMethod: 'email',
            screening: null, // No screening questions for email applications
            candidateId: selectedCandidateId,
          ),
        ),
      ),
    );
  }

  /// Show success dialog after successful application
  void _showSuccessDialog(BuildContext context, ApplySuccess state) {
    // Capture the ApplyBloc instance before showing the dialog
    final applyBloc = BlocProvider.of<ApplyBloc>(context);
    // Capture the JobBloc instance to refresh job details
    final jobBloc = BlocProvider.of<JobBloc>(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Application Submitted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your application has been submitted successfully.'),
            const SizedBox(height: 8),
            Text('Application ID: ${state.applicationId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Reset the apply state using the captured bloc instance
              applyBloc.add(const ApplyReset());

              // If this is an Ajiriwa application, refresh the job details to update the applied status
              if (state.mode == 'ajiriwa') {
                // Get the current job slug from the JobBloc state
                final currentState = jobBloc.state;
                if (currentState is JobLoaded) {
                  // Reload job details to update the applied status
                  jobBloc.add(LoadJobDetailsEvent(currentState.jobDetails.slug));
                }
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
