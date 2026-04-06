import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/subscription_plan.dart';
import '../bloc/cv_optimization_bloc.dart';
import '../bloc/cv_optimization_event.dart';
import '../bloc/cv_optimization_state.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CvOptimizationBloc>().add(const LoadSubscriptionPlans());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Subscription Plans',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
      ),
      body: BlocConsumer<CvOptimizationBloc, CvOptimizationState>(
        listener: (context, state) {
          if (state is PaymentInitiated) {
            if (state.paymentUrl.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<CvOptimizationBloc>(),
                  child: PaymentWebViewScreen(
                    paymentUrl: state.paymentUrl,
                    trackingId: state.trackingId,
                  ),
                ),
              ));
            }
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionPlansLoading || state is PaymentInitiating) {
            return _buildSkeleton();
          }
          if (state is SubscriptionPlansLoaded) {
            return _buildPlansList(context, state.plans);
          }
          if (state is PaymentError) {
            return _buildError(context, state.message);
          }
          return _buildSkeleton();
        },
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, List<SubscriptionPlan> plans) {
    final candidatePlans = plans.where((p) =>
        p.userType == null || p.userType == 'candidate' || p.userType == 'both').toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildPlanCard(context, candidatePlans[index], index),
              childCount: candidatePlans.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.primaryColor, size: 32),
          ),
          const SizedBox(height: 14),
          const Text('Unlock Premium Features',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            'Get unlimited CV optimizations, AI cover letters, and more with a premium plan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan, int index) {
    final isPopular = index == 1;
    final price = plan.effectivePrice;
    final hasOffer = plan.offerPrice != null && plan.offerPrice! < plan.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPopular
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: isPopular
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: const Text('MOST POPULAR',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                          if (plan.offerName != null)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(plan.offerName!,
                                  style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasOffer)
                          Text('KES ${plan.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF),
                                  decoration: TextDecoration.lineThrough)),
                        Text('KES ${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                        const Text('/month', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ],
                ),
                if (plan.yearlyPrice != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.savings_rounded, size: 14, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Text('KES ${plan.yearlyPrice!.toStringAsFixed(0)}/year — Save more!',
                            style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
                if (plan.features.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 12),
                  ...plan.features.take(6).map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(f,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.read<CvOptimizationBloc>().add(InitiatePayment(plan.id)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? AppTheme.primaryColor : const Color(0xFF1A1A2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    child: Text('Subscribe to ${plan.name}'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<CvOptimizationBloc>().add(const LoadSubscriptionPlans()),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(height: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 16),
            ...List.generate(3, (_) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 260,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            )),
          ],
        ),
      ),
    );
  }
}

// Payment WebView Screen
class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String trackingId;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.trackingId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (url) {
          setState(() => _isLoading = false);
          // Detect return from payment gateway
          if (url.contains('payment_status') || url.contains('OrderTrackingId')) {
            _handlePaymentReturn(url);
          }
        },
        onNavigationRequest: (request) {
          // Allow all navigation within the payment flow
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handlePaymentReturn(String url) {
    final uri = Uri.parse(url);
    final trackingId = uri.queryParameters['OrderTrackingId'] ??
        uri.queryParameters['tracking_id'] ??
        widget.trackingId;
    final status = uri.queryParameters['payment_status'] ?? '';

    if (status.toLowerCase() == 'completed' || status.toLowerCase() == 'success') {
      _showPaymentResult(true, 'Payment Successful!', 'Your subscription has been activated.');
    } else if (status.isNotEmpty) {
      context.read<CvOptimizationBloc>().add(CheckPaymentStatus(trackingId));
    }
  }

  void _showPaymentResult(bool success, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              size: 56,
              color: success ? AppTheme.primaryColor : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CvOptimizationBloc, CvOptimizationState>(
      listener: (context, state) {
        if (state is PaymentStatusChecked) {
          _showPaymentResult(
            state.isCompleted,
            state.isCompleted ? 'Payment Successful!' : 'Payment Pending',
            state.isCompleted
                ? 'Your subscription has been activated.'
                : 'Your payment status: ${state.status}. Please check back later.',
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => _confirmExit(context),
          ),
          title: const Text('Secure Payment',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
          actions: [
            if (!_isLoading)
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B7280)),
                onPressed: () => _controller.reload(),
              ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: 16),
                    Text('Loading secure payment...', style: TextStyle(color: Color(0xFF6B7280))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Payment?'),
        content: const Text('Are you sure you want to exit? Your payment may not be completed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Stay')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop();
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
