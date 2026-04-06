import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit experience screen - for editing work experience
class ResumeEditExperienceScreen extends StatefulWidget {
  /// Constructor
  const ResumeEditExperienceScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditExperienceScreen> createState() => _ResumeEditExperienceScreenState();
}

class _ResumeEditExperienceScreenState extends State<ResumeEditExperienceScreen> {
  // Profile completion percentage
  int _profileCompletion = 0;

  // Candidate ID
  int? _candidateId;

  // List of experiences
  List<Experience> _experiences = [];

  // Map of countries
  Map<String, dynamic> _countries = {};

  // Map of industries
  List<Map<String, dynamic>> _industries = [];

  // Resume bloc instance
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    // Initialize the resumeBloc
    resumeBloc = context.read<ResumeBloc>();
    // Fetch experience information when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'experience'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Experience'),
        actions: [
          // Keep the next button
          TextButton(
            onPressed: () {
              // Navigate to next section (education)
              context.goNamed(AppRouter.resumeEditEducation);
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
          ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditExperience),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to previous section (career)
            context.goNamed(AppRouter.resumeEditCareer);
          },
        ),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            // Update profile completion, candidate ID, countries, and industries
            setState(() {
              _profileCompletion = state.response.data['profile_completion'] as int? ?? 0;
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
              _countries = state.response.countries ?? {};
              _industries = state.response.industries ?? [];

              // Get experience list from response
              final experienceList = state.response.data['experience'] as List<dynamic>?;
              if (experienceList != null) {
                _experiences = experienceList.map((e) {
                  final exp = e as Map<String, dynamic>;
                  return Experience(
                    id: exp['id'] as int?,
                    jobTitle: exp['title'] as String? ?? '',
                    company: exp['company'] as String? ?? '',
                    startDate: exp['start_date'] as String? ?? '',
                    endDate: exp['end_date'] as String?,
                    isCurrent: (exp['currently_working'] as int?) == 1,
                    description: exp['description'] as String?,
                    location: exp['country'] as String?,
                  );
                }).toList();
              } else {
                _experiences = [];
              }
            });
          } else if (state is ExperienceAdded) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Experience added successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the experience list
            resumeBloc.add(const GetResumeSection(section: 'experience'));
          } else if (state is ExperienceUpdated) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Experience updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the experience list
            resumeBloc.add(const GetResumeSection(section: 'experience'));
          } else if (state is ExperienceDeleted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Experience deleted successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the experience list
            resumeBloc.add(const GetResumeSection(section: 'experience'));
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
          // Not when adding, updating, or deleting experiences
          if (state is ResumeLoading && _experiences.isEmpty) {
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

                // Work experience list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Work Experience',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 100, // Fixed width to avoid infinite constraints
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Show add experience dialog/screen
                          _showAddExperienceDialog(context);
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

                // Experience list
                if (_experiences.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No work experience added yet. Click the "Add" button to add your work experience.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _experiences.length,
                    itemBuilder: (context, index) {
                      final experience = _experiences[index];
                      final countryCode = experience.location?.toLowerCase();
                      String countryName = countryCode ?? '';
                      if (countryCode != null && _countries.containsKey(countryCode)) {
                        final countryData = _countries[countryCode] as Map<String, dynamic>?;
                        if (countryData != null) {
                          countryName = countryData['name'] as String? ?? countryCode;
                        }
                      }

                      // Format dates
                      final startDate = experience.startDate.isNotEmpty
                          ? DateFormat('MMMM yyyy').format(DateTime.parse(experience.startDate))
                          : '';
                      final endDate = experience.isCurrent
                          ? 'Present'
                          : (experience.endDate != null && experience.endDate!.isNotEmpty
                              ? DateFormat('MMMM yyyy').format(DateTime.parse(experience.endDate!))
                              : '');

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
                                      experience.jobTitle,
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
                                          _showEditExperienceDialog(context, experience);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(context, experience);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                experience.company,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
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
                              if (experience.description != null && experience.description!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  experience.description!,
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
                          context.goNamed(AppRouter.resumeEditCareer);
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
                          context.goNamed(AppRouter.resumeEditEducation);
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

  void _showAddExperienceDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _jobTitleController = TextEditingController();
    final _companyController = TextEditingController();
    String? _selectedCountry;
    DateTime? _startDate;
    DateTime? _endDate;
    bool _isCurrent = false;
    final _descriptionController = TextEditingController();
    bool _isSaving = false;

    // Get the ResumeBloc instance from the context before showing the dialog
    //final resumeBloc = context.read<ResumeBloc>();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is ExperienceAdded) {
                // Close dialog when experience is added
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
                title: const Text('Add Work Experience'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Job Title
                        TextFormField(
                          controller: _jobTitleController,
                          decoration: const InputDecoration(
                            labelText: 'Job Title *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter job title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                      // Company
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: 'Company *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter company name';
                          }
                          return null;
                        },
                      ),
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
                              value: countryCode.toUpperCase(),
                              child: Text(countryCode.toUpperCase()),
                            );
                          }
                          final countryName = countryData['name'] as String? ?? 'Unknown';
                          final countryEmoji = countryData['emoji'] as String?;

                          return DropdownMenuItem<String>(
                            value: countryCode.toUpperCase(),
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
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _startDate = date;
                            // Force rebuild
                            (context as Element).markNeedsBuild();
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Start Date *',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: _startDate != null
                                  ? DateFormat('yyyy-MM-dd').format(_startDate!)
                                  : '',
                            ),
                            validator: (value) {
                              if (_startDate == null) {
                                return 'Please select start date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Currently Working
                      CheckboxListTile(
                        title: const Text('I currently work here'),
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

                      // End Date (only if not current job)
                      if (!_isCurrent)
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: _startDate ?? DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              _endDate = date;
                              // Force rebuild
                              (context as Element).markNeedsBuild();
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'End Date *',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              controller: TextEditingController(
                                text: _endDate != null
                                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                    : '',
                              ),
                              validator: (value) {
                                if (!_isCurrent && _endDate == null) {
                                  return 'Please select end date';
                                }
                                return null;
                              },
                            ),
                          ),
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

                      // Create experience entity
                      final experience = Experience(
                        jobTitle: _jobTitleController.text,
                        company: _companyController.text,
                        startDate: _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : '',
                        endDate: _isCurrent ? null : (_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null),
                        isCurrent: _isCurrent,
                        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
                        location: _selectedCountry,
                      );

                      // Dispatch add event using the stored ResumeBloc instance
                      resumeBloc.add(AddExperience(
                        experience: experience,
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
          )
        );
      },
    );
  }

  void _showEditExperienceDialog(BuildContext context, Experience experience) {
    final _formKey = GlobalKey<FormState>();
    final _jobTitleController = TextEditingController(text: experience.jobTitle);
    final _companyController = TextEditingController(text: experience.company);
    String? _selectedCountry = experience.location?.toUpperCase();
    DateTime? _startDate = experience.startDate.isNotEmpty ? DateTime.tryParse(experience.startDate) : null;
    DateTime? _endDate = experience.endDate != null && experience.endDate!.isNotEmpty ? DateTime.tryParse(experience.endDate!) : null;
    bool _isCurrent = experience.isCurrent;
    final _descriptionController = TextEditingController(text: experience.description ?? '');
    bool _isSaving = false;

    // Get the ResumeBloc instance from the context before showing the dialog
    //final resumeBloc = context.read<ResumeBloc>();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is ExperienceUpdated) {
                // Close dialog when experience is updated
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
                title: const Text('Edit Work Experience'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      // Job Title
                      TextFormField(
                        controller: _jobTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Job Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter job title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Company
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: 'Company *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter company name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Country
                      DropdownButtonFormField<String>(
                        value: _countries.isEmpty || _selectedCountry == null ? null :
                        (_countries.keys.any((k) => k.toUpperCase() == _selectedCountry) ? _selectedCountry : null),
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
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _startDate = date;
                            // Force rebuild
                            (context as Element).markNeedsBuild();
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Start Date *',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: _startDate != null
                                  ? DateFormat('yyyy-MM-dd').format(_startDate!)
                                  : '',
                            ),
                            validator: (value) {
                              if (_startDate == null) {
                                return 'Please select start date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Currently Working
                      CheckboxListTile(
                        title: const Text('I currently work here'),
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

                      // End Date (only if not current job)
                      if (!_isCurrent)
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: _startDate ?? DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              _endDate = date;
                              // Force rebuild
                              (context as Element).markNeedsBuild();
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'End Date *',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              controller: TextEditingController(
                                text: _endDate != null
                                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                    : '',
                              ),
                              validator: (value) {
                                if (!_isCurrent && _endDate == null) {
                                  return 'Please select end date';
                                }
                                return null;
                              },
                            ),
                          ),
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

                      // Create updated experience entity
                      final updatedExperience = Experience(
                        id: experience.id,
                        jobTitle: _jobTitleController.text,
                        company: _companyController.text,
                        startDate: _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : '',
                        endDate: _isCurrent ? null : (_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null),
                        isCurrent: _isCurrent,
                        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
                        location: _selectedCountry,
                      );

                      // Dispatch update event using the stored ResumeBloc instance
                      resumeBloc.add(UpdateExperience(
                        experience: updatedExperience,
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
          )
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Experience experience) {
    bool _isDeleting = false;

    // Get the ResumeBloc instance from the context before showing the dialog
    //final resumeBloc = context.read<ResumeBloc>();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while deleting
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is ExperienceDeleted) {
                // Close dialog when experience is deleted
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
                title: const Text('Delete Experience'),
                content: Text('Are you sure you want to delete "${experience.jobTitle}" at "${experience.company}"?'),
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
                      if (experience.id != null) {
                        // Set deleting state
                        setState(() {
                          _isDeleting = true;
                        });

                        // Dispatch delete event using the stored ResumeBloc instance
                        resumeBloc.add(DeleteExperience(
                          experienceId: experience.id!,
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
          )
          );
      },
    );
  }
}
