import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit career screen - for editing career information
class ResumeEditCareerScreen extends StatefulWidget {
  /// Constructor
  const ResumeEditCareerScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditCareerScreen> createState() => _ResumeEditCareerScreenState();
}

class _ResumeEditCareerScreenState extends State<ResumeEditCareerScreen> {
  // HTML Editor controller
  final HtmlEditorController _htmlController = HtmlEditorController();

  // Profile completion percentage
  int _profileCompletion = 0;

  // Candidate ID
  int? _candidateId;

  // Career objective
  String? _careerObjective;

  @override
  void initState() {
    super.initState();
    // Fetch career information when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResumeBloc>().add(const GetResumeSection(section: 'career'));

      // Ensure the HTML editor is initialized before setting text
      Future.delayed(const Duration(milliseconds: 500), () {
        print("In initState delayed callback, career objective: $_careerObjective");
        if (_careerObjective != null && _careerObjective!.isNotEmpty) {
          print("Setting text in editor from initState");
          _htmlController.setText(_careerObjective!);
          print("Text set in editor from initState");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("In build method, career objective: $_careerObjective");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Information'),
        actions: [
          // Keep the next button
          TextButton(
            onPressed: () {
              // Navigate to next section (experience)
              context.goNamed(AppRouter.resumeEditExperience);
            },
            child: const Row(
              children: [
                Text('Next', style: TextStyle(color: Colors.white)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ),
          // Add navigation menu (at the far right)
          ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditCareer),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to previous section (personal)
            context.goNamed(AppRouter.resumeEditPersonal);
          },
        ),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            // Update profile completion and candidate ID
            setState(() {
              _profileCompletion = state.response.data['profile_completion'] as int? ?? 0;
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
            });

            // Get personal information from response
            final personal = state.response.data['personal'] as Map<String, dynamic>?;
            if (personal != null && personal.containsKey('career_objective')) {
              // Update career objective from personal section
              setState(() {
                _careerObjective = personal['career_objective'] as String? ?? '';
              });

              // Set the HTML content in the editor with a delay to ensure the editor is ready
              if (_careerObjective != null && _careerObjective!.isNotEmpty) {
                print("Career objective from personal section: $_careerObjective");
                Future.delayed(const Duration(milliseconds: 500), () {
                  print("Setting text in editor from personal section");
                  _htmlController.setText(_careerObjective!);
                  print("Text set in editor from personal section");
                });
              }
            } else {
              // Try to get career objective from other locations in the response
              // Check if it's directly in the data section
              if (state.response.data.containsKey('career_objective')) {
                setState(() {
                  _careerObjective = state.response.data['career_objective'] as String? ?? '';
                });

                if (_careerObjective != null && _careerObjective!.isNotEmpty) {
                  print("Career objective from data section: $_careerObjective");
                  Future.delayed(const Duration(milliseconds: 500), () {
                    print("Setting text in editor from data section");
                    _htmlController.setText(_careerObjective!);
                    print("Text set in editor from data section");
                  });
                }
              }
            }
          } else if (state is CareerUpdated) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Career information updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Navigate to next section
            context.goNamed(AppRouter.resumeEditExperience);
          } else if (state is ResumeError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          // Show loading indicator while fetching data
          if (state is ResumeLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show form
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile completion indicator
                LinearProgressIndicator(value: _profileCompletion / 100),
                const SizedBox(height: 8),
                Text('$_profileCompletion% Complete', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                // Career information form
                const Text(
                  'Career Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Career objective editor
                const Text(
                  'Career Objective:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                HtmlEditor(
                  controller: _htmlController,
                  htmlEditorOptions: const HtmlEditorOptions(
                    hint: 'Enter your career objective here...',
                    shouldEnsureVisible: true,
                  ),
                  htmlToolbarOptions: const HtmlToolbarOptions(
                    toolbarPosition: ToolbarPosition.aboveEditor,
                    defaultToolbarButtons: [
                      StyleButtons(),
                      FontSettingButtons(),
                      FontButtons(),
                      ColorButtons(),
                      ListButtons(),
                      ParagraphButtons(),
                      InsertButtons(link: true),
                      OtherButtons(codeview: false),
                    ],
                  ),
                  otherOptions: const OtherOptions(
                    height: 300,
                  ),
                  callbacks: Callbacks(
                    onInit: () {
                      print("HtmlEditor initialized");
                      if (_careerObjective != null && _careerObjective!.isNotEmpty) {
                        print("Setting text in editor from onInit callback");
                        _htmlController.setText(_careerObjective!);
                        print("Text set in editor from onInit callback");
                      }
                    },
                    onChangeContent: (String? changed) {
                      print("HtmlEditor content changed: $changed");
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Navigation buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Go back to previous section
                          context.goNamed(AppRouter.resumeEditPersonal);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('Previous'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Get the HTML content from the editor
                          final htmlContent = await _htmlController.getText();

                          // Create career entity with the updated career objective
                          final career = Career(
                            careerObjective: htmlContent,
                          );

                          // Dispatch update event
                          context.read<ResumeBloc>().add(UpdateCareer(
                            career: career,
                            candidateId: _candidateId,
                          ));
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('Save & Continue'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
