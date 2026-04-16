import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/cover_letter_editor.dart';
import '../../domain/entities/job_apply_context.dart';
import '../../domain/entities/job_details.dart';
import '../../domain/entities/job_screening.dart';
import '../bloc/bloc.dart';
import '../../../../core/utils/app_logger.dart';
import 'pre_apply_analysis_screen.dart';

/// Apply screen - allows users to apply for a job
class ApplyScreen extends StatefulWidget {
  /// Job slug
  final String slug;

  /// Application method (ajiriwa, email)
  final String applicationMethod;

  /// Screening questions (for ajiriwa method)
  final JobScreening? screening;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const ApplyScreen({
    Key? key,
    required this.slug,
    required this.applicationMethod,
    this.screening,
    this.candidateId,
  }) : super(key: key);

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final GlobalKey<CoverLetterEditorState> _editorKey = GlobalKey<CoverLetterEditorState>();
  final List<Map<String, dynamic>> _selectedCertificates = [];
  final List<Map<String, dynamic>> _screeningAnswers = [];

  // Certificates from apply context
  List<Map<String, dynamic>> _certificates = [];

  // Job details from apply context
  JobDetails? _jobDetails;
  Candidate? _candidate;

  // State to track if the application was successfully sent (Requirement 2)
  bool _applicationSent = false;
  String? _applicationId;

  @override
  void initState() {
    super.initState();
    _initializeScreeningAnswers();
    _loadApplyContext();
  }

  void _initializeScreeningAnswers() {
    appLogger.d(widget.screening);
    if (widget.screening != null) {
      for (final question in widget.screening!.questions) {
        final answerMap = {
          'question_id': question.id,
          'answer_text': '',
          'answer_choice_id': null,
          'type': question.type,
        };

        if (question.answer != null && question.answer!.isNotEmpty &&
            (question.options == null || question.optionsDecoded == null || question.optionsDecoded!.isEmpty)) {
          answerMap['answer_text'] = question.answer;
        }

        _screeningAnswers.add(answerMap);
      }
    }
  }

