import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  /// Constructor
  const Failure([this.properties = const <dynamic>[]]);

  /// Properties to be used in equality comparison
  final List<dynamic> properties;

  /// Error message
  String get message => toString();

  @override
  List<dynamic> get props => properties;
}

/// Server failure
class ServerFailure extends Failure {
  /// Error message
  final String? _message;

  /// Constructor
  const ServerFailure([this._message]) : super(const []);

  @override
  String get message => _message ?? 'Server error';

  @override
  List<dynamic> get props => [_message];

  @override
  String toString() => '${_message ?? 'Server error'}';
}

/// Cache failure
class CacheFailure extends Failure {
  /// Error message
  final String? _message;

  /// Constructor
  const CacheFailure([this._message]) : super(const []);

  @override
  String get message => _message ?? 'Cache error';

  @override
  List<dynamic> get props => [_message];

  @override
  String toString() => '${_message ?? 'Cache error'}';
}

/// Network failure
class NetworkFailure extends Failure {
  /// Error message
  final String? _message;

  /// Constructor
  const NetworkFailure([this._message]) : super(const []);

  @override
  String get message => _message ?? 'Network error';

  @override
  List<dynamic> get props => [_message];

  @override
  String toString() => '${_message ?? 'Network error'}';
}

/// Authentication failure
class AuthFailure extends Failure {
  /// Error message
  final String? _message;

  /// Constructor
  const AuthFailure([this._message]) : super(const []);

  @override
  String get message => _message ?? 'Authentication error';

  @override
  List<dynamic> get props => [_message];

  @override
  String toString() => '${_message ?? 'Authentication error'}';
}
