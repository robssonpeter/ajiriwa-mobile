import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/resume_edit_navigation_widget.dart';

/// Resume edit reference (referees) screen
class ResumeEditReferenceScreen extends StatefulWidget {
  const ResumeEditReferenceScreen({Key? key}) : super(key: key);

  @override
  State<ResumeEditReferenceScreen> createState() => _ResumeEditReferenceScreenState();
}

class _ResumeEditReferenceScreenState extends State<ResumeEditReferenceScreen> {
  int? _candidateId;
  List<Reference> _references = [];
  late ResumeBloc resumeBloc;

  @override
  void initState() {
    super.initState();
    resumeBloc = context.read<ResumeBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeBloc.add(const GetResumeSection(section: 'reference'));
    });
  }

  void _showReferenceSheet(BuildContext context, {Reference? existing}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final positionCtrl = TextEditingController(text: existing?.position ?? '');
    final companyCtrl = TextEditingController(text: existing?.company ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final relationshipCtrl = TextEditingController(text: existing?.relationship ?? '');
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
            if (state is ReferenceAdded || state is ReferenceUpdated) Navigator.of(ctx).pop();
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
                          Icon(Icons.people_outline, color: primary),
                          const SizedBox(width: 8),
                          Text(
                            existing == null ? 'Add Referee' : 'Edit Referee',
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
                                  labelText: 'Full Name *',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: positionCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Position / Title *',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: companyCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Company / Organisation *',
                                  prefixIcon: Icon(Icons.business_outlined),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: emailCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: phoneCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: relationshipCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Relationship',
                                  prefixIcon: Icon(Icons.handshake_outlined),
                                  hintText: 'e.g. Former Manager, Colleague',
                                ),
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: isSaving
                                    ? null
                                    : () {
                                        if (formKey.currentState!.validate()) {
                                          setSheetState(() => isSaving = true);
                                          final ref = Reference(
                                            id: existing?.id,
                                            name: nameCtrl.text,
                                            position: positionCtrl.text,
                                            company: companyCtrl.text,
                                            email: emailCtrl.text.isNotEmpty ? emailCtrl.text : null,
                                            phone: phoneCtrl.text.isNotEmpty ? phoneCtrl.text : null,
                                            relationship: relationshipCtrl.text.isNotEmpty ? relationshipCtrl.text : null,
                                          );
                                          if (existing == null) {
                                            resumeBloc.add(AddReference(reference: ref, candidateId: _candidateId));
                                          } else {
                                            resumeBloc.add(UpdateReference(reference: ref, candidateId: _candidateId));
                                          }
                                        }
                                      },
                                icon: isSaving
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.save_outlined),
                                label: Text(isSaving ? 'Saving...' : 'Save Referee'),
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

  void _confirmDelete(BuildContext context, Reference ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Referee'),
        content: Text('Remove "${ref.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              resumeBloc.add(DeleteReference(referenceId: ref.id!, candidateId: _candidateId));
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
          onPressed: () => context.goNamed(AppRouter.resumeEditAwards),
        ),
        actions: [ResumeEditNavigationWidget(currentScreen: AppRouter.resumeEditReference)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReferenceSheet(context),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Referee'),
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listener: (context, state) {
          if (state is ResumeSectionLoaded) {
            setState(() {
              _candidateId = state.response.data['candidate_id'] as int? ?? state.response.selectedCandidateId;
              final list = state.response.data['referees'] as List<dynamic>?;
              if (list != null) {
                _references = list.map((e) {
                  final m = e as Map<String, dynamic>;
                  return Reference(
                    id: m['id'] as int?,
                    name: m['name'] as String? ?? '',
                    position: m['position'] as String? ?? '',
                    company: m['company'] as String? ?? '',
                    email: m['email'] as String?,
                    phone: m['phone'] as String?,
                    relationship: m['relationship'] as String?,
                  );
                }).toList();
              } else {
                _references = [];
              }
            });
          } else if (state is ReferenceAdded) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Referee added!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'reference'));
          } else if (state is ReferenceUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Referee updated!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'reference'));
          } else if (state is ReferenceDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Referee removed!')]),
              backgroundColor: primary, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
            resumeBloc.add(const GetResumeSection(section: 'reference'));
          } else if (state is ResumeError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
          }
        },
        builder: (context, state) {
          if (state is ResumeLoading && _references.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              ResumeSectionProgressBar(currentScreen: AppRouter.resumeEditReference),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    const ResumeSectionHeader(
                      title: 'Referees',
                      icon: Icons.people_outline,
                      subtitle: 'Professional references who can vouch for you',
                    ),

                    if (_references.isEmpty)
                      ResumeSectionCard(
                        child: Column(
                          children: [
                            Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('No referees added yet', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('Add professional references who can vouch for your work',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => _showReferenceSheet(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Referee'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primary, side: BorderSide(color: primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._references.map((ref) => Container(
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
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: primary.withOpacity(0.1),
                                child: Text(
                                  ref.name.isNotEmpty ? ref.name[0].toUpperCase() : '?',
                                  style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ref.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('${ref.position} · ${ref.company}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                                    if (ref.relationship != null && ref.relationship!.isNotEmpty)
                                      Text(ref.relationship!, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (ref.email != null && ref.email!.isNotEmpty) ...[
                                          Icon(Icons.email_outlined, size: 12, color: Colors.grey.shade400),
                                          const SizedBox(width: 3),
                                          Flexible(child: Text(ref.email!, style: TextStyle(color: Colors.grey.shade500, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                        ],
                                        if (ref.phone != null && ref.phone!.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Icon(Icons.phone_outlined, size: 12, color: Colors.grey.shade400),
                                          const SizedBox(width: 3),
                                          Text(ref.phone!, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'edit') _showReferenceSheet(context, existing: ref);
                                  if (v == 'delete') _confirmDelete(context, ref);
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
                                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )).toList(),

                    ResumeNavButtons(
                      prevRoute: AppRouter.resumeEditAwards,
                    ),

                    // Done button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ElevatedButton.icon(
                        onPressed: () => context.goNamed(AppRouter.profile),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Done – View Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
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
