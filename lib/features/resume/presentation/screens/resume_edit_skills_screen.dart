import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit skills screen - for editing skills and proficiency levels
class ResumeEditSkillsScreen extends StatefulWidget {
  /// Constructor
  const ResumeEditSkillsScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditSkillsScreen> createState() => _ResumeEditSkillsScreenState();
}

class _ResumeEditSkillsScreenState extends State<ResumeEditSkillsScreen> {
  // Profile completion percentage
  int _profileCompletion = 0;

  // Candidate ID
  int? _candidateId;

  // List of skills
  List<Skill> _skills = [];

  // Resume bloc instance
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    // Initialize the resumeBloc
    resumeBloc = context.read<ResumeBloc>();
    // Fetch skills information when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'skills'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills'),
        actions: [
          // Keep the next button
          TextButton(
            onPressed: () {
              // Navigate to next section (awards)
              context.goNamed(AppRouter.resumeEditAwards);
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
          ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditSkills),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to previous section (language)
            context.goNamed(AppRouter.resumeEditLanguage);
          },
        ),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            // Update profile completion, candidate ID
            setState(() {
              _profileCompletion = state.response.data['profile_completion'] as int? ?? 0;
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;

              // Get skills list from response
              final skillsList = state.response.data['skills'] as List<dynamic>?;
              if (skillsList != null) {
                _skills = skillsList.map((e) {
                  final skill = e as Map<String, dynamic>;
                  return Skill(
                    id: skill['id'] as int?,
                    name: skill['name'] as String? ?? '',
                    levelId: skill['levelId'] as int?,
                    level: skill['level'] as String?,
                    rating: skill['rating'] as int?,
                    ratingLabel: skill['rating_label'] as String?,
                  );
                }).toList();
              } else {
                _skills = [];
              }
            });
          } else if (state is SkillAdded) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Skill added successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the skills list
            resumeBloc.add(const GetResumeSection(section: 'skills'));
          } else if (state is SkillUpdated) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Skill updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the skills list
            resumeBloc.add(const GetResumeSection(section: 'skills'));
          } else if (state is SkillDeleted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Skill deleted successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the skills list
            resumeBloc.add(const GetResumeSection(section: 'skills'));
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
          // Not when adding, updating, or deleting skills
          if (state is ResumeLoading && _skills.isEmpty) {
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

                // Skills list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Skills',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 100, // Fixed width to avoid infinite constraints
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Show add skill dialog/screen
                          _showAddSkillDialog(context);
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

                // Skills list
                if (_skills.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No skills added yet. Click the "Add" button to add your skills.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _skills.length,
                    itemBuilder: (context, index) {
                      final skill = _skills[index];
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
                                      skill.name,
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
                                          _showEditSkillDialog(context, skill);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(context, skill);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (skill.rating != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Rating: ',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Flexible(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(5, (index) {
                                          return Icon(
                                            index < (skill.rating ?? 0) 
                                                ? Icons.star 
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 18,
                                          );
                                        }),
                                      ),
                                    ),
                                    if (skill.ratingLabel != null && skill.ratingLabel!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '(${skill.ratingLabel})',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
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
                          context.goNamed(AppRouter.resumeEditLanguage);
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
                          context.goNamed(AppRouter.resumeEditAwards);
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

  void _showAddSkillDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    int _selectedRating = 1; // Default to 1 to ensure a valid rating
    bool _isSaving = false;

    // Define rating labels
    final ratingLabels = {
      0: '',
      1: 'Basic',
      2: 'Limited',
      3: 'Good',
      4: 'Very Good',
      5: 'Excellent',
    };

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is SkillAdded) {
                // Close dialog when skill is added
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
                title: const Text('Add Skill'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Skill Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Skill Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter skill name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Rating
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rating',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Flexible(
                                  child: Row(
                                    children: List.generate(5, (index) {
                                      return IconButton(
                                        icon: Icon(
                                          index < _selectedRating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _selectedRating = index + 1;
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_selectedRating > 0)
                                  Text(
                                    '(${ratingLabels[_selectedRating]})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
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

                              // Create skill entity
                              // Ensure rating is always between 1-5 as required by backend
                              final effectiveRating = _selectedRating > 0 ? _selectedRating : 1;
                              final skill = Skill(
                                name: _nameController.text,
                                rating: effectiveRating,
                                ratingLabel: ratingLabels[effectiveRating],
                              );

                              // Dispatch add event using the stored ResumeBloc instance
                              resumeBloc.add(AddSkill(
                                skill: skill,
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

  void _showEditSkillDialog(BuildContext context, Skill skill) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: skill.name);
    int _selectedRating = skill.rating ?? 1; // Default to 1 if no rating
    bool _isSaving = false;

    // Define rating labels
    final ratingLabels = {
      0: '',
      1: 'Basic',
      2: 'Limited',
      3: 'Good',
      4: 'Very Good',
      5: 'Excellent',
    };

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is SkillUpdated) {
                // Close dialog when skill is updated
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
                title: const Text('Edit Skill'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Skill Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Skill Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter skill name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Rating
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rating',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Flexible(
                                  child: Row(
                                    children: List.generate(5, (index) {
                                      return IconButton(
                                        icon: Icon(
                                          index < _selectedRating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _selectedRating = index + 1;
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_selectedRating > 0)
                                  Text(
                                    '(${ratingLabels[_selectedRating]})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
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

                              // Create updated skill entity
                              // Ensure rating is always between 1-5 as required by backend
                              final effectiveRating = _selectedRating > 0 ? _selectedRating : 1;
                              final updatedSkill = Skill(
                                id: skill.id,
                                name: _nameController.text,
                                rating: effectiveRating,
                                ratingLabel: ratingLabels[effectiveRating],
                              );

                              // Dispatch update event using the stored ResumeBloc instance
                              resumeBloc.add(UpdateSkill(
                                skill: updatedSkill,
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

  void _showDeleteConfirmationDialog(BuildContext context, Skill skill) {
    bool _isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while deleting
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is SkillDeleted) {
                // Close dialog when skill is deleted
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
                title: const Text('Delete Skill'),
                content: Text('Are you sure you want to delete "${skill.name}"?'),
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
                            if (skill.id != null) {
                              // Set deleting state
                              setState(() {
                                _isDeleting = true;
                              });

                              // Dispatch delete event using the stored ResumeBloc instance
                              resumeBloc.add(DeleteSkill(
                                skillId: skill.id!,
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
}
