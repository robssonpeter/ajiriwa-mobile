import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import '../utils/app_logger.dart';
import 'network_info.dart';

/// Implementation of the NetworkInfo interface
class NetworkInfoImpl implements NetworkInfo {
  /// Connectivity instance
  final Connectivity connectivity;

  /// Constructor
  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } on PlatformException catch (e) {
      appLogger.w('Connectivity plugin error: ${e.message}');
      return true;
    } on MissingPluginException catch (e) {
      appLogger.w('Connectivity plugin not available: ${e.message}');
      return true;
    } catch (e) {
      appLogger.w('Error checking connectivity', error: e);
      return true;
    }
  }
}
