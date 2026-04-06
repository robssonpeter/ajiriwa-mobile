import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import '../../../../../core/navigation/app_router.dart';
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
  final HtmlEditorController _htmlController = HtmlEditorController();
  int? _candidateId;
  bool _isSaving = false;
  String _currentHtml = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResumeBloc>().add(const GetResumeSection(section: 'career'));
    });
  }

  void _save() async {
    setState(() => _isSaving = true);
    final html = await _htmlController.getText();
    final career = Career(careerObjective: html);
    context.read<ResumeBloc>().add(UpdateCareer(career: career, candidateId: _candidateId));
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
            setState(() => _currentHtml = objective);
            if (objective.isNotEmpty) {
              _htmlController.setText(objective);
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
          if (state is ResumeLoading && _currentHtml.isEmpty) {
            return const Center(child: CircularProgressIndicator());
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
                          Text(
                            'Write a compelling summary that highlights your skills, experience, and career goals. This is often the first thing employers read.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 250),
                              child: HtmlEditor(
                                controller: _htmlController,
                                htmlEditorOptions: const HtmlEditorOptions(
                                  hint: 'Write your career objective or personal summary here...',
                                  shouldEnsureVisible: true,
                                  autoAdjustHeight: true,
                                  adjustHeightForKeyboard: true,
                                ),
                                htmlToolbarOptions: HtmlToolbarOptions(
                                  toolbarPosition: ToolbarPosition.aboveEditor,
                                  toolbarType: ToolbarType.nativeScrollable,
                                  defaultToolbarButtons: [
                                    const StyleButtons(),
                                    const FontSettingButtons(fontSizeUnit: false),
                                    const ListButtons(listStyles: false),
                                    const ParagraphButtons(
                                      textDirection: false,
                                      lineHeight: false,
                                      caseConverter: false,
                                    ),
                                  ],
                                ),
                                callbacks: Callbacks(
                                  onChangeContent: (changed) {
                                    if (changed != null) setState(() => _currentHtml = changed);
                                  },
                                ),
                              ),
                            ),
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
