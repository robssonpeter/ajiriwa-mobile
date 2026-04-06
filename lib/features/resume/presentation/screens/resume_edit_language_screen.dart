import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit language screen - for editing language proficiency
class ResumeEditLanguageScreen extends StatefulWidget {
  /// Constructor
  const ResumeEditLanguageScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditLanguageScreen> createState() => _ResumeEditLanguageScreenState();
}

class _ResumeEditLanguageScreenState extends State<ResumeEditLanguageScreen> {
  // Profile completion percentage
  int _profileCompletion = 0;

  // Candidate ID
  int? _candidateId;

  // List of languages
  List<Language> _languages = [];

  // Map of language levels
  Map<String, String> _languageLevels = {};

  // Resume bloc instance
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    // Initialize the resumeBloc
    resumeBloc = context.read<ResumeBloc>();
    // Fetch language information when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'language'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Languages'),
        actions: [
          // Keep the next button
          TextButton(
            onPressed: () {
              // Navigate to next section (skills)
              context.goNamed(AppRouter.resumeEditSkills);
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
          ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditLanguage),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to previous section (education)
            context.goNamed(AppRouter.resumeEditEducation);
          },
        ),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            // Update profile completion, candidate ID, language levels
            setState(() {
              _profileCompletion = state.response.data['profile_completion'] as int? ?? 0;
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;

              // Get language levels from response
              final languageLevelsData = state.response.data['language_levels'] as Map<String, dynamic>?;
              if (languageLevelsData != null) {
                _languageLevels = languageLevelsData.map((key, value) => MapEntry(key, value as String));
              }

              // Get language list from response
              final languageList = state.response.data['languages'] as List<dynamic>?;
              if (languageList != null) {
                _languages = languageList.map((e) {
                  final lang = e as Map<String, dynamic>;
                  return Language(
                    id: lang['id'] as int?,
                    name: lang['name'] as String? ?? '',
                    listening: lang['listening'] != null ? (lang['listening'] is int ? lang['listening'] as int : (lang['listening'] as double).round()) : null,
                    speaking: lang['speaking'] != null ? (lang['speaking'] is int ? lang['speaking'] as int : (lang['speaking'] as double).round()) : null,
                    reading: lang['reading'] != null ? (lang['reading'] is int ? lang['reading'] as int : (lang['reading'] as double).round()) : null,
                    writing: lang['writing'] != null ? (lang['writing'] is int ? lang['writing'] as int : (lang['writing'] as double).round()) : null,
                    rating: lang['rating'] != null ? (lang['rating'] is int ? lang['rating'] as int : (lang['rating'] as double).round()) : null,
                    ratingLabel: lang['rating_label'] as String?,
                  );
                }).toList();
              } else {
                _languages = [];
              }
            });
          } else if (state is LanguageAdded) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Language added successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the language list
            resumeBloc.add(const GetResumeSection(section: 'language'));
          } else if (state is LanguageUpdated) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Language updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the language list
            resumeBloc.add(const GetResumeSection(section: 'language'));
          } else if (state is LanguageDeleted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Language deleted successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the language list
            resumeBloc.add(const GetResumeSection(section: 'language'));
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
          // Show loading indicator only when initially loading the section
          // Not when adding, updating, or deleting languages
          if (state is ResumeLoading && _languages.isEmpty) {
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

                // Language list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Languages',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 100, // Fixed width to avoid infinite constraints
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Show add language dialog/screen
                          _showAddLanguageDialog(context);
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Language list
                if (_languages.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No languages added yet. Click the "Add" button to add your languages.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final language = _languages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      language.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () {
                                          _showEditLanguageDialog(context, language);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(context, language);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                language.ratingLabel ?? 'Proficiency: ${language.rating ?? 0}/5',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildProficiencyItem('Listening', language.listening ?? 0),
                                  _buildProficiencyItem('Speaking', language.speaking ?? 0),
                                  _buildProficiencyItem('Reading', language.reading ?? 0),
                                  _buildProficiencyItem('Writing', language.writing ?? 0),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Go back to previous section
                          context.goNamed(AppRouter.resumeEditEducation);
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
                        onPressed: () {
                          // Save and navigate to next section
                          context.goNamed(AppRouter.resumeEditSkills);
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

  Widget _buildProficiencyItem(String label, int level) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              Icons.star,
              size: 16,
              color: index < level ? Colors.amber : Colors.grey.shade300,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddLanguageDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    int _listening = 3;
    int _speaking = 3;
    int _reading = 3;
    int _writing = 3;
    bool _isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is LanguageAdded) {
                // Close dialog when language is added
                Navigator.of(dialogContext).pop();
              } else if (state is ResumeError) {
                // Update saving state
                setState(() {
                  _isSaving = false;
                });
              }
            },
            child: StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Add Language'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Language Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Language *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter language name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Proficiency Sliders
                        const Text(
                          'Proficiency Levels',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Listening
                        _buildProficiencySlider(
                          'Listening',
                          _listening,
                          (value) {
                            setState(() {
                              _listening = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),

                        // Speaking
                        _buildProficiencySlider(
                          'Speaking',
                          _speaking,
                          (value) {
                            setState(() {
                              _speaking = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),

                        // Reading
                        _buildProficiencySlider(
                          'Reading',
                          _reading,
                          (value) {
                            setState(() {
                              _reading = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),

                        // Writing
                        _buildProficiencySlider(
                          'Writing',
                          _writing,
                          (value) {
                            setState(() {
                              _writing = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: _isSaving
                        ? null // Disable cancel button while saving
                        : () {
                            Navigator.of(dialogContext).pop();
                          },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: _isSaving
                        ? null // Disable save button while saving
                        : () {
                            if (_formKey.currentState!.validate()) {
                              // Set saving state
                              setState(() {
                                _isSaving = true;
                              });

                              // Calculate overall rating (average of all skills)
                              final rating = ((_listening + _speaking + _reading + _writing) / 4).round();

                              // Create language entity
                              final language = Language(
                                name: _nameController.text,
                                listening: _listening,
                                speaking: _speaking,
                                reading: _reading,
                                writing: _writing,
                                rating: rating,
                                ratingLabel: _getRatingLabel(rating),
                              );

                              // Dispatch add event using the stored ResumeBloc instance
                              resumeBloc.add(AddLanguage(
                                language: language,
                                candidateId: _candidateId,
                              ));

                              // Note: Don't pop here, let the BlocListener handle it
                            }
                          },
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditLanguageDialog(BuildContext context, Language language) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: language.name);
    int _listening = language.listening ?? 3;
    int _speaking = language.speaking ?? 3;
    int _reading = language.reading ?? 3;
    int _writing = language.writing ?? 3;
    bool _isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is LanguageUpdated) {
                // Close dialog when language is updated
                Navigator.of(dialogContext).pop();
              } else if (state is ResumeError) {
                // Update saving state
                setState(() {
                  _isSaving = false;
                });
              }
            },
            child: StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Edit Language'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Language Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Language *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter language name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Proficiency Sliders
                        const Text(
                          'Proficiency Levels',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Listening
                        _buildProficiencySlider(
                          'Listening',
                          _listening,
                          (value) {
                            setState(() {
                              _listening = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),

                        // Speaking
                        _buildProficiencySlider(
                          'Speaking',
                          _speaking,
                          (value) {
                            setState(() {
                              _speaking = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),

                        // Reading
                        _buildProficiencySlider(
                          'Reading',
                          _reading,
                          (value) {
                            setState(() {
                              _reading = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),

                        // Writing
                        _buildProficiencySlider(
                          'Writing',
                          _writing,
                          (value) {
                            setState(() {
                              _writing = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: _isSaving
                        ? null // Disable cancel button while saving
                        : () {
                            Navigator.of(dialogContext).pop();
                          },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: _isSaving
                        ? null // Disable save button while saving
                        : () {
                            if (_formKey.currentState!.validate()) {
                              // Set saving state
                              setState(() {
                                _isSaving = true;
                              });

                              // Calculate overall rating (average of all skills)
                              final rating = ((_listening + _speaking + _reading + _writing) / 4).round();

                              // Create updated language entity
                              final updatedLanguage = Language(
                                id: language.id,
                                name: _nameController.text,
                                listening: _listening,
                                speaking: _speaking,
                                reading: _reading,
                                writing: _writing,
                                rating: rating,
                                ratingLabel: _getRatingLabel(rating),
                              );

                              // Dispatch update event using the stored ResumeBloc instance
                              resumeBloc.add(UpdateLanguage(
                                language: updatedLanguage,
                                candidateId: _candidateId,
                              ));

                              // Note: Don't pop here, let the BlocListener handle it
                            }
                          },
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Language language) {
    bool _isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while deleting
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is LanguageDeleted) {
                // Close dialog when language is deleted
                Navigator.of(dialogContext).pop();
              } else if (state is ResumeError) {
                // Update deleting state
                setState(() {
                  _isDeleting = false;
                });
              }
            },
            child: StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Delete Language'),
                content: Text('Are you sure you want to delete "${language.name}"?'),
                actions: [
                  TextButton(
                    onPressed: _isDeleting
                        ? null // Disable cancel button while deleting
                        : () {
                            Navigator.of(dialogContext).pop();
                          },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: _isDeleting
                        ? null // Disable delete button while deleting
                        : () {
                            if (language.id != null) {
                              // Set deleting state
                              setState(() {
                                _isDeleting = true;
                              });

                              // Dispatch delete event using the stored ResumeBloc instance
                              resumeBloc.add(DeleteLanguage(
                                languageId: language.id!,
                                candidateId: _candidateId,
                              ));

                              // Note: Don't pop here, let the BlocListener handle it
                            }
                          },
                    child: _isDeleting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Delete'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProficiencySlider(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  size: 16,
                  color: index < value ? Colors.amber : Colors.grey.shade300,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: _getProficiencyLabel(value),
          onChanged: (newValue) {
            onChanged(newValue.round());
          },
        ),
      ],
    );
  }

  String _getProficiencyLabel(int value) {
    switch (value) {
      case 1:
        return 'Elementary';
      case 2:
        return 'Limited';
      case 3:
        return 'Professional';
      case 4:
        return 'Full Professional';
      case 5:
        return 'Native / Bilingual';
      default:
        return 'Professional';
    }
  }

  String? _getRatingLabel(int rating) {
    return _languageLevels[rating.toString()] ?? _getProficiencyLabel(rating);
  }
}
