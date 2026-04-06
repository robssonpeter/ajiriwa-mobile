import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit awards screen - for editing awards and certificates
class ResumeEditAwardsScreen extends StatefulWidget {
  /// Constructor
  const ResumeEditAwardsScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditAwardsScreen> createState() => _ResumeEditAwardsScreenState();
}

class _ResumeEditAwardsScreenState extends State<ResumeEditAwardsScreen> {
  // Profile completion percentage
  int _profileCompletion = 0;

  // Candidate ID
  int? _candidateId;

  // List of awards
  List<Award> _awards = [];

  // Map of countries
  Map<String, dynamic> _countries = {};

  // List of industries
  List<dynamic> _industries = [];

  // Resume bloc instance
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    // Initialize the resumeBloc
    resumeBloc = context.read<ResumeBloc>();
    // Fetch awards information when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'certificates'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awards & Certificates'),
        actions: [
          // Keep the next button
          TextButton(
            onPressed: () {
              // Navigate to next section (reference)
              context.goNamed(AppRouter.resumeEditReference);
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
          ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditAwards),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to previous section (skills)
            context.goNamed(AppRouter.resumeEditSkills);
          },
        ),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            // Update profile completion, candidate ID, countries, industries
            setState(() {
              _profileCompletion = state.response.data['profile_completion'] as int? ?? 0;
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
              _countries = state.response.countries ?? {};
              _industries = state.response.industries ?? [];

              // Get awards list from response
              final awardsList = state.response.data['awards'] as List<dynamic>?;
              if (awardsList != null) {
                _awards = awardsList.map((e) {
                  final award = e as Map<String, dynamic>;

                  // Get the country value from the response
                  final countryValue = award['country_id'] as String?;
                  // Find the country code for the given country value
                  String? countryCode;
                  String? countryName;
                  if (countryValue != null) {
                    // First check if the country value is already a valid country code
                    if (_countries.containsKey(countryValue.toLowerCase())) {
                      countryCode = countryValue.toLowerCase();
                      final countryData = _countries[countryCode] as Map<String, dynamic>?;
                      if (countryData != null) {
                        countryName = countryData['name'] as String?;
                      }
                    } else {
                      // If not, try to find the country code by name
                      for (final entry in _countries.entries) {
                        final countryData = entry.value as Map<String, dynamic>?;
                        if (countryData != null && 
                            (countryData['name'] as String?) == countryValue) {
                          countryCode = entry.key;
                          countryName = countryValue;
                          break;
                        }
                      }
                    }
                  }

                  // Get the industry value from the response
                  final industryId = award['industry_id'] as int?;
                  String? industryName;
                  if (industryId != null) {
                    // Find the industry name for the given industry ID
                    final industry = _industries.firstWhere(
                      (industry) => industry['id'] == industryId,
                      orElse: () => {'name': ''},
                    );
                    industryName = industry['name'] as String?;
                  }

                  return Award(
                    id: award['id'] as int?,
                    name: award['name'] as String? ?? '',
                    issuer: award['issuer'] as String? ?? '',
                    date: award['date'] as String? ?? '',
                    description: award['description'] as String?,
                    categoryId: award['category_id'] as int?,
                    category: award['category'] as String?,
                    countryId: countryCode,
                    country: countryName,
                    industryId: industryId,
                    industry: industryName,
                  );
                }).toList();
              } else {
                _awards = [];
              }
            });
          } else if (state is AwardAdded) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Award added successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the awards list
            resumeBloc.add(const GetResumeSection(section: 'certificates'));
          } else if (state is AwardUpdated) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Award updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the awards list
            resumeBloc.add(const GetResumeSection(section: 'certificates'));
          } else if (state is AwardDeleted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Award deleted successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Refresh the awards list
            resumeBloc.add(const GetResumeSection(section: 'certificates'));
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
          // Not when adding, updating, or deleting awards
          if (state is ResumeLoading && _awards.isEmpty) {
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

                // Awards list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Awards & Certificates',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 100, // Fixed width to avoid infinite constraints
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Show add award dialog/screen
                          _showAddAwardDialog(context);
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

                // Awards list
                if (_awards.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No awards or certificates added yet. Click the "Add" button to add your awards and certificates.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _awards.length,
                    itemBuilder: (context, index) {
                      final award = _awards[index];

                      // Format date
                      String formattedDate = award.date;
                      try {
                        final date = DateTime.parse(award.date);
                        formattedDate = DateFormat.yMMMd().format(date);
                      } catch (e) {
                        // If date parsing fails, use the original date string
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
                                      award.name,
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
                                          _showEditAwardDialog(context, award);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(context, award);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                award.issuer,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Received: $formattedDate',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              if (award.category != null && award.category!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Category: ${award.category}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              if (award.country != null && award.country!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Country: ${award.country}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              if (award.industry != null && award.industry!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Industry: ${award.industry}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              if (award.description != null && award.description!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  award.description!,
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
                          context.goNamed(AppRouter.resumeEditSkills);
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
                          context.goNamed(AppRouter.resumeEditReference);
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

  void _showAddAwardDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _issuerController = TextEditingController();
    final _dateController = TextEditingController();
    final _descriptionController = TextEditingController();
    String? _selectedCountry;
    int? _selectedIndustryId;
    int? _selectedCategoryId;
    bool _isSaving = false;

    // Define categories
    final categories = [
      {'id': 1, 'name': 'Academic'},
      {'id': 2, 'name': 'Professional'},
      {'id': 3, 'name': 'Technical'},
      {'id': 4, 'name': 'Leadership'},
      {'id': 5, 'name': 'Community Service'},
    ];

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is AwardAdded) {
                // Close dialog when award is added
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
                title: const Text('Add Award/Certificate'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Award Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Award/Certificate Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter award/certificate name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Issuer
                        TextFormField(
                          controller: _issuerController,
                          decoration: const InputDecoration(
                            labelText: 'Issuing Organization *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter issuing organization';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date
                        TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Date Received *',
                            border: OutlineInputBorder(),
                            hintText: 'YYYY-MM-DD',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter date received';
                            }
                            // Simple date validation
                            final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                            if (!dateRegex.hasMatch(value)) {
                              return 'Please enter date in format YYYY-MM-DD';
                            }
                            return null;
                          },
                          onTap: () async {
                            // Show date picker
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              _dateController.text = DateFormat('yyyy-MM-dd').format(date);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category
                        DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem<int>(
                              value: category['id'] as int,
                              child: Text(category['name'] as String),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
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

                        // Industry
                        DropdownButtonFormField<int>(
                          value: _selectedIndustryId,
                          decoration: const InputDecoration(
                            labelText: 'Industry',
                            border: OutlineInputBorder(),
                          ),
                          items: _industries.isEmpty
                              ? []
                              : _industries.map((industry) {
                            return DropdownMenuItem<int>(
                              value: industry['id'] as int,
                              child: Text(industry['name'] as String),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedIndustryId = value;
                            });
                          },
                        ),
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

                              // Get category name from selected category ID
                              String? categoryName;
                              if (_selectedCategoryId != null) {
                                final category = categories.firstWhere(
                                  (category) => category['id'] == _selectedCategoryId,
                                  orElse: () => {'name': ''},
                                );
                                categoryName = category['name'] as String?;
                              }

                              // Get country name from selected country ID
                              String? countryName;
                              if (_selectedCountry != null) {
                                final countryData = _countries[_selectedCountry] as Map<String, dynamic>?;
                                if (countryData != null) {
                                  countryName = countryData['name'] as String?;
                                }
                              }

                              // Get industry name from selected industry ID
                              String? industryName;
                              if (_selectedIndustryId != null) {
                                final industry = _industries.firstWhere(
                                  (industry) => industry['id'] == _selectedIndustryId,
                                  orElse: () => {'name': ''},
                                );
                                industryName = industry['name'] as String?;
                              }

                              // Create award entity
                              final award = Award(
                                name: _nameController.text,
                                issuer: _issuerController.text,
                                date: _dateController.text,
                                description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
                                categoryId: _selectedCategoryId,
                                category: categoryName,
                                countryId: _selectedCountry,
                                country: countryName,
                                industryId: _selectedIndustryId,
                                industry: industryName,
                              );

                              // Dispatch add event using the stored ResumeBloc instance
                              resumeBloc.add(AddAward(
                                award: award,
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

  void _showEditAwardDialog(BuildContext context, Award award) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: award.name);
    final _issuerController = TextEditingController(text: award.issuer);
    final _dateController = TextEditingController(text: award.date);
    final _descriptionController = TextEditingController(text: award.description ?? '');
    String? _selectedCountry = award.countryId;
    int? _selectedIndustryId = award.industryId;
    int? _selectedCategoryId = award.categoryId;
    bool _isSaving = false;

    // Define categories
    final categories = [
      {'id': 1, 'name': 'Academic'},
      {'id': 2, 'name': 'Professional'},
      {'id': 3, 'name': 'Technical'},
      {'id': 4, 'name': 'Leadership'},
      {'id': 5, 'name': 'Community Service'},
    ];

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is AwardUpdated) {
                // Close dialog when award is updated
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
                title: const Text('Edit Award/Certificate'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Award Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Award/Certificate Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter award/certificate name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Issuer
                        TextFormField(
                          controller: _issuerController,
                          decoration: const InputDecoration(
                            labelText: 'Issuing Organization *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter issuing organization';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date
                        TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Date Received *',
                            border: OutlineInputBorder(),
                            hintText: 'YYYY-MM-DD',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter date received';
                            }
                            // Simple date validation
                            final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                            if (!dateRegex.hasMatch(value)) {
                              return 'Please enter date in format YYYY-MM-DD';
                            }
                            return null;
                          },
                          onTap: () async {
                            // Show date picker
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.tryParse(award.date) ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              _dateController.text = DateFormat('yyyy-MM-dd').format(date);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category
                        DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem<int>(
                              value: category['id'] as int,
                              child: Text(category['name'] as String),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
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

                        // Industry
                        DropdownButtonFormField<int>(
                          value: _selectedIndustryId,
                          decoration: const InputDecoration(
                            labelText: 'Industry',
                            border: OutlineInputBorder(),
                          ),
                          items: _industries.isEmpty
                              ? []
                              : _industries.map((industry) {
                            return DropdownMenuItem<int>(
                              value: industry['id'] as int,
                              child: Text(industry['name'] as String),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedIndustryId = value;
                            });
                          },
                        ),
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

                              // Get category name from selected category ID
                              String? categoryName;
                              if (_selectedCategoryId != null) {
                                final category = categories.firstWhere(
                                  (category) => category['id'] == _selectedCategoryId,
                                  orElse: () => {'name': ''},
                                );
                                categoryName = category['name'] as String?;
                              }

                              // Get country name from selected country ID
                              String? countryName;
                              if (_selectedCountry != null) {
                                final countryData = _countries[_selectedCountry] as Map<String, dynamic>?;
                                if (countryData != null) {
                                  countryName = countryData['name'] as String?;
                                }
                              }

                              // Get industry name from selected industry ID
                              String? industryName;
                              if (_selectedIndustryId != null) {
                                final industry = _industries.firstWhere(
                                  (industry) => industry['id'] == _selectedIndustryId,
                                  orElse: () => {'name': ''},
                                );
                                industryName = industry['name'] as String?;
                              }

                              // Create updated award entity
                              final updatedAward = Award(
                                id: award.id,
                                name: _nameController.text,
                                issuer: _issuerController.text,
                                date: _dateController.text,
                                description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
                                categoryId: _selectedCategoryId,
                                category: categoryName,
                                countryId: _selectedCountry,
                                country: countryName,
                                industryId: _selectedIndustryId,
                                industry: industryName,
                              );

                              // Dispatch update event using the stored ResumeBloc instance
                              resumeBloc.add(UpdateAward(
                                award: updatedAward,
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

  void _showDeleteConfirmationDialog(BuildContext context, Award award) {
    bool _isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while deleting
      builder: (dialogContext) {
        return BlocProvider.value(
          value: resumeBloc,
          child: BlocListener<ResumeBloc, ResumeState>(
            listener: (context, state) {
              if (state is AwardDeleted) {
                // Close dialog when award is deleted
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
                title: const Text('Delete Award/Certificate'),
                content: Text('Are you sure you want to delete "${award.name}"?'),
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
                            if (award.id != null) {
                              // Set deleting state
                              setState(() {
                                _isDeleting = true;
                              });

                              // Dispatch delete event using the stored ResumeBloc instance
                              resumeBloc.add(DeleteAward(
                                awardId: award.id!,
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
