import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
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

  // Polling for download
  Timer? _downloadPollingTimer;
  int _downloadTries = 0;
  static const int _maxDownloadTries = 12;

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
    if (_isLoading) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.0,
            ),
            SizedBox(width: 16),
            Text('Checking resume status...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final hasConnectivity = await _checkConnectivity();
      if (!hasConnectivity) {
        _showErrorSnackBar('No internet connection. Please check your network settings.');
        return;
      }

      final apiClient = sl<ApiClient>();
      final token = await apiClient.getToken();

      if (token == null) {
        _showErrorSnackBar('Authentication token not found. Please log in again.');
        return;
      }

      // 1. Check if PDF exists via /api/v1/my-resume
      final response = await apiClient.get('/my-resume');

      if (response != null && response['resume_pdf'] != null) {
        final resumePdf = response['resume_pdf'];
        final bool exists = resumePdf['exists'] ?? false;
        final String? downloadUrl = resumePdf['download_url'];

        if (exists && downloadUrl != null) {
          // PDF is ready, trigger download
          _triggerDownload(downloadUrl, token);
        } else {
          // PDF is not ready, start polling
          _startDownloadPolling(token);
        }
      } else {
        _showErrorSnackBar('Could not check resume status. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _startDownloadPolling(String token) {
    _downloadTries = 0;
    _downloadPollingTimer?.cancel();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.0,
            ),
            SizedBox(width: 16),
            Text('Preparing your resume PDF...'),
          ],
        ),
        duration: Duration(minutes: 1),
      ),
    );

    _downloadPollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      _downloadTries++;
      if (_downloadTries >= _maxDownloadTries) {
        _stopPolling();
        _showErrorSnackBar('Resume preparation is taking longer than expected. Please try again in a moment.');
        return;
      }

      try {
        final apiClient = sl<ApiClient>();
        final response = await apiClient.get('/my-resume');

        if (response != null && response['resume_pdf'] != null) {
          final resumePdf = response['resume_pdf'];
          final bool exists = resumePdf['exists'] ?? false;
          final String? downloadUrl = resumePdf['download_url'];

          if (exists && downloadUrl != null) {
            _stopPolling();
            _triggerDownload(downloadUrl, token);
          }
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    });
  }

  void _stopPolling() {
    _downloadPollingTimer?.cancel();
    _downloadPollingTimer = null;
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  Future<void> _triggerDownload(String url, String token) async {
    try {
      final uri = Uri.parse(url);
      final downloadUrl = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'token': token,
        },
      );

      if (await canLaunchUrl(downloadUrl)) {
        await launchUrl(downloadUrl, mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume download started'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorSnackBar('Could not start download. Please try again later.');
      }
    } catch (e) {
      _showErrorSnackBar('Error starting download: ${e.toString()}');
    }
  }

  void _fetchResumeHtml() {
    _retryCount = 0;
    _loadResumeUrl(templateKey: _currentTemplateKey);
  }

  static const String _baseUrl = 'https://www.ajiriwa.net';

  void _setDefaultTemplates() {
    setState(() {
      _templates = [
        {'key': 'material',   'name': 'Material',   'thumbnail': '$_baseUrl/storage/thumbnails/material.webp',   'owned': true},
        {'key': 'stockholm',  'name': 'Stockholm',  'thumbnail': '$_baseUrl/storage/thumbnails/stockholm.webp',  'owned': true},
        {'key': 'stylish',    'name': 'Stylish',    'thumbnail': '$_baseUrl/storage/thumbnails/stylish.webp',    'owned': true},
        {'key': 'toronto',    'name': 'Toronto',    'thumbnail': '$_baseUrl/storage/thumbnails/toronto.webp',    'owned': true},
        {'key': 'executive',  'name': 'Executive',  'thumbnail': '$_baseUrl/storage/thumbnails/executive.webp',  'owned': true},
        {'key': 'modern',     'name': 'Modern',     'thumbnail': '$_baseUrl/storage/thumbnails/modern.webp',     'owned': true},
        {'key': 'minimalist', 'name': 'Minimalist', 'thumbnail': '$_baseUrl/storage/thumbnails/minimalist.webp', 'owned': true},
        {'key': 'elegant',    'name': 'Elegant',    'thumbnail': '$_baseUrl/storage/thumbnails/elegant.webp',    'owned': true},
        {'key': 'nordic',     'name': 'Nordic',     'thumbnail': '$_baseUrl/storage/thumbnails/nordic.webp',     'owned': true},
        {'key': 'atelier',    'name': 'Atelier',    'thumbnail': '$_baseUrl/storage/thumbnails/atelier.webp',    'owned': true},
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
            if (templatesData.isNotEmpty) {
              setState(() {
                _templates = templatesData.map<Map<String, dynamic>>((template) {
                  // Resolve thumbnail: prefix relative paths with base URL
                  String thumb = template['thumbnail'] as String? ?? '';
                  if (thumb.isNotEmpty && !thumb.startsWith('http')) {
                    // Check if it starts with storage/
                    if (thumb.startsWith('storage/')) {
                      thumb = 'https://www.ajiriwa.net/$thumb';
                    } else {
                      thumb = 'https://www.ajiriwa.net/storage/$thumb';
                    }
                  }
                  return {
                    'key': template['slug'] as String,
                    'name': template['name'] as String,
                    'thumbnail': thumb,
                    'price': template['price'],
                    'currency': template['currency'],
                    'owned': template['owned'] as bool? ?? true,
                  };
                }).toList();
              });
            } else {
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
            color: Colors.white,
            child: _buildResumeSkeleton(),
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

  Widget _buildResumeSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(width: 80, height: 80, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 200, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 8),
                      Container(width: 150, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Contact info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) => Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)))),
            ),
            const SizedBox(height: 40),
            // Sections
            ...List.generate(3, (index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 16),
                Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 32),
              ],
            )),
          ],
        ),
      ),
    );
  }

  void _showThemeSelectionDialog() {
    final primary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.color_lens_outlined, color: primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Choose CV Theme',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_templates.length} themes',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.55,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _templates.length,
                  itemBuilder: (ctx2, index) {
                    final template = _templates[index];
                    final isSelected = template['key'] == _currentTemplateKey;
                    final thumbUrl = template['thumbnail']?.toString() ?? '';
                    final isOwned = template['owned'] as bool? ?? true;

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _loadResumeUrl(templateKey: template['key'] as String);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? primary.withOpacity(0.05) : Theme.of(ctx2).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? primary : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04),
                              blurRadius: isSelected ? 10 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Thumbnail image
                                    thumbUrl.isNotEmpty
                                        ? Image.network(
                                            thumbUrl,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (ctx3, child, progress) {
                                              if (progress == null) return child;
                                              return Container(
                                                color: Colors.grey.shade100,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: progress.expectedTotalBytes != null
                                                        ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                                        : null,
                                                    strokeWidth: 2,
                                                    color: primary,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (_, __, ___) => _buildThumbPlaceholder(primary),
                                          )
                                        : _buildThumbPlaceholder(primary),
                                    // Lock overlay for unowned templates
                                    if (!isOwned)
                                      Container(
                                        color: Colors.black.withOpacity(0.35),
                                        child: const Center(
                                          child: Icon(Icons.lock_outline, color: Colors.white, size: 28),
                                        ),
                                      ),
                                    // Selected checkmark
                                    if (isSelected)
                                      Positioned(
                                        top: 8, right: 8,
                                        child: Container(
                                          width: 24, height: 24,
                                          decoration: BoxDecoration(
                                            color: primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check, color: Colors.white, size: 14),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      template['name'] as String? ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? primary : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (!isOwned)
                                    Icon(Icons.lock_outline, size: 12, color: Colors.grey.shade400),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThumbPlaceholder(Color primary) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 36, color: primary.withOpacity(0.3)),
          const SizedBox(height: 4),
          Text('Preview', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _downloadPollingTimer?.cancel();
    super.dispose();
  }
}
