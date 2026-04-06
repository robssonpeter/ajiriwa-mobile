/// Exception thrown when a server error occurs
class ServerException implements Exception {
  /// Error message
  final String message;

  /// Constructor
  ServerException([this.message = 'Server error']);
}

/// Exception thrown when a cache error occurs
class CacheException implements Exception {
  /// Error message
  final String message;

  /// Constructor
  CacheException([this.message = 'Cache error']);
}

/// Exception thrown when a network error occurs
class NetworkException implements Exception {
  /// Error message
  final String message;

  /// Constructor
  NetworkException([this.message = 'Network error']);
}

/// Exception thrown when an authentication error occurs
class AuthException implements Exception {
  /// Error message
  final String message;

  /// Constructor
  AuthException([this.message = 'Authentication error']);
}
