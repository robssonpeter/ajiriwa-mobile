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
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _headlineController = TextEditingController();

  String? _selectedCountry;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  int _profileCompletion = 0;
  int? _candidateId;
  Map<String, dynamic> _countries = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResumeBloc>().add(const GetResumeSection(section: 'personal'));
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _headlineController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      final personal = Personal(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        country: _selectedCountry != null ? _selectedCountry!.toLowerCase() : null,
        postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth != null
            ? '${_selectedDateOfBirth!.year}-${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}'
            : null,
        headline: _headlineController.text.isNotEmpty ? _headlineController.text : null,
      );
      context.read<ResumeBloc>().add(UpdatePersonal(personal: personal, candidateId: _candidateId));
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
          onPressed: () => context.goNamed(AppRouter.profile),
        ),
        actions: [
          ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditPersonal),
        ],
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          setState(() => _isSaving = false);
          if (state is ResumeSectionLoaded) {
            setState(() {
              _profileCompletion = state.response.data['profile_completion'] as int? ?? 0;
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
              _countries = state.response.countries ?? {};
            });
            final personal = state.response.data['personal'] as Map<String, dynamic>?;
            if (personal != null) {
              _firstNameController.text = personal['first_name'] as String? ?? '';
              _lastNameController.text = personal['last_name'] as String? ?? '';
              _emailController.text = personal['email'] as String? ?? '';
              _phoneController.text = personal['phone'] as String? ?? '';
              _addressController.text = personal['address'] as String? ?? '';
              _cityController.text = personal['city'] as String? ?? '';
              _postalCodeController.text = personal['postalCode'] as String? ?? '';
              _headlineController.text = personal['professional_title'] as String? ?? '';
              setState(() {
                final countryCode = personal['country'] as String?;
                _selectedCountry = (countryCode != null && countryCode.isNotEmpty) ? countryCode.toUpperCase() : null;
                final gender = personal['gender'];
                _selectedGender = gender != null ? (gender == 1 ? 'male' : 'female') : null;
                final dob = personal['dob'] as String?;
                _selectedDateOfBirth = dob != null ? DateTime.tryParse(dob) : null;
              });
            }
          } else if (state is PersonalUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Personal information saved!'),
                  ],
                ),
                backgroundColor: primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                duration: const Duration(seconds: 2),
              ),
            );
            context.goNamed(AppRouter.resumeEditCareer);
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
          if (state is ResumeLoading && _firstNameController.text.isEmpty) {
            return const ResumeEditSkeleton();
          }

          return Column(
            children: [
              ResumeSectionProgressBar(currentScreen: AppRouter.resumeEditPersonal),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Profile completion banner
                      if (_profileCompletion > 0)
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.insights, color: primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Profile $_profileCompletion% complete',
                                style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                      const ResumeSectionHeader(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        subtitle: 'Your basic contact and identity details',
                      ),

                      ResumeSectionCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'First Name *',
                                      prefixIcon: Icon(Icons.badge_outlined),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                    textCapitalization: TextCapitalization.words,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lastNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Last Name *',
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                    textCapitalization: TextCapitalization.words,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _headlineController,
                              decoration: const InputDecoration(
                                labelText: 'Professional Title / Headline',
                                prefixIcon: Icon(Icons.work_outline),
                                hintText: 'e.g. Senior Software Engineer',
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),

                      const ResumeSectionHeader(
                        title: 'Location',
                        icon: Icons.location_on_outlined,
                        subtitle: 'Where are you based?',
                      ),

                      ResumeSectionCard(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                prefixIcon: Icon(Icons.home_outlined),
                              ),
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: _countries.isEmpty || _selectedCountry == null
                                  ? null
                                  : (_countries.keys.any((k) => k.toUpperCase() == _selectedCountry)
                                      ? _selectedCountry
                                      : null),
                              decoration: const InputDecoration(
                                labelText: 'Country',
                                prefixIcon: Icon(Icons.flag_outlined),
                              ),
                              isExpanded: true,
                              items: _countries.isEmpty
                                  ? []
                                  : _countries.entries.map((entry) {
                                      final code = entry.key;
                                      final data = entry.value as Map<String, dynamic>?;
                                      final name = data?['name'] as String? ?? code.toUpperCase();
                                      final emoji = data?['emoji'] as String?;
                                      return DropdownMenuItem<String>(
                                        value: code.toUpperCase(),
                                        child: Text(emoji != null ? '$emoji  $name' : name),
                                      );
                                    }).toList(),
                              onChanged: (v) => setState(() => _selectedCountry = v),
                            ),
                          ],
                        ),
                      ),

                      const ResumeSectionHeader(
                        title: 'Personal Details',
                        icon: Icons.person_pin_outlined,
                        subtitle: 'Optional demographic information',
                      ),

                      ResumeSectionCard(
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedGender == null
                                  ? null
                                  : (const ['male', 'female', 'other', 'prefer_not_to_say'].contains(_selectedGender)
                                      ? _selectedGender
                                      : null),
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(Icons.wc_outlined),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                DropdownMenuItem(value: 'female', child: Text('Female')),
                                DropdownMenuItem(value: 'other', child: Text('Other')),
                                DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Prefer not to say')),
                              ],
                              onChanged: (v) => setState(() => _selectedGender = v),
                            ),
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDateOfBirth ?? DateTime(1990),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) setState(() => _selectedDateOfBirth = date);
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Date of Birth',
                                    prefixIcon: Icon(Icons.cake_outlined),
                                    suffixIcon: Icon(Icons.calendar_today_outlined),
                                  ),
                                  controller: TextEditingController(
                                    text: _selectedDateOfBirth != null
                                        ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                                        : '',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Save button
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
                        nextRoute: AppRouter.resumeEditCareer,
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
