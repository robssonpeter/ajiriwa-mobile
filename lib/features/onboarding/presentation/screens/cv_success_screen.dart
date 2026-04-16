import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';

class CvSuccessScreen extends StatefulWidget {
  final int profileCompletion;
  const CvSuccessScreen({super.key, required this.profileCompletion});

  @override
  State<CvSuccessScreen> createState() => _CvSuccessScreenState();
}

class _CvSuccessScreenState extends State<CvSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = Tween<double>(begin: 0, end: widget.profileCompletion / 100)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    // Start after a short delay so the screen feels intentional
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color get _completionColor {
    if (widget.profileCompletion >= 80) return Colors.green;
    if (widget.profileCompletion >= 50) return Colors.orange;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Success icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 56),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Profile set up!',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your CV has been analysed and your profile has been filled in.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Animated completion gauge
              Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (context, _) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: _progressAnim.value,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            color: _completionColor,
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(_progressAnim.value * 100).round()}%',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _completionColor,
                                  ),
                                ),
                                Text(
                                  'complete',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (widget.profileCompletion < 80) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add more details in your profile to increase your chances of being found by employers.',
                          style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Spacer(),

              FilledButton.icon(
                onPressed: () => context.go(AppRouter.jobsPath),
                icon: const Icon(Icons.search),
                label: const Text('Browse Jobs'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRouter.resumeEditPath),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Review & Edit Profile'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
