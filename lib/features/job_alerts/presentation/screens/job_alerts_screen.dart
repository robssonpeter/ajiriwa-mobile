import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/job_alert.dart';
import '../bloc/job_alerts_bloc.dart';
import '../bloc/job_alerts_event.dart';
import '../bloc/job_alerts_state.dart';

class JobAlertsScreen extends StatelessWidget {
  const JobAlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobAlertsBloc>()..add(LoadJobAlertsEvent()),
      child: const _JobAlertsView(),
    );
  }
}

class _JobAlertsView extends StatelessWidget {
  const _JobAlertsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New alert',
            onPressed: () => _showAlertForm(context, null),
          ),
        ],
      ),
      body: BlocConsumer<JobAlertsBloc, JobAlertsState>(
        listener: (context, state) {
          if (state is JobAlertSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is JobAlertsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is JobAlertsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = _alertsFrom(state);

          if (alerts.isEmpty && state is! JobAlertsLoading) {
            return _buildEmpty(context);
          }

          return Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    _AlertCard(alert: alerts[index]),
              ),
              if (state is JobAlertsSaving)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<JobAlertsBloc, JobAlertsState>(
        builder: (context, state) {
          final alerts = _alertsFrom(state);
          if (alerts.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _showAlertForm(context, null),
            icon: const Icon(Icons.add),
            label: const Text('New Alert'),
            backgroundColor: AppTheme.primaryColor,
          );
        },
      ),
    );
  }

  List<JobAlert> _alertsFrom(JobAlertsState state) {
    if (state is JobAlertsLoaded) return state.alerts;
    if (state is JobAlertsSaving) return state.alerts;
    if (state is JobAlertSaved) return state.alerts;
    return [];
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No job alerts yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an alert and we\'ll notify you when matching jobs are posted.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAlertForm(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Create Alert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertForm(BuildContext context, JobAlert? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<JobAlertsBloc>(),
        child: _AlertForm(existing: existing),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final JobAlert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: alert.isActive,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    context.read<JobAlertsBloc>().add(UpdateJobAlertEvent(
                          id: alert.id,
                          name: alert.name,
                          keywords: alert.keywords,
                          location: alert.location,
                          jobTypeId: alert.jobTypeId,
                          isRemote: alert.isRemote,
                          isActive: value,
                        ));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (alert.keywords != null && alert.keywords!.isNotEmpty)
                  _Chip(Icons.search, alert.keywords!),
                if (alert.location != null && alert.location!.isNotEmpty)
                  _Chip(Icons.location_on, alert.location!),
                if (alert.jobTypeName != null)
                  _Chip(Icons.work, alert.jobTypeName!),
                if (alert.isRemote)
                  _Chip(Icons.wifi, 'Remote'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEdit(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<JobAlertsBloc>(),
        child: _AlertForm(existing: alert),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Alert'),
        content: Text('Delete "${alert.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<JobAlertsBloc>().add(DeleteJobAlertEvent(alert.id));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14, color: AppTheme.primaryColor),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _AlertForm extends StatefulWidget {
  final JobAlert? existing;
  const _AlertForm({this.existing});

  @override
  State<_AlertForm> createState() => _AlertFormState();
}

class _AlertFormState extends State<_AlertForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _keywordsCtrl;
  late final TextEditingController _locationCtrl;
  bool _isRemote = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _keywordsCtrl = TextEditingController(text: widget.existing?.keywords ?? '');
    _locationCtrl = TextEditingController(text: widget.existing?.location ?? '');
    _isRemote = widget.existing?.isRemote ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _keywordsCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit Job Alert' : 'Create Job Alert',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Alert Name *',
                hintText: 'e.g. Software Jobs in Dar',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _keywordsCtrl,
              decoration: const InputDecoration(
                labelText: 'Keywords',
                hintText: 'e.g. Flutter, Laravel, Python',
                border: OutlineInputBorder(),
                helperText: 'Separate multiple keywords with commas',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'e.g. Dar es Salaam',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remote only'),
              value: _isRemote,
              activeColor: AppTheme.primaryColor,
              onChanged: (v) => setState(() => _isRemote = v),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(isEditing ? 'Update Alert' : 'Create Alert'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);
    final bloc = context.read<JobAlertsBloc>();
    if (widget.existing != null) {
      bloc.add(UpdateJobAlertEvent(
        id: widget.existing!.id,
        name: _nameCtrl.text.trim(),
        keywords: _keywordsCtrl.text.trim().isEmpty ? null : _keywordsCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        isRemote: _isRemote,
        isActive: widget.existing!.isActive,
      ));
    } else {
      bloc.add(CreateJobAlertEvent(
        name: _nameCtrl.text.trim(),
        keywords: _keywordsCtrl.text.trim().isEmpty ? null : _keywordsCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        isRemote: _isRemote,
      ));
    }
  }
}
