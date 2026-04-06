import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit reference screen - for editing references
class ResumeEditReferenceScreen extends StatefulWidget {
  /// Constructor
  const ResumeEditReferenceScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditReferenceScreen> createState() => _ResumeEditReferenceScreenState();
}

class _ResumeEditReferenceScreenState extends State<ResumeEditReferenceScreen> {
  // Profile completion percentage
  int _profileCompletion = 0;

  // Candidate ID
  int? _candidateId;

  // List of references
  List<Reference> _references = [];

  // Countries data from API
  Map<String, dynamic> _countries = {};

  // Resume bloc instance
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    // Initialize the resumeBloc
    resumeBloc = context.read<ResumeBloc>();
    // Fetch references information when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'reference'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('References'),
        actions: [
          // Add navigation menu
          ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditReference),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to previous section (awards)
            context.goNamed(AppRouter.resumeEditAwards);
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

              // Get countries data from response
              _countries = state.response.countries ?? {};

              // Get references list from response
              final referencesList = state.response.data['referees'] as List<dynamic>?;
              if (referencesList != null) {
                _references = referencesList.map((e) {
                  final reference = e as Map<String, dynamic>;
                  return Reference(
                    id: reference['id'] as int?,
                    name: reference['name'] as String? ?? '',
                    position: reference['position'] as String? ?? '',
                    company: reference['company'] as String? ?? '',
                    email: reference['email'] as String?,
                    phone: reference['phone'] as String?,
                    relationship: reference['relationship'] as String?,
                  );
                }).toList();
              } else {
                _references = [];
              }
            });
          } else if (state is ReferenceAdded) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reference added successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the references list
            resumeBloc.add(const GetResumeSection(section: 'reference'));
          } else if (state is ReferenceUpdated) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reference updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the references list
            resumeBloc.add(const GetResumeSection(section: 'reference'));
          } else if (state is ReferenceDeleted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reference deleted successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the references list
            resumeBloc.add(const GetResumeSection(section: 'reference'));
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
          // Not when adding, updating, or deleting references
          if (state is ResumeLoading && _references.isEmpty) {
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

                // References list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'References',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 100, // Fixed width to avoid infinite constraints
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Show add reference dialog/screen
                          _showAddReferenceDialog(context);
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

                // References list
                if (_references.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No references added yet. Click the "Add" button to add your references.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _references.length,
                    itemBuilder: (context, index) {
                      final reference = _references[index];
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
                                      reference.name,
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
                                          _showEditReferenceDialog(context, reference);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(context, reference);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${reference.position} at ${reference.company}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              if (reference.email != null && reference.email!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Email: ${reference.email}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              if (reference.phone != null && reference.phone!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Phone: ${reference.phone}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              if (reference.relationship != null && reference.relationship!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Relationship: ${reference.relationship}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
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
                          context.goNamed(AppRouter.resumeEditAwards);
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
                          // Save and finish
                          _saveAndFinish(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('Save & Finish'),
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

  void _showAddReferenceDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _positionController = TextEditingController();
    final _companyController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _relationshipController = TextEditingController();
    bool _isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is ReferenceAdded) {
                // Close dialog when reference is added
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
                title: const Text('Add Reference'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Reference Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter reference name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Position
                        TextFormField(
                          controller: _positionController,
                          decoration: const InputDecoration(
                            labelText: 'Position/Title *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter position/title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Company
                        TextFormField(
                          controller: _companyController,
                          decoration: const InputDecoration(
                            labelText: 'Company/Organization *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter company/organization';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              // Simple email validation
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Please enter a valid email';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        // Relationship
                        TextFormField(
                          controller: _relationshipController,
                          decoration: const InputDecoration(
                            labelText: 'Relationship',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., Manager, Colleague, Professor',
                          ),
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

                              // Create reference entity
                              final reference = Reference(
                                name: _nameController.text,
                                position: _positionController.text,
                                company: _companyController.text,
                                email: _emailController.text.isEmpty ? null : _emailController.text,
                                phone: _phoneController.text.isEmpty ? null : _phoneController.text,
                                relationship: _relationshipController.text.isEmpty ? null : _relationshipController.text,
                              );

                              // Dispatch add event using the stored ResumeBloc instance
                              resumeBloc.add(AddReference(
                                reference: reference,
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

  void _showEditReferenceDialog(BuildContext context, Reference reference) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: reference.name);
    final _positionController = TextEditingController(text: reference.position);
    final _companyController = TextEditingController(text: reference.company);
    final _emailController = TextEditingController(text: reference.email ?? '');
    final _phoneController = TextEditingController(text: reference.phone ?? '');
    final _relationshipController = TextEditingController(text: reference.relationship ?? '');
    bool _isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is ReferenceUpdated) {
                // Close dialog when reference is updated
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
                title: const Text('Edit Reference'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Reference Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter reference name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Position
                        TextFormField(
                          controller: _positionController,
                          decoration: const InputDecoration(
                            labelText: 'Position/Title *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter position/title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Company
                        TextFormField(
                          controller: _companyController,
                          decoration: const InputDecoration(
                            labelText: 'Company/Organization *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter company/organization';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              // Simple email validation
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Please enter a valid email';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        // Relationship
                        TextFormField(
                          controller: _relationshipController,
                          decoration: const InputDecoration(
                            labelText: 'Relationship',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., Manager, Colleague, Professor',
                          ),
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

                              // Create updated reference entity
                              final updatedReference = Reference(
                                id: reference.id,
                                name: _nameController.text,
                                position: _positionController.text,
                                company: _companyController.text,
                                email: _emailController.text.isEmpty ? null : _emailController.text,
                                phone: _phoneController.text.isEmpty ? null : _phoneController.text,
                                relationship: _relationshipController.text.isEmpty ? null : _relationshipController.text,
                              );

                              // Dispatch update event using the stored ResumeBloc instance
                              resumeBloc.add(UpdateReference(
                                reference: updatedReference,
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

  void _showDeleteConfirmationDialog(BuildContext context, Reference reference) {
    bool _isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while deleting
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is ReferenceDeleted) {
                // Close dialog when reference is deleted
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
                title: const Text('Delete Reference'),
                content: Text('Are you sure you want to delete "${reference.name}"?'),
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
                            if (reference.id != null) {
                              // Set deleting state
                              setState(() {
                                _isDeleting = true;
                              });

                              // Dispatch delete event using the stored ResumeBloc instance
                              resumeBloc.add(DeleteReference(
                                referenceId: reference.id!,
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

  void _saveAndFinish(BuildContext context) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resume saved successfully!'),
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back to profile screen
    Future.delayed(const Duration(seconds: 1), () {
      context.goNamed(AppRouter.profile);
    });
  }
}
