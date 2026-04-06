import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit skills screen
class ResumeEditSkillsScreen extends StatefulWidget {
  const ResumeEditSkillsScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditSkillsScreen> createState() => _ResumeEditSkillsScreenState();
}

class _ResumeEditSkillsScreenState extends State<ResumeEditSkillsScreen> {
  int? _candidateId;
  List<Skill> _skills = [];
  List<dynamic> _skillLevels = [];
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    resumeBloc = context.read<ResumeBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'skills'));
    });
  }

  void _showSkillSheet(BuildContext context, {Skill? existing}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    int? selectedLevelId = existing?.levelId;
    int rating = existing?.rating ?? 3;
    bool isSaving = false;
    final primary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: resumeBloc,
        child: BlocListener<ResumeBloc, ResumeState>(
          listener: (_, state) {
            if (state is SkillAdded || state is SkillUpdated) Navigator.of(ctx).pop();
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
                          Icon(Icons.star_outline, color: primary),
                          const SizedBox(width: 8),
                          Text(
                            existing == null ? 'Add Skill' : 'Edit Skill',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Skill Name *',
                                prefixIcon: Icon(Icons.star_outline),
                                hintText: 'e.g. Flutter, Python, Project Management',
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 12),
                            if (_skillLevels.isNotEmpty)
                              DropdownButtonFormField<int>(
                                value: selectedLevelId,
                                decoration: const InputDecoration(
                                  labelText: 'Proficiency Level',
                                  prefixIcon: Icon(Icons.bar_chart_outlined),
                                ),
                                isExpanded: true,
                                items: _skillLevels.map((level) {
                                  final l = level as Map<String, dynamic>;
                                  return DropdownMenuItem<int>(
                                    value: l['id'] as int?,
                                    child: Text(l['name'] as String? ?? ''),
                                  );
                                }).toList(),
                                onChanged: (v) => setSheetState(() => selectedLevelId = v),
                              ),
                            if (_skillLevels.isNotEmpty) const SizedBox(height: 12),
                            Text('Rating: $rating / 5', style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 13)),
                            Slider(
                              value: rating.toDouble(),
                              min: 1, max: 5, divisions: 4,
                              activeColor: primary,
                              label: rating.toString(),
                              onChanged: (v) => setSheetState(() => rating = v.round()),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: isSaving
                                  ? null
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        setSheetState(() => isSaving = true);
                                        final skill = Skill(
                                          id: existing?.id,
                                          name: nameCtrl.text,
                                          levelId: selectedLevelId,
                                          rating: rating,
                                        );
                                        if (existing == null) {
                                          resumeBloc.add(AddSkill(skill: skill, candidateId: _candidateId));
                                        } else {
                                          resumeBloc.add(UpdateSkill(skill: skill, candidateId: _candidateId));
                                        }
                                      }
                                    },
                              icon: isSaving
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.save_outlined),
                              label: Text(isSaving ? 'Saving...' : 'Save Skill'),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Skill skill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Skill'),
        content: Text('Remove "${skill.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              resumeBloc.add(DeleteSkill(skillId: skill.id!, candidateId: _candidateId));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDots(int rating, Color primary) {
    return Row(
      children: List.generate(5, (i) => Padding(
        padding: const EdgeInsets.only(right: 3),
        child: Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < rating ? primary : primary.withOpacity(0.2),
          ),
        ),
      )),
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
          onPressed: () => context.goNamed(AppRouter.resumeEditEducation),
        ),
        actions: [ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditSkills)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSkillSheet(context),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Skill'),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            setState(() {
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
              _skillLevels = state.response.data['skill_levels'] as List<dynamic>? ?? [];
              final list = state.response.data['skills'] as List<dynamic>?;
              if (list != null) {
                _skills = list.map((e) {
                  final m = e as Map<String, dynamic>;
                  return Skill(
                    id: m['id'] as int?,
                    name: m['name'] as String? ?? '',
                    levelId: m['skill_level_id'] as int?,
                    level: m['skill_level'] as String?,
                    rating: m['rating'] as int?,
                    ratingLabel: m['rating_label'] as String?,
                  );
                }).toList();
              } else {
                _skills = [];
              }
            });
          } else if (state is SkillAdded) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Skill added!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'skills'));
          } else if (state is SkillUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Skill updated!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'skills'));
          } else if (state is SkillDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Skill removed!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'skills'));
          } else if (state is ResumeError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
          }
        },
        builder: (context, state) {
          if (state is ResumeLoading && _skills.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              ResumeSectionProgressBar(currentScreen: AppRouter.resumeEditSkills),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    const ResumeSectionHeader(
                      title: 'Skills',
                      icon: Icons.star_outline,
                      subtitle: 'Highlight your key professional skills',
                    ),

                    if (_skills.isEmpty)
                      ResumeSectionCard(
                        child: Column(
                          children: [
                            Icon(Icons.star_border_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('No skills added yet', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => _showSkillSheet(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Skill'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primary, side: BorderSide(color: primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ResumeSectionCard(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _skills.map((skill) {
                            return GestureDetector(
                              onTap: () => _showSkillSheet(context, existing: skill),
                              onLongPress: () => _confirmDelete(context, skill),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: primary.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(skill.name, style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 13)),
                                    if (skill.rating != null) ...[
                                      const SizedBox(width: 6),
                                      _buildRatingDots(skill.rating!, primary),
                                    ],
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _confirmDelete(context, skill),
                                      child: Icon(Icons.close, size: 14, color: primary.withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    if (_skills.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          'Tap a skill to edit • Long press or tap × to delete',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    ResumeNavButtons(
                      prevRoute: AppRouter.resumeEditEducation,
                      nextRoute: AppRouter.resumeEditLanguage,
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