  void _loadApplyContext() {
    // Load apply context data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplyBloc>().add(ApplyContextRequested(widget.slug, candidateId: widget.candidateId));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApplyBloc, ApplyState>(
      listener: (context, state) {
        if (state is ApplySuccess) {
          // Requirement 2: Set success state and application ID
          setState(() {
            _applicationSent = true;
            _applicationId = state.applicationId.toString();
          });
          // Note: No need for a dialog, the success screen replaces the body.
        } else if (state is ApplyFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
          // Restore form data if available
          _restoreFormData(state);
        } else if (state is ApplyContextLoaded) {
          setState(() {
            _jobDetails = state.applyContext.job;
            _candidate = state.applyContext.candidate;
            _certificates = state.applyContext.certificates.map((cert) => {
              'id': cert.code,
              'name': cert.label,
              'type': cert.label.toLowerCase().contains('resume') ? 'resume' : 'document',
            }).toList();
          });
        } else if (state is CoverLetterGenerationSuccess) {
          _editorKey.currentState?.animateSetHtml(state.content);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cover letter generated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CoverLetterGenerationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to generate cover letter: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Apply for Job'),
          ),
          body: _buildBody(context, state),
          // Only show bottom bar if not already sent
          bottomNavigationBar: _applicationSent || (state is ApplyContextLoaded && state.applyContext.applied) 
              ? null 
              : _buildBottomBar(context, state),
        );
      },
    );
  }

  void _restoreFormData(ApplyFailure state) {
    if (state.details != null) {
      if (state.details!.containsKey('screeningAnswers')) {
        final screeningAnswers = state.details!['screeningAnswers'] as List<Map<String, dynamic>>;
        if (screeningAnswers.length == _screeningAnswers.length) {
          setState(() {
            for (int i = 0; i < screeningAnswers.length; i++) {
              _screeningAnswers[i]['answer_text'] = screeningAnswers[i]['answer_text'];
              _screeningAnswers[i]['answer_choice_id'] = screeningAnswers[i]['answer_choice_id'];
            }
          });
        }
      }

      if (state.details!.containsKey('coverLetter') && state.details!['coverLetter'] != null) {
        _editorKey.currentState?.setHtml(state.details!['coverLetter'] as String);
      }

      if (state.details!.containsKey('attachments') && state.details!['attachments'] != null) {
        final attachments = state.details!['attachments'] as List<Map<String, dynamic>>;
        setState(() {
          _selectedCertificates.clear();
          for (final attachment in attachments) {
            final certificate = _certificates.firstWhere(
                  (cert) => cert['id'] == attachment['file_id'],
              orElse: () => Map<String, dynamic>.from(attachment),
            );
            _selectedCertificates.add(certificate);
          }
        });
      }
    }
  }

  Widget _buildBody(BuildContext context, ApplyState state) {
    if (_applicationSent) {
      // Requirement 2: Show success screen
      return _buildSuccessScreen(context);
    }

    // Check if user has already applied for this job
    if (state is ApplyContextLoaded && state.applyContext.applied) {
      return _buildAlreadyAppliedScreen(context, state.applyContext.application);
    }

    // Check if job is past its deadline or not active
    if (_jobDetails != null) {
      if (_jobDetails!.expired) {
        return _buildJobNotAvailableScreen(context, 'This job is past its deadline and no longer accepting applications.');
      }

      if (_jobDetails!.status != 1) {
        return _buildJobNotAvailableScreen(context, 'This job is no longer active and not accepting applications.');
      }
    }

    if (state is ApplySubmitting || (state is ApplyInitial && _jobDetails == null)) {
      // Requirement 3: Show skeleton loader while context loads
      return _buildSkeletonLoader();
    }

    // Main Form Content
    Widget formContent = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _jobDetails?.title ?? 'Job Title',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _jobDetails?.company.name ?? 'Company Name',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Screening questions (if any)
          if (widget.screening != null) ...[
            const Text(
              'Screening Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.screening!.questions.map((question) {
              final index = widget.screening!.questions.indexOf(question);
              return _buildScreeningQuestion(question, index);
            }).toList(),
            const SizedBox(height: 16),
          ],

          // Cover letter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cover Letter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state is CoverLetterGenerating)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton.icon(
                  onPressed: () => _generateAiCoverLetter(context),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(
                    (_editorKey.currentState?.getPlainText() ?? '').isEmpty
                        ? 'Write for me'
                        : 'Refine with AI',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          CoverLetterEditor(key: _editorKey),
          const SizedBox(height: 16),

          // Certificates
          const Text(
            'Certificates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select certificates to attach to your application:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ..._certificates.map((certificate) {
            final isSelected = _selectedCertificates.any((c) => c['id'] == certificate['id']);
            return CheckboxListTile(
              title: Text(certificate['name']),
              subtitle: Text(certificate['type']),
              value: isSelected,
              onChanged: (value) {
                if (state is! ApplySubmitting) { // Prevent changes while submitting
                  setState(() {
                    if (value == true) {
                      _selectedCertificates.add(certificate);
                    } else {
                      _selectedCertificates.removeWhere((c) => c['id'] == certificate['id']);
                    }
                  });
                }
              },
            );
          }).toList(),
        ],
      ),
    );

    // Requirement 1: Overlay loader when submitting
    return Stack(
      children: [
        // 1. The visible form content
        formContent,

        // 2. The overlay loader
        if (state is ApplySubmitting)
          Positioned.fill(
            child: Container(
              color: Colors.black54, // Semi-transparent overlay
              child: const Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Card(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Submitting Application...', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- Requirement 2: Success Screen ---
  Widget _buildSuccessScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Application Sent Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your application for ${_jobDetails?.title ?? "the job"} has been submitted.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement navigation to the main jobs list screen
                  Navigator.of(context).pop(); // Example: Pop this screen
                  context.read<ApplyBloc>().add(const ApplyReset()); // Reset state
                },
                icon: const Icon(Icons.search),
                label: const Text('Browse More Jobs'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  // TODO: Implement navigation to the user's application status/history screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigating to Application Status...')),
                  );
                },
                icon: const Icon(Icons.assignment),
                label: const Text('View Application Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Already Applied Screen ---
  Widget _buildAlreadyAppliedScreen(BuildContext context, JobApplication? application) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.blue,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'You Have Already Applied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You have already submitted an application for ${_jobDetails?.title ?? "this job"}.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (application != null) ...[
              const SizedBox(height: 16),
              Text(
                'Application ID: ${application.id}',
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${application.status}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Applied on: ${application.appliedAt}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // Pop this screen
                  context.read<ApplyBloc>().add(const ApplyReset()); // Reset state
                },
                icon: const Icon(Icons.search),
                label: const Text('Browse More Jobs'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  // TODO: Implement navigation to the user's application status/history screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigating to Application Status...')),
                  );
                },
                icon: const Icon(Icons.assignment),
                label: const Text('View Application Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Job Not Available Screen ---
  Widget _buildJobNotAvailableScreen(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Job Not Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // Pop this screen
                  context.read<ApplyBloc>().add(const ApplyReset()); // Reset state
                },
                icon: const Icon(Icons.search),
                label: const Text('Browse More Jobs'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Requirement 3: Skeleton Loader ---
  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job details card skeleton
          _buildShimmerItem(height: 80, isCard: true),
          const SizedBox(height: 16),
          // Screening questions title skeleton
          _buildShimmerItem(width: 200, height: 20),
          const SizedBox(height: 8),
          // Question 1 skeleton
          _buildShimmerItem(height: 100, isCard: true),
          // Question 2 skeleton
          _buildShimmerItem(height: 100, isCard: true),
          const SizedBox(height: 16),
          // Cover Letter title skeleton
          _buildShimmerItem(width: 150, height: 20),
          const SizedBox(height: 8),
          // Cover letter text field skeleton
          _buildShimmerItem(height: 120),
          const SizedBox(height: 16),
          // Certificates title skeleton
          _buildShimmerItem(width: 150, height: 20),
          const SizedBox(height: 8),
          // Certificate list item skeletons
          _buildShimmerItem(height: 50),
          _buildShimmerItem(height: 50),
        ],
      ),
    );
  }

  Widget _buildShimmerItem({required double height, double? width, bool isCard = false}) {
    // This is a simplified static placeholder for the skeleton effect.
    // For a true "shimmer" effect, you would typically use a package like 'shimmer'
    // or a custom animation, but this provides the required structural layout.
    final placeholder = Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(isCard ? 8.0 : 4.0),
      ),
    );

    return isCard ? Card(child: Padding(padding: const EdgeInsets.all(16.0), child: placeholder)) : placeholder;
  }

  // --- Form Building Helpers (Retained) ---

  Widget _buildScreeningQuestion(ScreeningQuestion question, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${question.question}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (question.description != null) ...[
              const SizedBox(height: 4),
              Text(
                question.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            _buildInputField(question, index),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(ScreeningQuestion question, int index) {
    // Check if the question has options, if so, display a selection input regardless of the inputType
    final isSubmitting = context.read<ApplyBloc>().state is ApplySubmitting;

    if (question.options != null && question.optionsDecoded!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: question.optionsDecoded!.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _screeningAnswers[index]['answer_text'],
            onChanged: isSubmitting ? null : (value) {
              setState(() {
                _screeningAnswers[index]['answer_text'] = value;
              });
            },
          );
        }).toList(),
      );
    }

    // If no options, determine the input type
    final inputType = question.inputType ?? 'text';

    switch (inputType) {
      case 'number':
        return TextField(
          enabled: !isSubmitting,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _screeningAnswers[index]['answer_text'] = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Enter a number',
            border: const OutlineInputBorder(),
          ),
        );

      case 'text':
      case null:
        return TextField(
          enabled: !isSubmitting,
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _screeningAnswers[index]['answer_text'] = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Enter your answer here...',
            border: OutlineInputBorder(),
          ),
        );

      case 'select':
        final options = question.optionsDecoded ?? [];
        if (options.isEmpty) {
          return const Text('No options available');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text("$option"),
              value: option,
              groupValue: _screeningAnswers[index]['answer_text'],
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _screeningAnswers[index]['answer_text'] = value;
                });
              },
            );
          }).toList(),
        );

      case 'date':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: isSubmitting ? null : () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );

                if (date != null) {
                  setState(() {
                    _screeningAnswers[index]['answer_text'] =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  });
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Pick a Date'),
            ),
            if (_screeningAnswers[index]['answer_text']?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                'Selected date: ${_screeningAnswers[index]['answer_text']}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        );

      case 'file':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: isSubmitting ? null : () {
                // TODO: Implement file picking
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File upload will be implemented in the future'),
                  ),
                );
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload File'),
            ),
            if (_screeningAnswers[index]['answer_text']?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                'Selected file: ${_screeningAnswers[index]['answer_text']}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        );

      default:
      // For multiple_choice and any other types
        if (question.choices != null && question.choices!.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: question.choices!.map((choice) {
              return RadioListTile<int>(
                title: Text(choice.text),
                value: choice.id,
                groupValue: _screeningAnswers[index]['answer_choice_id'],
                onChanged: isSubmitting ? null : (value) {
                  setState(() {
                    _screeningAnswers[index]['answer_choice_id'] = value;
                  });
                },
              );
            }).toList(),
          );
        } else {
          return TextField(
            enabled: !isSubmitting,
            onChanged: (value) {
              setState(() {
                _screeningAnswers[index]['answer_text'] = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Enter your answer here...',
              border: OutlineInputBorder(),
            ),
          );
        }
    }
  }

  Widget _buildBottomBar(BuildContext context, ApplyState state) {
    final isSubmitting = state is ApplySubmitting;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isSubmitting ? null : () => _openAnalysis(context),
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('Analyze My Application'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(color: Colors.deepPurple),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 56.0,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : () => _submitApplication(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Submit Application',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAnalysis(BuildContext context) {
    // Build a map of screening responses keyed by question ID
    final screeningMap = <String, dynamic>{};
    if (widget.screening != null) {
      for (int i = 0; i < widget.screening!.questions.length; i++) {
        final question = widget.screening!.questions[i];
        final answer = _screeningAnswers[i];
        final value = answer['answer_text']?.toString().isNotEmpty == true
            ? answer['answer_text']
            : answer['answer_choice_id']?.toString();
        if (value != null) {
          screeningMap[question.id.toString()] = value;
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreApplyAnalysisScreen(
          jobSlug: widget.slug,
          jobTitle: _jobDetails?.title ?? '',
          coverLetter: (_editorKey.currentState?.getPlainText() ?? '').isNotEmpty
              ? _editorKey.currentState?.getHtml()
              : null,
          screeningResponses: screeningMap.isNotEmpty ? screeningMap : null,
        ),
      ),
    );
  }

  void _submitApplication(BuildContext context) {
    // --- Validation Logic (Retained) ---
    if (widget.screening != null) {
      for (int i = 0; i < widget.screening!.questions.length; i++) {
        final question = widget.screening!.questions[i];
        final answer = _screeningAnswers[i];
        final inputType = question.inputType ?? 'text';

        if (question.necessity == 'required') {
          final hasOptions = question.options != null && question.optionsDecoded != null && question.optionsDecoded!.isNotEmpty;
          final isChoice = question.choices != null && question.choices!.isNotEmpty;

          if (hasOptions || inputType == 'select') {
            if (answer['answer_text'] == null || answer['answer_text'].isEmpty) {
              _showValidationError(context, 'Please select an option for question ${i + 1}');
              return;
            }
          } else if (isChoice) {
            if (answer['answer_choice_id'] == null) {
              _showValidationError(context, 'Please select an answer for question ${i + 1}');
              return;
            }
          } else {
            if (answer['answer_text'] == null || answer['answer_text'].isEmpty) {
              _showValidationError(context, 'Please answer question ${i + 1}');
              return;
            }
          }
        }

        // Validate number input
        if (inputType == 'number' && answer['answer_text'] != null && answer['answer_text'].isNotEmpty) {
          try {
            final userValue = double.parse(answer['answer_text']);

            if (question.questionType == 'minimum' && question.answer != null) {
              final minValue = double.parse(question.answer!);
              if (userValue < minValue) {
                _showValidationError(
                    context,
                    'The answer for question ${i + 1} must be at least ${question.answer}'
                );
                return;
              }
            }
          } catch (e) {
            _showValidationError(context, 'Please enter a valid number for question ${i + 1}');
            return;
          }
        }
      }
    }

    // Validate certificates
    if (_selectedCertificates.isEmpty) {
      _showValidationError(context, 'Please select at least one certificate');
      return;
    }

    final attachments = _selectedCertificates.map((certificate) {
      return {
        'file_id': certificate['id'],
        'type': certificate['type'],
      };
    }).toList();

    // Find the resume ID, defaulting to the first selected certificate if 'resume' type is not explicitly found
    final resumeId = _selectedCertificates.firstWhere(
          (c) => c['type'] == 'resume',
      orElse: () => _selectedCertificates.first,
    )['id'];

    // --- Submission Event ---
    if (widget.applicationMethod == 'ajiriwa') {
      context.read<ApplyBloc>().add(
        ApplySubmitted(
          jobId: _jobDetails?.id ?? 0,
          screeningAnswers: _screeningAnswers,
          resumeId: resumeId,
          coverLetter: _editorKey.currentState?.getHtml() ?? '',
          attachments: attachments,
          candidateId: widget.candidateId,
        ),
      );
    } else if (widget.applicationMethod == 'email') {
      final certificateNames = _selectedCertificates.map((c) => c['name']).join(', ');
      final notes = 'Cover Letter: ${_editorKey.currentState?.getPlainText() ?? ''}\n\nAttached Certificates: $certificateNames';

      context.read<ApplyBloc>().add(
        ApplyExternalIntentRecorded(
          jobId: _jobDetails?.id ?? 0,
          mode: 'email',
          notes: notes,
          candidateId: widget.candidateId,
        ),
      );
    }
  }

  void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _generateAiCoverLetter(BuildContext context) {
    if (_jobDetails == null) return;

    final currentHtml = _editorKey.currentState?.getHtml() ?? '';
    final startingPoint = (_editorKey.currentState?.getPlainText() ?? '').isNotEmpty ? currentHtml : null;

    if (startingPoint != null) {
      // Show refinement dialog
      _showRefinementDialog(context, startingPoint);
    } else {
      // Direct generation
      context.read<ApplyBloc>().add(
        CoverLetterGenerated(
          jobId: _jobDetails!.id,
          candidateId: widget.candidateId,
        ),
      );
    }
  }

  void _showRefinementDialog(BuildContext context, String startingPoint) {
    final TextEditingController refineController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refine with AI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tell AI how you want to refine your cover letter:'),
            const SizedBox(height: 12),
            TextField(
              controller: refineController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g., Make it more formal, emphasize my leadership skills, etc.',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final instructions = refineController.text.trim();
              Navigator.pop(context);
              this.context.read<ApplyBloc>().add(
                CoverLetterGenerated(
                  jobId: _jobDetails!.id,
                  startingPoint: startingPoint,
                  refineInstructions: instructions.isNotEmpty ? instructions : null,
                  candidateId: widget.candidateId,
                ),
              );
            },
            child: const Text('Refine'),
          ),
        ],
      ),
    );
  }
}
