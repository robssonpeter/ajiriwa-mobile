import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection_container.dart';
import '../../../jobs/domain/entities/job_details.dart';
import '../../domain/entities/application_details.dart';
import '../bloc/application_details_bloc.dart';
import '../bloc/application_details_event.dart';
import '../bloc/application_details_state.dart';

/// Application details screen - displays application details and allows withdrawal
class ApplicationDetailsScreen extends StatefulWidget {
  /// Job details
  final JobDetails? jobDetails;

  /// Application ID
  final int? applicationId;

  /// Constructor
  const ApplicationDetailsScreen({
    Key? key,
    this.jobDetails,
    this.applicationId,
  }) : super(key: key);

  @override
  State<ApplicationDetailsScreen> createState() => _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ApplicationDetailsBloc>(
      create: (_) {
        final bloc = sl<ApplicationDetailsBloc>();
        if (widget.applicationId != null) {
          bloc.add(LoadApplicationDetailsEvent(widget.applicationId!));
        }
        return bloc;
      },
      child: BlocConsumer<ApplicationDetailsBloc, ApplicationDetailsState>(
        listener: (context, state) {
          if (state is ApplicationWithdrawn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Application withdrawn successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ApplicationDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Application Details'),
            ),
            body: _buildContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ApplicationDetailsState state) {
    if (state is ApplicationDetailsInitial || state is ApplicationDetailsLoading) {
      return _buildSkeletonLoader();
    } else if (state is ApplicationWithdrawing) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ApplicationDetailsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${state.message}',
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (widget.applicationId != null) {
                  context.read<ApplicationDetailsBloc>().add(
                    LoadApplicationDetailsEvent(widget.applicationId!),
                  );
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (state is ApplicationDetailsLoaded) {
      return _buildBody(context, state.applicationDetails);
    } else if (state is InterviewPrepLoading) {
      return _buildBody(context, state.applicationDetails);
    } else if (state is InterviewPrepLoaded) {
      return _buildBody(context, state.applicationDetails);
    } else if (state is InterviewPrepError) {
      return _buildBody(context, state.applicationDetails);
    }

    // Fallback
    return const Center(child: Text('Something went wrong'));
  }

  Widget _buildBody(BuildContext context, ApplicationDetails applicationDetails) {
    final state = context.watch<ApplicationDetailsBloc>().state;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job title
          Text(
            applicationDetails.job.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Company name and location
          Row(
            children: [
              _buildCompanyLogo(applicationDetails.job.company),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicationDetails.job.company.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      applicationDetails.job.company.name, // Using company name as location is not available
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Application status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Application Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusIcon(applicationDetails.status),
                      const SizedBox(width: 8),
                      Text(
                        applicationDetails.applicationStatus,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(applicationDetails.status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Application ID: ${applicationDetails.id}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Applied on: ${applicationDetails.applicationDateTime} (${applicationDetails.timeAgo})',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cover letter
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cover Letter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCoverLetterContent(applicationDetails.coverLetter),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Attached documents
          if (applicationDetails.attachments.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attached Documents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildDocumentsList(applicationDetails.attachments),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Screening questions and answers
          if (applicationDetails.screeningResponses.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Screening Questions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildScreeningQuestions(applicationDetails.screeningResponses),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Status history - only show if there are logs
          if (applicationDetails.logs.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Display current status as history item
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(top: 5, right: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  applicationDetails.applicationStatus,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${applicationDetails.applicationDateTime} (${applicationDetails.timeAgo})',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Interview schedule card
          if (applicationDetails.schedule != null)
            _buildInterviewCard(context, applicationDetails.schedule, state),
          const SizedBox(height: 16),

          // No employer notes in the API response
          const SizedBox(height: 24),

          // Withdraw button (only for Ajiriwa applications)
          if (applicationDetails.job.applied)
            SizedBox(
              width: double.infinity,
              height: 56.0,
              child: ElevatedButton(
                onPressed: state is ApplicationWithdrawing
                    ? null
                    : () => _showWithdrawConfirmation(context, applicationDetails.id),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.red,
                ),
                child: state is ApplicationWithdrawing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                            'Processing...',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      )
                    : const Text(
                        'Withdraw Application',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInterviewCard(
    BuildContext context,
    dynamic schedule,
    ApplicationDetailsState state,
  ) {
    final Map<String, dynamic> s =
        schedule is Map<String, dynamic> ? schedule : {};
    final typeLabels = {1: 'Face to Face', 2: 'Telephone', 3: 'Virtual'};
    final interviewType = typeLabels[s['interview_type']] ?? 'Interview';
    final date = s['date'] ?? '';
    final time = s['time'] ?? '';
    final venue = s['venue'];
    final meetingLink = s['meeting_link'];
    final scheduleId = s['id'] as int?;

    final isPrepLoading = state is InterviewPrepLoading;
    final prepData = state is InterviewPrepLoaded ? state.prepData : null;
    final prepError = state is InterviewPrepError ? state.message : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Interview Scheduled',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.category, interviewType),
            if (date.isNotEmpty) _buildInfoRow(Icons.calendar_today, '$date at $time'),
            if (venue != null && venue.toString().isNotEmpty)
              _buildInfoRow(Icons.location_on, venue.toString()),
            if (meetingLink != null && meetingLink.toString().isNotEmpty)
              _buildInfoRow(Icons.videocam, 'Virtual meeting link available'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'AI Interview Preparation',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            if (prepData != null) ...[
              _buildPrepSection('Preparation Tips', Icons.lightbulb_outline,
                  _toStringList(prepData['tips']), Colors.blue),
              const SizedBox(height: 12),
              _buildPrepSection('Likely Questions', Icons.help_outline,
                  _toStringList(prepData['likely_questions']), Colors.orange),
              const SizedBox(height: 12),
              _buildPrepSection('Questions to Ask', Icons.question_answer_outlined,
                  _toStringList(prepData['questions_to_ask']), Colors.green),
              const SizedBox(height: 12),
              if (scheduleId != null)
                TextButton.icon(
                  onPressed: isPrepLoading
                      ? null
                      : () => context.read<ApplicationDetailsBloc>().add(
                            GenerateInterviewPrepEvent(scheduleId, refresh: true),
                          ),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh Tips'),
                ),
            ] else if (prepError != null) ...[
              Text('Error: $prepError',
                  style: TextStyle(color: Colors.red.shade600)),
              const SizedBox(height: 8),
              if (scheduleId != null)
                ElevatedButton.icon(
                  onPressed: () => context.read<ApplicationDetailsBloc>().add(
                        GenerateInterviewPrepEvent(scheduleId),
                      ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
            ] else if (isPrepLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Generating personalised tips...'),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Get AI-powered tips, likely interview questions, and smart questions to ask the interviewer.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              if (scheduleId != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<ApplicationDetailsBloc>().add(
                          GenerateInterviewPrepEvent(scheduleId),
                        ),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Prep Tips'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPrepSection(
      String title, IconData icon, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: color, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ...items.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${e.key + 1}. ',
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.bold)),
                    Expanded(
                        child: Text(e.value,
                            style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  List<Widget> _buildDocumentsList(List<ApplicationAttachment> attachments) {
    return attachments.map<Widget>((attachment) {
      IconData iconData;
      switch (attachment.category) {
        case 1: // Resume
          iconData = Icons.description;
          break;
        case 3: // Certificate
          iconData = Icons.card_membership;
          break;
        case 2: // Portfolio
          iconData = Icons.work;
          break;
        default:
          iconData = Icons.insert_drive_file;
      }

      return ListTile(
        leading: Icon(iconData, color: Colors.blue),
        title: Text(attachment.name),
        subtitle: Text('${attachment.institution} • Completed ${attachment.completionDate}'),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: Colors.blue),
          onPressed: () async {
            final url = Uri.tryParse(attachment.mediaUrl);
            final canOpen = url != null && await canLaunchUrl(url);
            if (canOpen) {
              await launchUrl(url!, mode: LaunchMode.externalApplication);
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cannot open ${attachment.name}')),
              );
            }
          },
        ),
      );
    }).toList();
  }

  // Status history method removed as it's no longer used

  Widget _buildStatusIcon(int statusCode) {
    IconData iconData;
    Color color;

    switch (statusCode) {
      case 1: // Applied
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case 2: // Shortlisted
        iconData = Icons.star;
        color = Colors.orange;
        break;
      case 3: // Rejected
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      case 4: // Interview
        iconData = Icons.people;
        color = Colors.purple;
        break;
      case 5: // Hired
        iconData = Icons.work;
        color = Colors.blue;
        break;
      default:
        iconData = Icons.help;
        color = Colors.grey;
    }

    return Icon(
      iconData,
      color: color,
    );
  }

  Color _getStatusColor(int statusCode) {
    switch (statusCode) {
      case 1: // Applied
        return Colors.green;
      case 2: // Rejected
        return Colors.red;
      case 3: // shortlisted
        return Colors.orange;
      case 4: // Interview
        return Colors.purple;
      case 5: // Interviewed
        return Colors.blue;
      case 6: // Interviewed
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildScreeningQuestions(List<ScreeningResponse> screeningResponses) {
    return screeningResponses.map<Widget>((response) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              response.question,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              response.response,
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCompanyLogo(ApplicationCompany? company) {
    if (company == null) {
      // Display a placeholder if company is null
      return CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        radius: 24,
        child: const Text(
          '?',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final logoUrl = company.logoUrl;

    if (logoUrl.isEmpty) {
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
        onBackgroundImageError: (exception, stackTrace) {},
      );
    }
  }

  /// Builds the cover letter content widget based on whether the content is HTML or plain text
  Widget _buildCoverLetterContent(String content) {
    // Check if the content appears to be HTML
    bool isHtml = _isHtmlContent(content);

    if (isHtml) {
      // Render HTML content
      return Html(
        data: content,
        style: {
          "body": Style(
            fontSize: FontSize(16),
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          "p": Style(
            margin: Margins.only(bottom: 8),
          ),
        },
      );
    } else {
      // Render plain text with newlines converted to line breaks
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildTextWithLineBreaks(content),
      );
    }
  }

  /// Determines if the content is likely HTML
  bool _isHtmlContent(String content) {
    // Simple check for common HTML tags
    final htmlTagPattern = RegExp(r'<\s*\w+[^>]*>|<\s*/\s*\w+\s*>');
    return htmlTagPattern.hasMatch(content);
  }

  /// Builds a list of Text widgets with line breaks for plain text
  List<Widget> _buildTextWithLineBreaks(String text) {
    if (text.isEmpty) {
      return [const Text('')];
    }

    // Split the text by newlines
    final lines = text.split('\n');

    // Create a Text widget for each line
    return lines.map((line) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          line,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }).toList();
  }

  void _showWithdrawConfirmation(BuildContext context, int applicationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application'),
        content: const Text(
          'Are you sure you want to withdraw your application? This action cannot be undone.',
        ),
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
              context.read<ApplicationDetailsBloc>().add(
                WithdrawApplicationEvent(applicationId),
              );
            },
            child: const Text(
              'Withdraw',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a skeleton loading UI for application details
  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade400,
        highlightColor: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job title placeholder
            Container(
              width: 250,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 8),

            // Company name and location placeholder
            Row(
              children: [
                // Company logo placeholder
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company name placeholder
                      Container(
                        width: 150,
                        height: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      // Location placeholder
                      Container(
                        width: 120,
                        height: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Application status card placeholder
            Card(
              child: Container(
                width: double.infinity,
                height: 120,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status title placeholder
                    Container(
                      width: 150,
                      height: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    // Status row placeholder
                    Row(
                      children: [
                        // Status icon placeholder
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status text placeholder
                        Container(
                          width: 80,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Application ID placeholder
                    Container(
                      width: 200,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    // Applied date placeholder
                    Container(
                      width: 250,
                      height: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cover letter card placeholder
            Card(
              child: Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover letter title placeholder
                    Container(
                      width: 120,
                      height: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    // Cover letter content placeholder
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 200,
                            height: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Attached documents card placeholder
            Card(
              child: Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Documents title placeholder
                    Container(
                      width: 180,
                      height: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    // Document items placeholder
                    Expanded(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        itemBuilder: (context, index) => ListTile(
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.white,
                          ),
                          subtitle: Container(
                            width: 150,
                            height: 12,
                            color: Colors.white,
                            margin: const EdgeInsets.only(top: 4),
                          ),
                          trailing: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status history card placeholder
            Card(
              child: Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status history title placeholder
                    Container(
                      width: 150,
                      height: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    // Status history items placeholder
                    Expanded(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.only(top: 5, right: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 200,
                                      height: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      height: 14,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Employer notes card placeholder
            Card(
              child: Container(
                width: double.infinity,
                height: 120,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employer notes title placeholder
                    Container(
                      width: 150,
                      height: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    // Employer notes content placeholder
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Withdraw button placeholder
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
