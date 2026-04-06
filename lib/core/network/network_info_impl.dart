import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

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
      print('Connectivity plugin error: ${e.message}');
      return true; // Assume connected if plugin fails
    } on MissingPluginException catch (e) {
      print('Connectivity plugin not available: ${e.message}');
      return true; // Assume connected if plugin is not available
    } catch (e) {
      print('Error checking connectivity: $e');
      return true; // Assume connected on any other error
    }
  }
}
