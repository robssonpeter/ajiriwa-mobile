import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  /// Constructor
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial authentication state
class AuthInitial extends AuthState {}

/// Loading authentication state
class AuthLoading extends AuthState {}

/// Authenticated state
class Authenticated extends AuthState {
  /// User
  final User user;

  /// Constructor
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {}

/// Authentication error state
class AuthError extends AuthState {
  /// Error message
  final String message;

  /// Constructor
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Password reset sent state
class PasswordResetSent extends AuthState {
  /// Success message
  final String message;

  /// Constructor
  const PasswordResetSent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Password changed successfully state
class PasswordChanged extends AuthState {
  const PasswordChanged();
}

/// Password change in progress state
class PasswordChanging extends AuthState {
  const PasswordChanging();
}
