import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class CvUploadScreen extends StatefulWidget {
  final int candidateId;
  const CvUploadScreen({super.key, required this.candidateId});

  @override
  State<CvUploadScreen> createState() => _CvUploadScreenState();
}

class _CvUploadScreenState extends State<CvUploadScreen> {
  File? _pickedFile;
  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  void _upload() {
    if (_pickedFile == null) return;
    context.read<OnboardingBloc>().add(
          UploadCvEvent(file: _pickedFile!, candidateId: widget.candidateId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is CvUploaded) {
          // Immediately kick off parsing
          context.read<OnboardingBloc>().add(ParseCvEvent(
                fileUrl: state.fileUrl,
                candidateId: state.candidateId,
                mediaId: state.mediaId,
              ));
        } else if (state is CvParsed) {
          context.pushReplacement(
            AppRouter.onboardingSuccessPath,
            extra: {'profileCompletion': state.profileCompletion},
          );
        } else if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Your CV'),
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            final isBusy = state is CvUploading || state is CvUploaded || state is CvParsing;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _buildStepIndicator(state),
                  const SizedBox(height: 40),

                  // Drop zone / file picker
                  GestureDetector(
                    onTap: isBusy ? null : _pickFile,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 180,
                      decoration: BoxDecoration(
                        color: _pickedFile != null
                            ? Theme.of(context).colorScheme.primary.withAlpha(15)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _pickedFile != null
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: _pickedFile != null
                          ? _buildFilePreview()
                          : _buildDropZone(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Supported formats: PDF, DOC, DOCX (max 10 MB)',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),

                  // Upload button
                  FilledButton.icon(
                    onPressed: (_pickedFile != null && !isBusy) ? _upload : null,
                    icon: isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cloud_upload_rounded),
                    label: Text(isBusy ? _busyLabel(state) : 'Upload & Analyse'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isBusy ? null : () => context.go(AppRouter.dashboardPath),
                    child: const Text('Skip for now'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _busyLabel(OnboardingState state) {
    if (state is CvUploading) return 'Uploading…';
    if (state is CvUploaded || state is CvParsing) return 'Analysing with AI…';
    return 'Processing…';
  }

  Widget _buildDropZone() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.upload_file_rounded, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        const Text('Tap to select your CV', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('PDF, DOC or DOCX', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      ],
    );
  }

  Widget _buildFilePreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.description_rounded,
            size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _fileName ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.swap_horiz, size: 16),
          label: const Text('Change file'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(OnboardingState state) {
    final isUploading = state is CvUploading;
    final isParsing = state is CvUploaded || state is CvParsing;

    return Row(
      children: [
        _Step(number: 1, label: 'Upload', active: isUploading, done: isParsing || state is CvParsed),
        Expanded(
          child: Divider(
            color: (isParsing || state is CvParsed) ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            thickness: 2,
          ),
        ),
        _Step(number: 2, label: 'AI Parse', active: isParsing, done: state is CvParsed),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String label;
  final bool active;
  final bool done;

  const _Step({required this.number, required this.label, required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    final color = (active || done) ? Theme.of(context).colorScheme.primary : Colors.grey.shade300;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
