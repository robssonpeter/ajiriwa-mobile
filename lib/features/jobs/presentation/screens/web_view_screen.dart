import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../bloc/bloc.dart';
import '../../../../core/utils/app_logger.dart';

/// WebView screen to display external URLs within the app
class WebViewScreen extends StatefulWidget {
  /// The URL to display
  final String url;

  /// The title to display in the app bar
  final String title;

  /// Job ID for the job being applied to
  final int? jobId;

  /// Application ID from the intent recording
  final int? applicationId;

  /// Constructor
  const WebViewScreen({
    Key? key,
    required this.url,
    required this.title,
    this.jobId,
    this.applicationId,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _hasError = false;
  int? _applicationId;

  @override
  void initState() {
    super.initState();
    appLogger.d('WebViewScreen.initState called');
    appLogger.d('URL to load: ${widget.url}');
    appLogger.d('JobId: ${widget.jobId}');
    appLogger.d('ApplicationId: ${widget.applicationId}');

    // Initialize WebView controller with a simpler approach
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            appLogger.d('WebView loading progress: $progress%');
          },
          onPageStarted: (String url) {
            appLogger.d('WebView onPageStarted: $url');
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _errorMessage = '';
              });
            }
          },
          onPageFinished: (String url) {
            appLogger.d('WebView onPageFinished: $url');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            appLogger.d('WebView error: ${error.description}');
            appLogger.d('WebView error code: ${error.errorCode}');
            appLogger.d('WebView error type: ${error.errorType}');

            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
                _errorMessage = 'Error: ${error.description} (Code: ${error.errorCode})';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    // If applicationId is provided, use it
    if (widget.applicationId != null) {
      _applicationId = widget.applicationId;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // If we don't have an applicationId yet, listen for the ApplyExternalIntentRecordedState
    if (_applicationId == null && widget.jobId != null) {
      context.read<ApplyBloc>().stream.listen((state) {
        if (state is ApplyExternalIntentRecordedState && state.response.applicationId != null) {
          appLogger.d('Received ApplyExternalIntentRecordedState with applicationId: ${state.response.applicationId}');
          setState(() {
            _applicationId = state.response.applicationId;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Only show the confirmation dialog if we have both jobId and applicationId
        if (widget.jobId != null && _applicationId != null) {
          final bool? didApply = await _showApplyConfirmationDialog(context);
          if (didApply == true) {
            // User confirmed they applied, mark the application as applied
            context.read<ApplyBloc>().add(
              ApplyExternalMarkedAsApplied(_applicationId!),
            );
          }
          // Allow the navigation to proceed regardless of the answer
          return true;
        }
        // If we don't have jobId or applicationId, just let the navigation proceed
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                appLogger.d('Refreshing WebView');
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  _errorMessage = '';
                });
                _controller.reload();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            if (!_hasError)
              WebViewWidget(controller: _controller),
            if (_hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load webpage',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          appLogger.d('Retrying WebView initialization');
                          setState(() {
                            _isLoading = true;
                            _hasError = false;
                            _errorMessage = '';
                          });

                          // Reload the WebView
                          _controller.reload();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoading && !_hasError)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  /// Show a confirmation dialog asking if the user applied
  Future<bool?> _showApplyConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Did you apply?'),
        content: const Text('Did you complete the application on the external website?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User did not apply
            },
            child: const Text('No, I didn\'t apply'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User did apply
            },
            child: const Text('Yes, I applied'),
          ),
        ],
      ),
    );
  }
}
