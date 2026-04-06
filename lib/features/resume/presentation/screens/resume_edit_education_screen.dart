import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit education screen
class ResumeEditEducationScreen extends StatefulWidget {
  const ResumeEditEducationScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditEducationScreen> createState() => _ResumeEditEducationScreenState();
}

class _ResumeEditEducationScreenState extends State<ResumeEditEducationScreen> {
  int? _candidateId;
  List<Education> _educations = [];
  Map<String, dynamic> _countries = {};
  List<dynamic> _educationLevels = [];
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    resumeBloc = context.read<ResumeBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'education'));
    });
  }

  void _showEducationSheet(BuildContext context, {Education? existing}) {
    final formKey = GlobalKey<FormState>();
    final institutionCtrl = TextEditingController(text: existing?.institution ?? '');
    final degreeCtrl = TextEditingController(text: existing?.degree ?? '');
    final fieldCtrl = TextEditingController(text: existing?.fieldOfStudy ?? '');
    int? startYear = existing?.startDate;
    int? endYear = existing?.endDate != null ? int.tryParse(existing!.endDate!) : null;
    bool isCurrent = existing?.isCurrent ?? false;
    int? selectedLevelId = existing?.educationLevelId;
    bool isSaving = false;

    final primary = Theme.of(context).colorScheme.primary;
    final currentYear = DateTime.now().year;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: resumeBloc,
        child: BlocListener<ResumeBloc, ResumeState>(
          listener: (_, state) {
            if (state is EducationAdded || state is EducationUpdated) Navigator.of(ctx).pop();
          },
          child: StatefulBuilder(
            builder: (ctx3, setSheetState) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx3).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(ctx3).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 4),
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.school_outlined, color: primary),
                          const SizedBox(width: 8),
                          Text(
                            existing == null ? 'Add Education' : 'Edit Education',
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
                                controller: institutionCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Institution / School *',
                                  prefixIcon: Icon(Icons.account_balance_outlined),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: degreeCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Degree / Qualification *',
                                  prefixIcon: Icon(Icons.workspace_premium_outlined),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: fieldCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Field of Study',
                                  prefixIcon: Icon(Icons.book_outlined),
                                ),
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 12),
                              if (_educationLevels.isNotEmpty)
                                DropdownButtonFormField<int>(
                                  value: selectedLevelId,
                                  decoration: const InputDecoration(
                                    labelText: 'Education Level',
                                    prefixIcon: Icon(Icons.bar_chart_outlined),
                                  ),
                                  isExpanded: true,
                                  items: _educationLevels.map((level) {
                                    final l = level as Map<String, dynamic>;
                                    return DropdownMenuItem<int>(
                                      value: l['id'] as int?,
                                      child: Text(l['name'] as String? ?? ''),
                                    );
                                  }).toList(),
                                  onChanged: (v) => setSheetState(() => selectedLevelId = v),
                                ),
                              if (_educationLevels.isNotEmpty) const SizedBox(height: 12),
                              // Start Year
                              TextFormField(
                                initialValue: startYear?.toString() ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Start Year *',
                                  prefixIcon: Icon(Icons.calendar_today_outlined),
                                  hintText: 'e.g. 2018',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  final y = int.tryParse(v);
                                  if (y == null || y < 1900 || y > currentYear) return 'Enter a valid year';
                                  return null;
                                },
                                onChanged: (v) => startYear = int.tryParse(v),
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                title: const Text('Currently studying here', style: TextStyle(fontSize: 14)),
                                value: isCurrent,
                                activeColor: primary,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (v) => setSheetState(() {
                                  isCurrent = v;
                                  if (isCurrent) endYear = null;
                                }),
                              ),
                              if (!isCurrent) ...[
                                TextFormField(
                                  initialValue: endYear?.toString() ?? '',
                                  decoration: const InputDecoration(
                                    labelText: 'End Year *',
                                    prefixIcon: Icon(Icons.calendar_today_outlined),
                                    hintText: 'e.g. 2022',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (!isCurrent) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      final y = int.tryParse(v);
                                      if (y == null || y < 1900 || y > currentYear + 10) return 'Enter a valid year';
                                      if (startYear != null && y < startYear!) return 'Must be after start year';
                                    }
                                    return null;
                                  },
                                  onChanged: (v) => endYear = int.tryParse(v),
                                ),
                                const SizedBox(height: 12),
                              ],
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: isSaving
                                    ? null
                                    : () {
                                        if (formKey.currentState!.validate()) {
                                          setSheetState(() => isSaving = true);
                                          final edu = Education(
                                            id: existing?.id,
                                            institution: institutionCtrl.text,
                                            degree: degreeCtrl.text,
                                            fieldOfStudy: fieldCtrl.text.isNotEmpty ? fieldCtrl.text : null,
                                            startDate: startYear ?? 0,
                                            endDate: isCurrent ? null : endYear?.toString(),
                                            isCurrent: isCurrent,
                                            educationLevelId: selectedLevelId,
                                          );
                                          if (existing == null) {
                                            resumeBloc.add(AddEducation(education: edu, candidateId: _candidateId));
                                          } else {
                                            resumeBloc.add(UpdateEducation(education: edu, candidateId: _candidateId));
                                          }
                                        }
                                      },
                                icon: isSaving
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.save_outlined),
                                label: Text(isSaving ? 'Saving...' : 'Save Education'),
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
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Education edu) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Education'),
        content: Text('Remove "${edu.degree}" from ${edu.institution}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              resumeBloc.add(DeleteEducation(educationId: edu.id!, candidateId: _candidateId));
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
          onPressed: () => context.goNamed(AppRouter.resumeEditExperience),
        ),
        actions: [ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditEducation)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEducationSheet(context),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Education'),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            setState(() {
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
              _countries = state.response.countries ?? {};
              _educationLevels = state.response.data['education_levels'] as List<dynamic>? ?? [];
              final list = state.response.data['education'] as List<dynamic>?;
              if (list != null) {
                _educations = list.map((e) {
                  final m = e as Map<String, dynamic>;
                  return Education(
                    id: m['id'] as int?,
                    institution: m['institute'] as String? ?? '',
                    degree: m['degree_title'] as String? ?? '',
                    fieldOfStudy: m['field_of_study'] as String?,
                    startDate: m['start_year'] as int? ?? 0,
                    endDate: m['end_year']?.toString(),
                    isCurrent: (m['currently_studying'] as int?) == 1,
                    educationLevelId: m['education_level_id'] as int?,
                  );
                }).toList();
              } else {
                _educations = [];
              }
            });
          } else if (state is EducationAdded) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Education added!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'education'));
          } else if (state is EducationUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Education updated!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'education'));
          } else if (state is EducationDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Education removed!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'education'));
          } else if (state is ResumeError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
          }
        },
        builder: (context, state) {
          if (state is ResumeLoading && _educations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              ResumeSectionProgressBar(currentScreen: AppRouter.resumeEditEducation),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    const ResumeSectionHeader(
                      title: 'Education',
                      icon: Icons.school_outlined,
                      subtitle: 'Your academic qualifications and training',
                    ),

                    if (_educations.isEmpty)
                      ResumeSectionCard(
                        child: Column(
                          children: [
                            Icon(Icons.school_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('No education added yet', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('Tap the button below to add your qualifications',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => _showEducationSheet(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Education'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primary, side: BorderSide(color: primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._educations.map((edu) {
                        final endStr = edu.isCurrent ? 'Present' : (edu.endDate ?? '');
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                  child: Icon(Icons.school_outlined, color: primary, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(edu.degree, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(edu.institution, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                      if (edu.fieldOfStudy != null && edu.fieldOfStudy!.isNotEmpty)
                                        Text(edu.fieldOfStudy!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                                          const SizedBox(width: 4),
                                          Text('${edu.startDate} – $endStr', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') _showEducationSheet(context, existing: edu);
                                    if (v == 'delete') _confirmDelete(context, edu);
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
                                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),

                    ResumeNavButtons(
                      prevRoute: AppRouter.resumeEditExperience,
                      nextRoute: AppRouter.resumeEditSkills,
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
