import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/job_details.dart';
import '../bloc/bloc.dart';
import '../../../applications/presentation/screens/application_details_screen.dart';

/// Apply button widget
class ApplyButton extends StatelessWidget {
  /// Job details
  final JobDetails jobDetails;

  /// Constructor
  const ApplyButton({
    Key? key,
    required this.jobDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplyBloc, ApplyState>(
      builder: (context, state) {
        // If the job is already applied, show "Already Applied" button
        if (jobDetails.applied) {
          return _buildAlreadyAppliedButton(context);
        }

        // If the job has expired or past deadline, show "Closed" button
        if (jobDetails.expired) {
          return _buildClosedButton(context);
        }

        // Handle different apply states
        if (state is ApplyCheckingEligibility) {
          return _buildLoadingButton(context);
        } else if (state is ApplyEligibilityReady) {
          return _buildEligibilityButton(context, state);
        } else if (state is ApplySubmitting) {
          return _buildSubmittingButton(context);
        } else if (state is ApplyFailure) {
          return _buildFailureButton(context, state);
        } else {
          // Default "Apply Now" button
          return _buildApplyNowButton(context);
        }
      },
    );
  }

  /// Build "Already Applied" button
  Widget _buildAlreadyAppliedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to application details screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ApplicationDetailsScreen(
                jobDetails: jobDetails,
                applicationId: jobDetails.id,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: Colors.blue.shade100,
        ),
        child: const Text(
          'View Application',
          style: TextStyle(fontSize: 18, color: Colors.blue),
        ),
      ),
    );
  }

  /// Build "Closed" button
  Widget _buildClosedButton(BuildContext context) {
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
          'Closed',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }

  /// Build loading button
  Widget _buildLoadingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: ElevatedButton(
        onPressed: null, // Disabled while loading
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Checking Eligibility',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  /// Build eligibility button
  Widget _buildEligibilityButton(BuildContext context, ApplyEligibilityReady state) {
    if (state.eligible) {
      return _buildApplyNowButton(context);
    } else {
      // Not eligible, show "Complete Profile to Apply" button
      final percentage = state.details.profileCompletion.percentage;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56.0,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to profile completion wizard
                // TODO: Implement navigation to profile completion wizard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile completion wizard will be implemented in the future'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.amber,
              ),
              child: Text(
                'Complete Profile to Apply',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade800),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your profile is $percentage% complete',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }

  /// Build submitting button
  Widget _buildSubmittingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: ElevatedButton(
        onPressed: null, // Disabled while submitting
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Submitting Application',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  /// Build failure button
  Widget _buildFailureButton(BuildContext context, ApplyFailure state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          height: 56.0,
          child: ElevatedButton(
            onPressed: () {
              // Get the ApplyBloc
              final applyBloc = context.read<ApplyBloc>();

              // Get the selected candidate ID if available
              int? selectedCandidateId;
              final applyState = applyBloc.state;
              if (applyState is CandidatesLoaded) {
                selectedCandidateId = applyState.selectedCandidateId;
              }

              // Retry eligibility check
              applyBloc.add(ApplyEligibilityRequested(jobDetails.id, candidateId: selectedCandidateId));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state.message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Build "Apply Now" button
  Widget _buildApplyNowButton(BuildContext context) {
    // Check if the user is authenticated
    final token = sl<ApiClient>().getToken();

    // Print job details for debugging
    print('ApplyButton._buildApplyNowButton - Job ID: ${jobDetails.id}');
    print('ApplyButton._buildApplyNowButton - Job Title: ${jobDetails.title}');
    print('ApplyButton._buildApplyNowButton - Job Slug: ${jobDetails.slug}');

    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: ElevatedButton(
        onPressed: () async {
          // Check if the user is authenticated
          final tokenValue = await token;
          final isAuthenticated = tokenValue != null && tokenValue.isNotEmpty;

          if (!isAuthenticated) {
            // Show login dialog
            _showLoginDialog(context);
            return;
          }

          // Validate job ID
          if (jobDetails.id <= 0) {
            print('ApplyButton._buildApplyNowButton - Invalid job ID: ${jobDetails.id}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid job ID: ${jobDetails.id}'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          print('ApplyButton._buildApplyNowButton - Checking eligibility for job ID: ${jobDetails.id}');

          // Get the ApplyBloc
          final applyBloc = context.read<ApplyBloc>();

          // Get the selected candidate ID if available
          int? selectedCandidateId;
          final applyState = applyBloc.state;
          if (applyState is CandidatesLoaded) {
            selectedCandidateId = applyState.selectedCandidateId;
          }

          // Check eligibility
          applyBloc.add(ApplyEligibilityRequested(jobDetails.id, candidateId: selectedCandidateId));
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: const Text(
          'Apply Now',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  /// Show login dialog
  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to be logged in to apply for this job.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen
              // TODO: Implement navigation to login screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Navigation to login screen will be implemented in the future'),
                ),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
