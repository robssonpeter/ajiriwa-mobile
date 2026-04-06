import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../bloc/bloc.dart';

/// Resume view screen using WebView - displays the user's resume
class ResumeViewScreen extends StatefulWidget {
  const ResumeViewScreen({Key? key}) : super(key: key);

  @override
  State<ResumeViewScreen> createState() => _ResumeViewScreenState();
}

class _ResumeViewScreenState extends State<ResumeViewScreen> {
  // Single WebView controller (no pagination needed)
  late final WebViewController _webViewController;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // Available CV templates
  List<Map<String, dynamic>> _templates = [];

  // Currently selected template
  String _currentTemplateKey = 'material'; // Default template

  @override
  void initState() {
    super.initState();

    // Initialize single WebView controller
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }

            // CRITICAL: DO NOT inject CSS - backend handles everything
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Error: ${error.description}';
                _isLoading = false;
              });
            }

            if (_retryCount < _maxRetries) {
              _retryCount++;
              _loadResumeUrl();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    // Fetch resume data to get templates
    context.read<ResumeBloc>().add(const GetResumeData());

    // Load the resume URL
    _loadResumeUrl();
  }

  /// Check if the device has internet connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> _loadResumeUrl({String? templateKey, int retryCount = 0}) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Check internet connectivity first
      final hasConnectivity = await _checkConnectivity();
      if (!hasConnectivity) {
        setState(() {
          _hasError = true;
          _errorMessage = 'No internet connection. Please check your network settings and try again.';
          _isLoading = false;
        });
        return;
      }

      // Get the authentication token
      final apiClient = sl<ApiClient>();
      final token = await apiClient.getToken();

      if (token == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Authentication token not found. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      // Set up headers with authentication token
      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'text/html',
      };

      // Use the provided template key or the current one
      final template = templateKey ?? _currentTemplateKey;

      // Update the current template key if a new one is provided
      if (templateKey != null) {
        setState(() {
          _currentTemplateKey = templateKey;
        });
      }

      // CRITICAL: Disable pagination for mobile app
      final uri = Uri.parse('${ApiClient.baseUrl}/my-resume/render').replace(
        queryParameters: {
          'template': template,
          'paginate': '0', // Disable pagination for mobile
          'mobile_app': '1', // Flag to indicate mobile app request
          'scale': '200', // Convert to string to avoid type error
        },
      );

      await _webViewController.loadRequest(
        uri,
        headers: headers,
      );
    } catch (e) {
      // Implement retry logic with exponential backoff
      if (retryCount < _maxRetries) {
        final delaySeconds = math.min(
          math.pow(2, retryCount).toInt(),
          10,
        );

        final delay = Duration(seconds: delaySeconds);
        debugPrint('Retrying after $delay (attempt ${retryCount + 1}/$_maxRetries)');

        await Future.delayed(delay);
        return _loadResumeUrl(templateKey: templateKey, retryCount: retryCount + 1);
      }

      // Show specific error messages
      setState(() {
        _hasError = true;

        if (e is SocketException) {
          _errorMessage = 'Network error: Unable to connect to server. Please check your internet connection.';
        } else if (e is TimeoutException) {
          _errorMessage = 'Request timed out. The server is taking too long to respond.';
        } else if (e.toString().contains('401')) {
          _errorMessage = 'Authentication error: Your session has expired. Please log in again.';
          sl<ApiClient>().deleteToken();
        } else if (e.toString().contains('403')) {
          _errorMessage = 'Access denied: You do not have permission to view this resume.';
        } else if (e.toString().contains('404')) {
          _errorMessage = 'Resume not found: The requested resume does not exist.';
        } else if (e.toString().contains('500')) {
          _errorMessage = 'Server error: Something went wrong on our servers. Please try again later.';
        } else {
          _errorMessage = 'Error loading resume: ${e.toString()}';
        }

        _isLoading = false;
      });
      debugPrint('Error loading resume URL: $e');
    }
  }

  /// Download the resume as a PDF
  Future<void> _downloadResume() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.0,
            ),
            SizedBox(width: 16),
            Text('Preparing download...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final hasConnectivity = await _checkConnectivity();
      if (!hasConnectivity) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Please check your network settings and try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final apiClient = sl<ApiClient>();
      final token = await apiClient.getToken();

      if (token == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token not found. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final uri = Uri.parse('${ApiClient.baseUrl}/my-resume/download').replace(
        queryParameters: {
          'template': _currentTemplateKey,
          'format': 'pdf',
          'paper_size': 'a4',
          'paginate': '1', // Enable pagination for PDF
        },
      );

      final downloadUrl = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'token': token,
        },
      );

      if (await canLaunchUrl(downloadUrl)) {
        await launchUrl(downloadUrl, mode: LaunchMode.externalApplication);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume download started'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not start download. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading resume: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error downloading resume: $e');
    }
  }

  void _fetchResumeHtml() {
    _retryCount = 0;
    _loadResumeUrl(templateKey: _currentTemplateKey);
  }

  void _setDefaultTemplates() {
    setState(() {
      _templates = [
        {'key': 'material', 'name': 'Material', 'thumbnail': '', 'owned': true},
        {'key': 'stockholm', 'name': 'Stockholm', 'thumbnail': '', 'owned': true},
        {'key': 'stylish', 'name': 'Stylish', 'thumbnail': '', 'owned': true},
        {'key': 'toronto', 'name': 'Toronto', 'thumbnail': '', 'owned': true},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResumeBloc, ResumeState>(
      listener: (context, state) {
        if (state is ResumeDataLoaded) {
          if (state.resumeData.template != null) {
            setState(() {
              _currentTemplateKey = state.resumeData.template['slug'] as String? ??
                  state.resumeData.template['key'] as String? ?? 'material';
            });
          }

          final rawData = state.resumeData as dynamic;
          if (rawData is Map && rawData.containsKey('templates')) {
            final templatesData = rawData['templates'] as List<dynamic>;
            setState(() {
              _templates = templatesData.map<Map<String, dynamic>>((template) {
                return {
                  'key': template['slug'] as String,
                  'name': template['name'] as String,
                  'thumbnail': template['thumbnail'] as String? ?? '',
                  'price': template['price'],
                  'currency': template['currency'],
                  'owned': template['owned'] as bool,
                };
              }).toList();
            });

            if (_templates.isEmpty) {
              _setDefaultTemplates();
            }
          } else {
            _setDefaultTemplates();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Resume'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchResumeHtml,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomActions(),
      ),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading resume',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchResumeHtml,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show WebView with scrollable content
    return Stack(
      children: [
        // WebView takes full screen and scrolls naturally
        WebViewWidget(
          controller: _webViewController,
        ),

        // Loading indicator overlay
        if (_isLoading)
          Container(
            color: Colors.white.withOpacity(0.9),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading resume...'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _downloadResume,
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showThemeSelectionDialog,
                icon: const Icon(Icons.color_lens),
                label: const Text('Change Theme'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select CV Theme'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                final isSelected = template['key'] == _currentTemplateKey;

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _loadResumeUrl(templateKey: template['key']);
                  },
                  child: Card(
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            child: Container(
                              color: Colors.grey[200],
                              child: template['thumbnail'] != null && template['thumbnail'].toString().isNotEmpty
                                  ? Image.network(
                                template['thumbnail'].toString(),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.description,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                },
                              )
                                  : Center(
                                child: Icon(
                                  Icons.description,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            template['name'],
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Theme.of(context).colorScheme.primary : null,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
