import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit experience screen - for editing work experience
class ResumeEditExperienceScreen extends StatefulWidget {
  const ResumeEditExperienceScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditExperienceScreen> createState() => _ResumeEditExperienceScreenState();
}

class _ResumeEditExperienceScreenState extends State<ResumeEditExperienceScreen> {
  int? _candidateId;
  List<Experience> _experiences = [];
  Map<String, dynamic> _countries = {};
  List<Map<String, dynamic>> _industries = [];
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    resumeBloc = context.read<ResumeBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'experience'));
    });
  }

  void _showExperienceSheet(BuildContext context, {Experience? existing}) {
    final formKey = GlobalKey<FormState>();
    final jobTitleCtrl = TextEditingController(text: existing?.jobTitle ?? '');
    final companyCtrl = TextEditingController(text: existing?.company ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String? selectedCountry = existing?.location?.toUpperCase();
    DateTime? startDate = existing?.startDate != null && existing!.startDate.isNotEmpty
        ? DateTime.tryParse(existing.startDate)
        : null;
    DateTime? endDate = existing?.endDate != null && existing!.endDate!.isNotEmpty
        ? DateTime.tryParse(existing.endDate!)
        : null;
    bool isCurrent = existing?.isCurrent ?? false;
    bool isSaving = false;

    final primary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: resumeBloc,
        child: BlocListener<ResumeBloc, ResumeState>(
          listener: (ctx2, state) {
            if (state is ExperienceAdded || state is ExperienceUpdated) {
              Navigator.of(ctx).pop();
            }
          },
          child: StatefulBuilder(
            builder: (ctx3, setSheetState) {
              return Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(ctx3).viewInsets.bottom),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(ctx3).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 4),
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.work_outline, color: primary),
                            const SizedBox(width: 8),
                            Text(
                              existing == null ? 'Add Work Experience' : 'Edit Work Experience',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: jobTitleCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Job Title *',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: companyCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Company *',
                                    prefixIcon: Icon(Icons.business_outlined),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _countries.isEmpty || selectedCountry == null
                                      ? null
                                      : (_countries.keys.any((k) => k.toUpperCase() == selectedCountry) ? selectedCountry : null),
                                  decoration: const InputDecoration(
                                    labelText: 'Country',
                                    prefixIcon: Icon(Icons.flag_outlined),
                                  ),
                                  isExpanded: true,
                                  items: _countries.entries.map((e) {
                                    final data = e.value as Map<String, dynamic>?;
                                    final name = data?['name'] as String? ?? e.key.toUpperCase();
                                    final emoji = data?['emoji'] as String?;
                                    return DropdownMenuItem<String>(
                                      value: e.key.toUpperCase(),
                                      child: Text(emoji != null ? '$emoji  $name' : name, overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (v) => setSheetState(() => selectedCountry = v),
                                ),
                                const SizedBox(height: 12),
                                // Start Date
                                GestureDetector(
                                  onTap: () async {
                                    final d = await showDatePicker(
                                      context: ctx3,
                                      initialDate: startDate ?? DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (d != null) setSheetState(() => startDate = d);
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Start Date *',
                                        prefixIcon: Icon(Icons.calendar_today_outlined),
                                      ),
                                      controller: TextEditingController(
                                        text: startDate != null ? DateFormat('MMM yyyy').format(startDate!) : '',
                                      ),
                                      validator: (_) => startDate == null ? 'Required' : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SwitchListTile(
                                  title: const Text('I currently work here', style: TextStyle(fontSize: 14)),
                                  value: isCurrent,
                                  activeColor: primary,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (v) => setSheetState(() {
                                    isCurrent = v;
                                    if (isCurrent) endDate = null;
                                  }),
                                ),
                                if (!isCurrent) ...[
                                  GestureDetector(
                                    onTap: () async {
                                      final d = await showDatePicker(
                                        context: ctx3,
                                        initialDate: endDate ?? DateTime.now(),
                                        firstDate: startDate ?? DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (d != null) setSheetState(() => endDate = d);
                                    },
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'End Date *',
                                          prefixIcon: Icon(Icons.calendar_today_outlined),
                                        ),
                                        controller: TextEditingController(
                                          text: endDate != null ? DateFormat('MMM yyyy').format(endDate!) : '',
                                        ),
                                        validator: (_) => (!isCurrent && endDate == null) ? 'Required' : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                TextFormField(
                                  controller: descCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    prefixIcon: Icon(Icons.notes_outlined),
                                    alignLabelWithHint: true,
                                  ),
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: isSaving
                                      ? null
                                      : () {
                                          if (formKey.currentState!.validate()) {
                                            setSheetState(() => isSaving = true);
                                            final exp = Experience(
                                              id: existing?.id,
                                              jobTitle: jobTitleCtrl.text,
                                              company: companyCtrl.text,
                                              startDate: startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : '',
                                              endDate: endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : null,
                                              isCurrent: isCurrent,
                                              description: descCtrl.text.isNotEmpty ? descCtrl.text : null,
                                              location: selectedCountry?.toLowerCase(),
                                            );
                                            if (existing == null) {
                                              resumeBloc.add(AddExperience(experience: exp, candidateId: _candidateId));
                                            } else {
                                              resumeBloc.add(UpdateExperience(experience: exp, candidateId: _candidateId));
                                            }
                                          }
                                        },
                                  icon: isSaving
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Icon(Icons.save_outlined),
                                  label: Text(isSaving ? 'Saving...' : 'Save Experience'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Experience exp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Experience'),
        content: Text('Remove "${exp.jobTitle}" at ${exp.company}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              resumeBloc.add(DeleteExperience(experienceId: exp.id!, candidateId: _candidateId));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
          onPressed: () => context.goNamed(AppRouter.resumeEditCareer),
        ),
        actions: [
          ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditExperience),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExperienceSheet(context),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Experience'),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            setState(() {
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
              _countries = state.response.countries ?? {};
              _industries = state.response.industries ?? [];
              final list = state.response.data['experience'] as List<dynamic>?;
              if (list != null) {
                _experiences = list.map((e) {
                  final m = e as Map<String, dynamic>;
                  return Experience(
                    id: m['id'] as int?,
                    jobTitle: m['title'] as String? ?? '',
                    company: m['company'] as String? ?? '',
                    startDate: m['start_date'] as String? ?? '',
                    endDate: m['end_date'] as String?,
                    isCurrent: (m['currently_working'] as int?) == 1,
                    description: m['description'] as String?,
                    location: m['country'] as String?,
                  );
                }).toList();
              } else {
                _experiences = [];
              }
            });
          } else if (state is ExperienceAdded) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Experience added!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'experience'));
          } else if (state is ExperienceUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Experience updated!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'experience'));
          } else if (state is ExperienceDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Experience removed!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'experience'));
          } else if (state is ResumeError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
          }
        },
        builder: (context, state) {
          if (state is ResumeLoading && _experiences.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              ResumeSectionProgressBar(currentScreen: AppRouter.resumeEditExperience),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    const ResumeSectionHeader(
                      title: 'Work Experience',
                      icon: Icons.work_outline,
                      subtitle: 'Add your professional work history',
                    ),

                    if (_experiences.isEmpty)
                      ResumeSectionCard(
                        child: Column(
                          children: [
                            Icon(Icons.work_off_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('No work experience added yet',
                                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('Tap the button below to add your first experience',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => _showExperienceSheet(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Experience'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primary,
                                side: BorderSide(color: primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._experiences.map((exp) {
                        final countryCode = exp.location?.toLowerCase();
                        String countryName = '';
                        if (countryCode != null && _countries.containsKey(countryCode)) {
                          final d = _countries[countryCode] as Map<String, dynamic>?;
                          countryName = d?['name'] as String? ?? countryCode;
                        }
                        String startStr = '';
                        String endStr = '';
                        try {
                          if (exp.startDate.isNotEmpty) startStr = DateFormat('MMM yyyy').format(DateTime.parse(exp.startDate));
                          endStr = exp.isCurrent ? 'Present' : (exp.endDate != null && exp.endDate!.isNotEmpty ? DateFormat('MMM yyyy').format(DateTime.parse(exp.endDate!)) : '');
                        } catch (_) {}

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Icon(Icons.work_outline, color: primary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(exp.jobTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                          Text(exp.company, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (v) {
                                        if (v == 'edit') _showExperienceSheet(context, existing: exp);
                                        if (v == 'delete') _confirmDelete(context, exp);
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
                                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text('$startStr – $endStr', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    if (countryName.isNotEmpty) ...[
                                      const SizedBox(width: 12),
                                      Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(countryName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    ],
                                  ],
                                ),
                                if (exp.isCurrent)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                      child: Text('Current', style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),

                    ResumeNavButtons(
                      prevRoute: AppRouter.resumeEditCareer,
                      nextRoute: AppRouter.resumeEditEducation,
                    ),
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
