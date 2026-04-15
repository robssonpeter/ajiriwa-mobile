import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/navigation/app_router.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit career screen - for editing career objective / personal summary
class ResumeEditCareerScreen extends StatefulWidget {
  /// Constructor
  const ResumeEditCareerScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditCareerScreen> createState() => _ResumeEditCareerScreenState();
}

class _ResumeEditCareerScreenState extends State<ResumeEditCareerScreen> {
  final TextEditingController _objectiveController = TextEditingController();
  int? _candidateId;
  bool _isSaving = false;
  bool _isLoadingSuggestions = false;
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResumeBloc>().add(const GetResumeSection(section: 'career'));
    });
  }

  @override
  void dispose() {
    _objectiveController.dispose();
    super.dispose();
  }

  void _save() async {
    setState(() => _isSaving = true);
    final text = _objectiveController.text;
    final career = Career(careerObjective: text);
    context.read<ResumeBloc>().add(UpdateCareer(career: career, candidateId: _candidateId));
  }

  Future<void> _fetchSuggestions() async {
    if (_candidateId == null) return;

    setState(() => _isLoadingSuggestions = true);

    try {
      final apiClient = sl<ApiClient>();
      final response = await apiClient.post('/ai/career-objective/templates', data: {
        'candidate_id': _candidateId,
      });

      if (response != null && response is List) {
        _showSuggestionsDialog(response);
      } else if (response != null && response['error'] != null) {
        _showError(response['error']);
      }
    } catch (e) {
      _showError('Failed to fetch suggestions: $e');
    } finally {
      setState(() => _isLoadingSuggestions = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuggestionsDialog(List suggestions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Professional Suggestions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Text(
                'Choose a template to use or refine.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: suggestions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    final template = suggestion['template'] as String;
                    final questions = suggestion['questions'] as List?;

                    return InkWell(
                      onTap: () {
                        if (questions == null || questions.isEmpty) {
                          _objectiveController.text = template;
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
                          _showQuestionsDialog(template, questions);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          template,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuestionsDialog(String template, List questions) {
    final List<TextEditingController> controllers = 
        questions.map((q) => TextEditingController()).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Refine Suggestion'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Provide a few more details to personalize this objective:'),
                const SizedBox(height: 16),
                ...List.generate(questions.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: controllers[index],
                      decoration: InputDecoration(
                        labelText: questions[index],
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final answers = controllers.map((c) => c.text).toList();
                Navigator.pop(context);
                _completeTemplate(template, answers);
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeTemplate(String template, List<String> answers) async {
    setState(() => _isLoadingSuggestions = true);
    try {
      final apiClient = sl<ApiClient>();
      final response = await apiClient.post('/ai/career-objective/complete', data: {
        'candidate_id': _candidateId,
        'template': template,
        'answers': answers,
      });

      if (response != null && response['final_template'] != null) {
        _objectiveController.text = response['final_template'];
      } else if (response != null && response['error'] != null) {
        _showError(response['error']);
      }
    } catch (e) {
      _showError('Failed to complete template: $e');
    } finally {
      setState(() => _isLoadingSuggestions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Profile Builder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(AppRouter.resumeEditPersonal),
        ),
        actions: [
          ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditCareer),
        ],
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          setState(() => _isSaving = false);
          if (state is ResumeSectionLoaded) {
            setState(() {
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
            });
            final career = state.response.data['career'] as Map<String, dynamic>?;
            final objective = career?['career_objective'] as String? ?? career?['objective'] as String? ?? '';
            setState(() => _currentText = objective);
            if (objective.isNotEmpty && _objectiveController.text.isEmpty) {
              _objectiveController.text = objective;
            }
          } else if (state is CareerUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Career objective saved!'),
                  ],
                ),
                backgroundColor: primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                duration: const Duration(seconds: 2),
              ),
            );
            context.goNamed(AppRouter.resumeEditExperience);
          } else if (state is ResumeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ResumeLoading && _currentText.isEmpty) {
            return const ResumeEditSkeleton();
          }

          return Column(
            children: [
              ResumeSectionProgressBar(currentScreen: AppRouter.resumeEditCareer),
              Expanded(
                child: ListView(
                  children: [
                    const ResumeSectionHeader(
                      title: 'Career Objective',
                      icon: Icons.flag_outlined,
                      subtitle: 'A brief summary of your professional goals',
                    ),

                    ResumeSectionCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Write a compelling summary that highlights your skills, experience, and career goals.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _isLoadingSuggestions ? null : _fetchSuggestions,
                                icon: _isLoadingSuggestions 
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.auto_awesome, size: 16),
                                label: const Text('Get Suggestions', style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(foregroundColor: primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _objectiveController,
                            maxLines: 10,
                            minLines: 8,
                            decoration: InputDecoration(
                              hintText: 'Write your career objective or personal summary here...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primary, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(_isSaving ? 'Saving...' : 'Save & Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),

                    ResumeNavButtons(
                      prevRoute: AppRouter.resumeEditPersonal,
                      nextRoute: AppRouter.resumeEditExperience,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
