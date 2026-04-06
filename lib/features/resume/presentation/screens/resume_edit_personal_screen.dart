import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit personal screen - for editing personal information
class ResumeEditPersonalScreen extends StatefulWidget {
  /// Constructor
  const ResumeEditPersonalScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditPersonalScreen> createState() => _ResumeEditPersonalScreenState();
}

class _ResumeEditPersonalScreenState extends State<ResumeEditPersonalScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _headlineController = TextEditingController();
  //final _summaryController = TextEditingController();

  // Selected values
  String? _selectedCountry;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  // Profile completion percentage
  int _profileCompletion = 0;

  // Candidate ID
  int? _candidateId;

  // Countries data from API
  Map<String, dynamic> _countries = {};

  @override
  void initState() {
    super.initState();
    // Fetch personal information when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResumeBloc>().add(const GetResumeSection(section: 'personal'));
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _headlineController.dispose();
    //_summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        actions: [
          // Keep the next button
          TextButton(
            onPressed: () {
              // Navigate to next section (career)
              context.goNamed(AppRouter.resumeEditCareer);
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
          ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditPersonal),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to profile screen
            context.goNamed(AppRouter.profile);
          },
        ),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            // Update profile completion and countries data
            setState(() {
              _profileCompletion = state.response.data['profile_completion'] as int? ?? 0;
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
              _countries = state.response.countries ?? {};
            });

            // Get personal information from response
            final personal = state.response.data['personal'] as Map<String, dynamic>?;
            if (personal != null) {
              // Update text controllers
              _firstNameController.text = personal['first_name'] != null ? personal['first_name'] as String? ?? '' : '';
              _lastNameController.text = personal['last_name'] != null ? personal['last_name'] as String? ?? '' : '';
              _emailController.text = personal['last_name'] != null ? personal['email'] as String? ?? '' : '';
              _phoneController.text = personal['last_name'] != null ? personal['phone'] as String? ?? '' : '';
              _addressController.text = personal['address'] != null ? personal['address'] as String? ?? '' : '';
              _cityController.text = personal['city'] != null ? personal['city'] as String? ?? '' : '';
              _postalCodeController.text = personal['postalCode'] != null ? personal['postalCode'] as String? ?? '' : '';
              _headlineController.text = personal['professional_title'] != null ? personal['professional_title'] as String? ?? '' : '';
              //_summaryController.text = personal['summary'] as String? ?? '';

              // Update selected values
              setState(() {
                // Convert country code to uppercase if it exists and not empty
                final countryCode = personal['country'] as String?;
                _selectedCountry = (countryCode != null && countryCode.isNotEmpty) ? countryCode.toUpperCase() : null;

                final gender = personal['gender'];
                _selectedGender = gender != null ? (gender == 1 ? "male" : "female") : null;
                final dob = personal['dob'] as String?;
                _selectedDateOfBirth = dob != null ? DateTime.tryParse(dob) : null;
              });
            }
          } else if (state is PersonalUpdated) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Personal information updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );

            // Navigate to next section
            context.goNamed(AppRouter.resumeEditCareer);
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile completion indicator
                  LinearProgressIndicator(value: _profileCompletion / 100),
                  const SizedBox(height: 8),
                  Text('$_profileCompletion% Complete', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),

                  // Personal information form
                  const Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // First name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  /*TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),*/

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

                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // City
                  /*TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),*/

                  // Country
                  DropdownButtonFormField<String>(
                    value: _countries.isEmpty || _selectedCountry == null ? null : (_countries.keys.any((k) => k.toUpperCase() == _selectedCountry) ? _selectedCountry : null),
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
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
                                Text(countryName),
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

                  // Postal code
                  /*TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),*/

                  // Gender
                  DropdownButtonFormField<String>(
                    value: _selectedGender == null ? null : 
                           (const ['male', 'female', 'other', 'prefer_not_to_say'].contains(_selectedGender) ? _selectedGender : null),
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                      DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Prefer not to say')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date of birth
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateOfBirth ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDateOfBirth = date;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: _selectedDateOfBirth != null
                              ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                              : '',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Headline
                  TextFormField(
                    controller: _headlineController,
                    decoration: const InputDecoration(
                      labelText: 'Headline/Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Summary
                  /*TextFormField(
                    controller: _summaryController,
                    decoration: const InputDecoration(
                      labelText: 'Summary',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 32),*/

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate form
                        if (_formKey.currentState!.validate()) {
                          // Create personal entity
                          final personal = Personal(
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            email: _emailController.text,
                            phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
                            address: _addressController.text.isNotEmpty ? _addressController.text : null,
                            //city: _cityController.text.isNotEmpty ? _cityController.text : null,
                            // Convert country code to lowercase if it exists
                            country: _selectedCountry != null ? _selectedCountry!.toLowerCase() : null,
                            postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
                            gender: _selectedGender /*== "male" ? 1 : 2*/,
                            dateOfBirth: _selectedDateOfBirth != null
                                ? '${_selectedDateOfBirth!.year}-${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}'
                                : null,
                            headline: _headlineController.text.isNotEmpty ? _headlineController.text : null,
                            //summary: _summaryController.text.isNotEmpty ? _summaryController.text : null,
                          );

                          // Dispatch update event
                          context.read<ResumeBloc>().add(UpdatePersonal(
                            personal: personal,
                            candidateId: _candidateId,
                          ));
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Save & Continue'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
