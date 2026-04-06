import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'core/di/injection_container.dart' as di;
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/bloc.dart';
import 'features/dashboard/presentation/bloc/bloc.dart';
import 'features/jobs/presentation/bloc/bloc.dart';
import 'features/cv_optimization/presentation/bloc/cv_optimization_bloc.dart';

void main() {
  // To make zone errors fatal (as suggested in the error message)
  // BindingBase.debugZoneErrorsAreFatal = true;

  // Run the app inside a zone to catch any errors
  runZonedGuarded(() async {
    // Initialize WebView platform before Flutter is initialized
    if (WebViewPlatform.instance == null) {
      if (Platform.isAndroid) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
      } else if (Platform.isIOS) {
        WebViewPlatform.instance = WebKitWebViewPlatform();
      }
    }

    // Ensure Flutter is initialized - MUST be in the same zone as runApp
    WidgetsFlutterBinding.ensureInitialized();

    // Catch any errors that occur during initialization
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      print('Flutter error: ${details.exception}');
    };

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize dependencies
    await di.init();

    // Run the app in the same zone as the Flutter binding initialization
    runApp(const AjiriwaApp());
  }, (error, stackTrace) {
    print('Caught error: $error');
    print('Stack trace: $stackTrace');
  });
}

/// The main app widget
class AjiriwaApp extends StatelessWidget {
  /// Constructor
  const AjiriwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => di.sl<DashboardBloc>(),
        ),
        BlocProvider<JobsBloc>(
          create: (context) => di.sl<JobsBloc>(),
        ),
        BlocProvider<CvOptimizationBloc>(
          create: (context) => di.sl<CvOptimizationBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Ajiriwa',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.light, // Default to light theme
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
