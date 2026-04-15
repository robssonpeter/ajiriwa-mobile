import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../utils/app_logger.dart';

import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/datasources/auth_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/data/datasources/dashboard_data_source.dart';
import '../../features/dashboard/data/datasources/dashboard_data_source_impl.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/jobs/data/datasources/job_data_source.dart';
import '../../features/jobs/data/datasources/job_data_source_impl.dart';
import '../../features/jobs/data/repositories/job_repository_impl.dart';
import '../../features/jobs/domain/repositories/job_repository.dart';
import '../../features/jobs/presentation/bloc/apply_bloc.dart';
import '../../features/jobs/presentation/bloc/job_bloc.dart';
import '../../features/jobs/presentation/bloc/jobs_bloc.dart';
import '../../features/applications/data/datasources/application_data_source.dart';
import '../../features/applications/data/datasources/application_data_source_impl.dart';
import '../../features/applications/data/repositories/application_repository_impl.dart';
import '../../features/applications/domain/repositories/application_repository.dart';
import '../../features/applications/presentation/bloc/applications_bloc.dart';
import '../../features/applications/presentation/bloc/application_details_bloc.dart';
import '../../features/saved_jobs/presentation/bloc/saved_jobs_bloc.dart';
import '../../features/resume/data/datasources/resume_remote_data_source.dart';
import '../../features/resume/data/datasources/resume_remote_data_source_impl.dart';
import '../../features/resume/data/repositories/resume_repository_impl.dart';
import '../../features/resume/domain/repositories/resume_repository.dart';
import '../../features/resume/presentation/bloc/bloc.dart';
import '../../features/cv_optimization/data/datasources/cv_optimization_data_source.dart';
import '../../features/cv_optimization/data/datasources/cv_optimization_data_source_impl.dart';
import '../../features/cv_optimization/data/repositories/cv_optimization_repository_impl.dart';
import '../../features/cv_optimization/domain/repositories/cv_optimization_repository.dart';
import '../../features/cv_optimization/presentation/bloc/cv_optimization_bloc.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../network/network_info_impl.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize dependencies
Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(authRepository: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(
      apiClient: sl(),
    ),
  );

  // Features - Dashboard
  // Bloc
  sl.registerFactory(
    () => DashboardBloc(dashboardRepository: sl()),
  );

  // Repositories
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<DashboardDataSource>(
    () => DashboardDataSourceImpl(
      apiClient: sl(),
    ),
  );

  // Features - Jobs
  // Bloc
  sl.registerFactory(
    () => JobBloc(jobRepository: sl()),
  );

  sl.registerFactory(
    () => JobsBloc(jobRepository: sl()),
  );

  sl.registerFactory(
    () => ApplyBloc(jobRepository: sl()),
  );

  // Repositories
  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<JobDataSource>(
    () => JobDataSourceImpl(
      apiClient: sl(),
    ),
  );

  // Features - Applications
  // Bloc
  sl.registerFactory(
    () => ApplicationsBloc(applicationRepository: sl()),
  );

  sl.registerFactory(
    () => ApplicationDetailsBloc(applicationRepository: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ApplicationRepository>(
    () => ApplicationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ApplicationDataSource>(
    () => ApplicationDataSourceImpl(
      apiClient: sl(),
    ),
  );

  // Features - Saved Jobs
  // Bloc
  sl.registerFactory(
    () => SavedJobsBloc(jobRepository: sl()),
  );

  // Features - Resume
  // Bloc
  sl.registerFactory(
    () => ResumeBloc(repository: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ResumeRepository>(
    () => ResumeRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ResumeRemoteDataSource>(
    () => ResumeRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );

  // Features - CV Optimization
  sl.registerFactory(
    () => CvOptimizationBloc(repository: sl()),
  );
  sl.registerLazySingleton<CvOptimizationRepository>(
    () => CvOptimizationRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<CvOptimizationDataSource>(
    () => CvOptimizationDataSourceImpl(apiClient: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() {
    try {
      // Try to create a NetworkInfoImpl with Connectivity
      return NetworkInfoImpl(Connectivity());
    } on MissingPluginException catch (e) {
      appLogger.w('Connectivity plugin unavailable: ${e.message}');
      return _MockNetworkInfo();
    } catch (e) {
      appLogger.e('Unexpected error initializing Connectivity', error: e);
      return _MockNetworkInfo();
    }
  });

  sl.registerLazySingleton(
    () => ApiClient(
      dio: sl(),
      secureStorage: sl(),
    ),
  );

  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}

/// Mock implementation of NetworkInfo that always returns connected
class _MockNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}
