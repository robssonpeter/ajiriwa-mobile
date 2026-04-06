import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit education screen - for editing education history
class ResumeEditEducationScreen extends StatefulWidget {
  /// Constructor
  const ResumeEditEducationScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditEducationScreen> createState() => _ResumeEditEducationScreenState();
}

class _ResumeEditEducationScreenState extends State<ResumeEditEducationScreen> {
  // Profile completion percentage
  int _profileCompletion = 0;

  // Candidate ID
  int? _candidateId;

  // List of educations
  List<Education> _educations = [];

  // Map of countries
  Map<String, dynamic> _countries = {};

  // Resume bloc instance
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    // Initialize the resumeBloc
    resumeBloc = context.read<ResumeBloc>();
    // Fetch education information when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'education'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
        actions: [
          // Keep the next button
          TextButton(
            onPressed: () {
              // Navigate to next section (language)
              context.goNamed(AppRouter.resumeEditLanguage);
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
          ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditEducation),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to previous section (experience)
            context.goNamed(AppRouter.resumeEditExperience);
          },
        ),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            // Update profile completion, candidate ID, countries
            setState(() {
              _profileCompletion = state.response.data['profile_completion'] as int? ?? 0;
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
              _countries = state.response.countries ?? {};

              // Get education list from response
              final educationList = state.response.data['education'] as List<dynamic>?;
              if (educationList != null) {
                _educations = educationList.map((e) {
                  final edu = e as Map<String, dynamic>;
                  // Get the country value from the response
                  final countryValue = edu['country_id'] as String?;
                  // Find the country code for the given country value
                  String? countryCode;
                  if (countryValue != null) {
                    // First check if the country value is already a valid country code
                    if (_countries.containsKey(countryValue.toLowerCase())) {
                      countryCode = countryValue.toLowerCase();
                    } else {
                      // If not, try to find the country code by name
                      for (final entry in _countries.entries) {
                        final countryData = entry.value as Map<String, dynamic>?;
                        if (countryData != null && 
                            (countryData['name'] as String?) == countryValue) {
                          countryCode = entry.key;
                          break;
                        }
                      }
                    }
                  }
                  return Education(
                    id: edu['id'] as int?,
                    institution: edu['institute'] as String? ?? '',
                    degree: edu['degree_title'] as String? ?? '',
                    fieldOfStudy: edu['field_of_study'] as String?,
                    startDate: edu['start_year'] as int,
                    endDate: () {
                      final yearValue = edu['year'];
                      if (yearValue is int) {
                        return yearValue.toString();
                      } else if (yearValue is String) {
                        return yearValue;
                      }
                      return null;
                    }(),
                    isCurrent: (edu['currently_studying'] as int?) == 1,
                    description: edu['description'] as String?,
                    countryId: countryCode,
                  );
                }).toList();
              } else {
                _educations = [];
              }
            });
          } else if (state is EducationAdded) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Education added successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the education list
            resumeBloc.add(const GetResumeSection(section: 'education'));
          } else if (state is EducationUpdated) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Education updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the education list
            resumeBloc.add(const GetResumeSection(section: 'education'));
          } else if (state is EducationDeleted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Education deleted successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the education list
            resumeBloc.add(const GetResumeSection(section: 'education'));
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
          // Not when adding, updating, or deleting educations
          if (state is ResumeLoading && _educations.isEmpty) {
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

                // Education list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Education',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 100, // Fixed width to avoid infinite constraints
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Show add education dialog/screen
                          _showAddEducationDialog(context);
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

                // Education list
                if (_educations.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No education added yet. Click the "Add" button to add your education.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _educations.length,
                    itemBuilder: (context, index) {
                      final education = _educations[index];

                      // Format dates
                      final startDate = education.startDate;
                      final endDate = education.isCurrent
                          ? 0
                          : (education.endDate != null && education.endDate!.isNotEmpty
                              ? education.endDate
                              : null);

                      // Get country name
                      final countryId = education.countryId?.toLowerCase();
                      String countryName = '';
                      if (countryId != null && _countries.containsKey(countryId)) {
                        final countryData = _countries[countryId] as Map<String, dynamic>?;
                        if (countryData != null) {
                          countryName = countryData['name'] as String? ?? '';
                        }
                      }

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
                                      education.degree,
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
                                          _showEditEducationDialog(context, education);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(context, education);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                education.institution,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              if (education.fieldOfStudy != null && education.fieldOfStudy!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  education.fieldOfStudy!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                '$startDate - $endDate',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              if (countryName.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  countryName,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              if (education.description != null && education.description!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  education.description!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
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
                          context.goNamed(AppRouter.resumeEditExperience);
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
                          context.goNamed(AppRouter.resumeEditLanguage);
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

  void _showAddEducationDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _institutionController = TextEditingController();
    final _degreeController = TextEditingController();
    final _fieldOfStudyController = TextEditingController();
    String? _selectedCountry;
    int? _startDate;
    int? _endDate;
    bool _isCurrent = false;
    final _descriptionController = TextEditingController();
    bool _isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is EducationAdded) {
                // Close dialog when education is added
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
                title: const Text('Add Education'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Institution
                        TextFormField(
                          controller: _institutionController,
                          decoration: const InputDecoration(
                            labelText: 'Institution *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter institution name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Degree
                        TextFormField(
                          controller: _degreeController,
                          decoration: const InputDecoration(
                            labelText: 'Degree *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter degree';
                            }
                            return null;
                          },
                        ),
                        /*const SizedBox(height: 16),

                        // Field of Study
                        TextFormField(
                          controller: _fieldOfStudyController,
                          decoration: const InputDecoration(
                            labelText: 'Field of Study *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter field of study';
                            }
                            return null;
                          },
                        ),*/
                        const SizedBox(height: 16),

                        // Country
                        DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            border: OutlineInputBorder(),
                          ),
                          isExpanded: true, // Ensure dropdown uses full width available
                          items: _countries.isEmpty
                              ? []
                              : _countries.entries.map((entry) {
                            final countryCode = entry.key;
                            final countryData = entry.value as Map<String, dynamic>?;
                            if (countryData == null) {
                              return DropdownMenuItem<String>(
                                value: countryCode.toLowerCase(),
                                child: Text(countryCode.toUpperCase()),
                              );
                            }
                            final countryName = countryData['name'] as String? ?? 'Unknown';
                            final countryEmoji = countryData['emoji'] as String?;

                            return DropdownMenuItem<String>(
                              value: countryCode.toLowerCase(),
                              child: Row(
                                children: [
                                  if (countryEmoji != null) Text(countryEmoji + ' '),
                                  Flexible(
                                    child: Text(
                                      countryName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _selectedCountry = value;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Start Date
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Start Year *',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 2020',
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: _startDate?.toString() ?? '',
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _startDate = int.tryParse(value);
                            } else {
                              _startDate = null;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter start year';
                            }
                            final year = int.tryParse(value);
                            if (year == null) {
                              return 'Please enter a valid year';
                            }
                            if (year < 1900 || year > DateTime.now().year) {
                              return 'Please enter a year between 1900 and ${DateTime.now().year}';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Currently Studying
                        CheckboxListTile(
                          title: const Text('I currently study here'),
                          value: _isCurrent,
                          onChanged: (value) {
                            _isCurrent = value ?? false;
                            if (_isCurrent) {
                              _endDate = null;
                            }
                            // Force rebuild
                            (context as Element).markNeedsBuild();
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),

                        // End Date (only if not current education)
                        if (!_isCurrent)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'End Year *',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., 2023',
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: _endDate?.toString() ?? '',
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                _endDate = int.tryParse(value);
                              } else {
                                _endDate = null;
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter end year';
                              }
                              final year = int.tryParse(value);
                              if (year == null) {
                                return 'Please enter a valid year';
                              }
                              if (year < 1900 || year > DateTime.now().year) {
                                return 'Please enter a year between 1900 and ${DateTime.now().year}';
                              }
                              if (_startDate != null && year < _startDate!) {
                                return 'End year must be after start year';
                              }
                              return null;
                            },
                          ),
                        if (!_isCurrent)
                          const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
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

                              // Create education entity
                              final education = Education(
                                institution: _institutionController.text,
                                degree: _degreeController.text,
                                fieldOfStudy: _fieldOfStudyController.text,
                                startDate: _startDate ?? 0,
                                endDate: _isCurrent ? null : _endDate?.toString(),
                                isCurrent: _isCurrent,
                                description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
                                countryId: _selectedCountry,
                              );

                              // Dispatch add event using the stored ResumeBloc instance
                              resumeBloc.add(AddEducation(
                                education: education,
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

  void _showEditEducationDialog(BuildContext context, Education education) {
    final _formKey = GlobalKey<FormState>();
    final _institutionController = TextEditingController(text: education.institution);
    final _degreeController = TextEditingController(text: education.degree);
    final _fieldOfStudyController = TextEditingController(text: education.fieldOfStudy ?? '');
    String? _selectedCountry = education.countryId;
    int? _startDate = education.startDate;
    int? _endDate = education.endDate != null ? int.tryParse(education.endDate!) : null;
    bool _isCurrent = education.isCurrent;
    final _descriptionController = TextEditingController(text: education.description ?? '');
    bool _isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is EducationUpdated) {
                // Close dialog when education is updated
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
                title: const Text('Edit Education'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Institution
                        TextFormField(
                          controller: _institutionController,
                          decoration: const InputDecoration(
                            labelText: 'Institution *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter institution name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Degree
                        TextFormField(
                          controller: _degreeController,
                          decoration: const InputDecoration(
                            labelText: 'Degree *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter degree';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Field of Study
                        /*TextFormField(
                          controller: _fieldOfStudyController,
                          decoration: const InputDecoration(
                            labelText: 'Field of Study *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter field of study';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),*/

                        // Country
                        DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            border: OutlineInputBorder(),
                          ),
                          isExpanded: true, // Ensure dropdown uses full width available
                          items: _countries.isEmpty
                              ? []
                              : _countries.entries.map((entry) {
                            final countryCode = entry.key;
                            final countryData = entry.value as Map<String, dynamic>?;
                            if (countryData == null) {
                              return DropdownMenuItem<String>(
                                value: countryCode.toLowerCase(),
                                child: Text(countryCode.toUpperCase()),
                              );
                            }
                            final countryName = countryData['name'] as String? ?? 'Unknown';
                            final countryEmoji = countryData['emoji'] as String?;

                            return DropdownMenuItem<String>(
                              value: countryCode.toLowerCase(),
                              child: Row(
                                children: [
                                  if (countryEmoji != null) Text(countryEmoji + ' '),
                                  Flexible(
                                    child: Text(
                                      countryName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCountry = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Start Date
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Start Year *',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 2020',
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: _startDate?.toString() ?? '',
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _startDate = int.tryParse(value);
                            } else {
                              _startDate = null;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter start year';
                            }
                            final year = int.tryParse(value);
                            if (year == null) {
                              return 'Please enter a valid year';
                            }
                            if (year < 1900 || year > DateTime.now().year) {
                              return 'Please enter a year between 1900 and ${DateTime.now().year}';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Currently Studying
                        CheckboxListTile(
                          title: const Text('I currently study here'),
                          value: _isCurrent,
                          onChanged: (value) {
                            _isCurrent = value ?? false;
                            if (_isCurrent) {
                              _endDate = null;
                            }
                            // Force rebuild
                            (context as Element).markNeedsBuild();
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),

                        // End Date (only if not current education)
                        if (!_isCurrent)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'End Year *',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., 2023',
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: _endDate?.toString() ?? '',
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                _endDate = int.tryParse(value);
                              } else {
                                _endDate = null;
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter end year';
                              }
                              final year = int.tryParse(value);
                              if (year == null) {
                                return 'Please enter a valid year';
                              }
                              if (year < 1900 || year > DateTime.now().year) {
                                return 'Please enter a year between 1900 and ${DateTime.now().year}';
                              }
                              if (_startDate != null && year < _startDate!) {
                                return 'End year must be after start year';
                              }
                              return null;
                            },
                          ),
                        if (!_isCurrent)
                          const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
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

                              // Create updated education entity
                              final updatedEducation = Education(
                                id: education.id,
                                institution: _institutionController.text,
                                degree: _degreeController.text,
                                fieldOfStudy: _fieldOfStudyController.text,
                                startDate: _startDate ?? education.startDate,
                                endDate: _isCurrent ? null : _endDate?.toString(),
                                isCurrent: _isCurrent,
                                description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
                                countryId: _selectedCountry,
                              );

                              // Dispatch update event using the stored ResumeBloc instance
                              resumeBloc.add(UpdateEducation(
                                education: updatedEducation,
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

  void _showDeleteConfirmationDialog(BuildContext context, Education education) {
    bool _isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while deleting
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is EducationDeleted) {
                // Close dialog when education is deleted
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
                title: const Text('Delete Education'),
                content: Text('Are you sure you want to delete "${education.degree}" at "${education.institution}"?'),
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
                            if (education.id != null) {
                              // Set deleting state
                              setState(() {
                                _isDeleting = true;
                              });

                              // Dispatch delete event using the stored ResumeBloc instance
                              resumeBloc.add(DeleteEducation(
                                educationId: education.id!,
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
