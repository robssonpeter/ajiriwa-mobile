import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit language screen
class ResumeEditLanguageScreen extends StatefulWidget {
  const ResumeEditLanguageScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditLanguageScreen> createState() => _ResumeEditLanguageScreenState();
}

class _ResumeEditLanguageScreenState extends State<ResumeEditLanguageScreen> {
  int? _candidateId;
  List<Language> _languages = [];
  List<dynamic> _languageLevels = [];
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    resumeBloc = context.read<ResumeBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'language'));
    });
  }

  void _showLanguageSheet(BuildContext context, {Language? existing}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    int? selectedLevelId = existing?.levelId;
    int listening = existing?.listening ?? 3;
    int speaking = existing?.speaking ?? 3;
    int reading = existing?.reading ?? 3;
    int writing = existing?.writing ?? 3;
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
            if (state is LanguageAdded || state is LanguageUpdated) Navigator.of(ctx).pop();
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
                          Icon(Icons.language_outlined, color: primary),
                          const SizedBox(width: 8),
                          Text(
                            existing == null ? 'Add Language' : 'Edit Language',
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Language *',
                                  prefixIcon: Icon(Icons.language_outlined),
                                  hintText: 'e.g. English, French, Swahili',
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 12),
                              if (_languageLevels.isNotEmpty)
                                DropdownButtonFormField<int>(
                                  value: selectedLevelId,
                                  decoration: const InputDecoration(
                                    labelText: 'Overall Level',
                                    prefixIcon: Icon(Icons.bar_chart_outlined),
                                  ),
                                  isExpanded: true,
                                  items: _languageLevels.map((level) {
                                    final l = level as Map<String, dynamic>;
                                    return DropdownMenuItem<int>(
                                      value: l['id'] as int?,
                                      child: Text(l['name'] as String? ?? ''),
                                    );
                                  }).toList(),
                                  onChanged: (v) => setSheetState(() => selectedLevelId = v),
                                ),
                              if (_languageLevels.isNotEmpty) const SizedBox(height: 16),
                              Text('Proficiency Breakdown', style: TextStyle(fontWeight: FontWeight.w600, color: primary, fontSize: 13)),
                              const SizedBox(height: 8),
                              _buildSkillSlider('Listening', listening, primary, (v) => setSheetState(() => listening = v)),
                              _buildSkillSlider('Speaking', speaking, primary, (v) => setSheetState(() => speaking = v)),
                              _buildSkillSlider('Reading', reading, primary, (v) => setSheetState(() => reading = v)),
                              _buildSkillSlider('Writing', writing, primary, (v) => setSheetState(() => writing = v)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: isSaving
                                    ? null
                                    : () {
                                        if (formKey.currentState!.validate()) {
                                          setSheetState(() => isSaving = true);
                                          final lang = Language(
                                            id: existing?.id,
                                            name: nameCtrl.text,
                                            levelId: selectedLevelId,
                                            listening: listening,
                                            speaking: speaking,
                                            reading: reading,
                                            writing: writing,
                                          );
                                          if (existing == null) {
                                            resumeBloc.add(AddLanguage(language: lang, candidateId: _candidateId));
                                          } else {
                                            resumeBloc.add(UpdateLanguage(language: lang, candidateId: _candidateId));
                                          }
                                        }
                                      },
                                icon: isSaving
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.save_outlined),
                                label: Text(isSaving ? 'Saving...' : 'Save Language'),
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

  Widget _buildSkillSlider(String label, int value, Color primary, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13))),
          Expanded(
            child: Slider(
              value: value.toDouble(),
              min: 1, max: 5, divisions: 4,
              activeColor: primary,
              label: value.toString(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          SizedBox(width: 24, child: Text('$value', style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Language lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Language'),
        content: Text('Remove "${lang.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              resumeBloc.add(DeleteLanguage(languageId: lang.id!, candidateId: _candidateId));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProficiencyBar(int value, Color primary) {
    return Row(
      children: List.generate(5, (i) => Expanded(
        child: Container(
          height: 4,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: i < value ? primary : primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(2),
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
          onPressed: () => context.goNamed(AppRouter.resumeEditSkills),
        ),
        actions: [ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditLanguage)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLanguageSheet(context),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Language'),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            setState(() {
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
              _languageLevels = state.response.data['language_levels'] as List<dynamic>? ?? [];
              final list = state.response.data['languages'] as List<dynamic>?;
              if (list != null) {
                _languages = list.map((e) {
                  final m = e as Map<String, dynamic>;
                  return Language(
                    id: m['id'] as int?,
                    name: m['name'] as String? ?? '',
                    levelId: m['language_level_id'] as int?,
                    level: m['language_level'] as String?,
                    listening: m['listening'] as int?,
                    speaking: m['speaking'] as int?,
                    reading: m['reading'] as int?,
                    writing: m['writing'] as int?,
                  );
                }).toList();
              } else {
                _languages = [];
              }
            });
          } else if (state is LanguageAdded) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Language added!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'language'));
          } else if (state is LanguageUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Language updated!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'language'));
          } else if (state is LanguageDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Language removed!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'language'));
          } else if (state is ResumeError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
          }
        },
        builder: (context, state) {
          if (state is ResumeLoading && _languages.isEmpty) {
            return const ResumeEditSkeleton();
          }

          return Column(
            children: [
              ResumeSectionProgressBar(currentScreen: AppRouter.resumeEditLanguage),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    const ResumeSectionHeader(
                      title: 'Languages',
                      icon: Icons.language_outlined,
                      subtitle: 'Languages you speak and your proficiency',
                    ),

                    if (_languages.isEmpty)
                      ResumeSectionCard(
                        child: Column(
                          children: [
                            Icon(Icons.language_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('No languages added yet', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => _showLanguageSheet(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Language'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primary, side: BorderSide(color: primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._languages.map((lang) => Container(
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
                                    child: Icon(Icons.language_outlined, color: primary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(lang.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        if (lang.level != null)
                                          Text(lang.level!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (v) {
                                      if (v == 'edit') _showLanguageSheet(context, existing: lang);
                                      if (v == 'delete') _confirmDelete(context, lang);
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
                                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                                    ],
                                  ),
                                ],
                              ),
                              if (lang.listening != null || lang.speaking != null) ...[
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(child: _buildMiniSkill('Listening', lang.listening ?? 0, primary)),
                                    Expanded(child: _buildMiniSkill('Speaking', lang.speaking ?? 0, primary)),
                                    Expanded(child: _buildMiniSkill('Reading', lang.reading ?? 0, primary)),
                                    Expanded(child: _buildMiniSkill('Writing', lang.writing ?? 0, primary)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      )).toList(),

                    ResumeNavButtons(
                      prevRoute: AppRouter.resumeEditSkills,
                      nextRoute: AppRouter.resumeEditAwards,
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

  Widget _buildMiniSkill(String label, int value, Color primary) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        _buildProficiencyBar(value, primary),
        const SizedBox(height: 2),
        Text('$value/5', style: TextStyle(fontSize: 10, color: primary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
