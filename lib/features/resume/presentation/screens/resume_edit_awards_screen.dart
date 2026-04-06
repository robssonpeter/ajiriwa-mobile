import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit awards / certifications screen
class ResumeEditAwardsScreen extends StatefulWidget {
  const ResumeEditAwardsScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditAwardsScreen> createState() => _ResumeEditAwardsScreenState();
}

class _ResumeEditAwardsScreenState extends State<ResumeEditAwardsScreen> {
  int? _candidateId;
  List<Award> _awards = [];
  Map<String, dynamic> _countries = {};
  List<dynamic> _industries = [];
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    resumeBloc = context.read<ResumeBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'awards'));
    });
  }

  void _showAwardSheet(BuildContext context, {Award? existing}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final issuerCtrl = TextEditingController(text: existing?.issuer ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    DateTime? awardDate = existing?.date != null && existing!.date.isNotEmpty
        ? DateTime.tryParse(existing.date)
        : null;
    String? selectedCountry = existing?.countryId?.toUpperCase();
    int? selectedIndustryId = existing?.industryId;
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
            if (state is AwardAdded || state is AwardUpdated) Navigator.of(ctx).pop();
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
                          Icon(Icons.workspace_premium_outlined, color: primary),
                          const SizedBox(width: 8),
                          Text(
                            existing == null ? 'Add Certification / Award' : 'Edit Certification / Award',
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
                                controller: nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Award / Certification Name *',
                                  prefixIcon: Icon(Icons.workspace_premium_outlined),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: issuerCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Issuing Organisation *',
                                  prefixIcon: Icon(Icons.business_outlined),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 12),
                              // Date
                              GestureDetector(
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: ctx3,
                                    initialDate: awardDate ?? DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (d != null) setSheetState(() => awardDate = d);
                                },
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Date Issued',
                                      prefixIcon: Icon(Icons.calendar_today_outlined),
                                      suffixIcon: Icon(Icons.calendar_today_outlined),
                                    ),
                                    controller: TextEditingController(
                                      text: awardDate != null
                                          ? '${awardDate!.day}/${awardDate!.month}/${awardDate!.year}'
                                          : '',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_countries.isNotEmpty)
                                DropdownButtonFormField<String>(
                                  value: selectedCountry == null
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
                              if (_countries.isNotEmpty) const SizedBox(height: 12),
                              if (_industries.isNotEmpty)
                                DropdownButtonFormField<int>(
                                  value: selectedIndustryId,
                                  decoration: const InputDecoration(
                                    labelText: 'Industry',
                                    prefixIcon: Icon(Icons.category_outlined),
                                  ),
                                  isExpanded: true,
                                  items: _industries.map((ind) {
                                    final m = ind as Map<String, dynamic>;
                                    return DropdownMenuItem<int>(
                                      value: m['id'] as int?,
                                      child: Text(m['name'] as String? ?? '', overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (v) => setSheetState(() => selectedIndustryId = v),
                                ),
                              if (_industries.isNotEmpty) const SizedBox(height: 12),
                              TextFormField(
                                controller: descCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Description (optional)',
                                  prefixIcon: Icon(Icons.notes_outlined),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: isSaving
                                    ? null
                                    : () {
                                        if (formKey.currentState!.validate()) {
                                          setSheetState(() => isSaving = true);
                                          final award = Award(
                                            id: existing?.id,
                                            name: nameCtrl.text,
                                            issuer: issuerCtrl.text,
                                            date: awardDate != null
                                                ? '${awardDate!.year}-${awardDate!.month.toString().padLeft(2, '0')}-${awardDate!.day.toString().padLeft(2, '0')}'
                                                : '',
                                            description: descCtrl.text.isNotEmpty ? descCtrl.text : null,
                                            countryId: selectedCountry?.toLowerCase(),
                                            industryId: selectedIndustryId,
                                          );
                                          if (existing == null) {
                                            resumeBloc.add(AddAward(award: award, candidateId: _candidateId));
                                          } else {
                                            resumeBloc.add(UpdateAward(award: award, candidateId: _candidateId));
                                          }
                                        }
                                      },
                                icon: isSaving
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.save_outlined),
                                label: Text(isSaving ? 'Saving...' : 'Save'),
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

  void _confirmDelete(BuildContext context, Award award) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Award'),
        content: Text('Remove "${award.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              resumeBloc.add(DeleteAward(awardId: award.id!, candidateId: _candidateId));
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
          onPressed: () => context.goNamed(AppRouter.resumeEditLanguage),
        ),
        actions: [ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditAwards)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAwardSheet(context),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Certification'),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            setState(() {
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
              _countries = state.response.countries ?? {};
              _industries = state.response.industries ?? [];
              final list = state.response.data['awards'] as List<dynamic>?;
              if (list != null) {
                _awards = list.map((e) {
                  final m = e as Map<String, dynamic>;
                  return Award(
                    id: m['id'] as int?,
                    name: m['name'] as String? ?? '',
                    issuer: m['issuer'] as String? ?? '',
                    date: m['date'] as String? ?? '',
                    description: m['description'] as String?,
                    countryId: m['country_id'] as String?,
                    country: m['country'] as String?,
                    industryId: m['industry_id'] as int?,
                    industry: m['industry'] as String?,
                  );
                }).toList();
              } else {
                _awards = [];
              }
            });
          } else if (state is AwardAdded) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Certification added!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'awards'));
          } else if (state is AwardUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Certification updated!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'awards'));
          } else if (state is AwardDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Certification removed!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'awards'));
          } else if (state is ResumeError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
          }
        },
        builder: (context, state) {
          if (state is ResumeLoading && _awards.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              ResumeSectionProgressBar(currentScreen: AppRouter.resumeEditAwards),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    const ResumeSectionHeader(
                      title: 'Certifications & Awards',
                      icon: Icons.workspace_premium_outlined,
                      subtitle: 'Professional certifications, awards and achievements',
                    ),

                    if (_awards.isEmpty)
                      ResumeSectionCard(
                        child: Column(
                          children: [
                            Icon(Icons.workspace_premium_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('No certifications added yet',
                                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('Add your professional certifications and awards',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => _showAwardSheet(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Certification'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primary, side: BorderSide(color: primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._awards.map((award) {
                        String dateStr = '';
                        try {
                          if (award.date.isNotEmpty) {
                            final d = DateTime.parse(award.date);
                            dateStr = '${d.day}/${d.month}/${d.year}';
                          }
                        } catch (_) {
                          dateStr = award.date;
                        }

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
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.workspace_premium_outlined, color: Color(0xFFF59E0B), size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(award.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(award.issuer, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                      if (dateStr.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                                            const SizedBox(width: 4),
                                            Text(dateStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                          ],
                                        ),
                                      if (award.industry != null && award.industry!.isNotEmpty)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(award.industry!, style: TextStyle(color: primary, fontSize: 11)),
                                        ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') _showAwardSheet(context, existing: award);
                                    if (v == 'delete') _confirmDelete(context, award);
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
                      prevRoute: AppRouter.resumeEditLanguage,
                      nextRoute: AppRouter.resumeEditReference,
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
