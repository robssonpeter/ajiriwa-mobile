import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  /// Constructor
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status event
class CheckAuthStatusEvent extends AuthEvent {}

/// Login event
class LoginEvent extends AuthEvent {
  /// Email
  final String email;

  /// Password
  final String password;

  /// Constructor
  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Register event
class RegisterEvent extends AuthEvent {
  /// Name
  final String name;

  /// Email
  final String email;

  /// Password
  final String password;

  /// Constructor
  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// Login with Google event
class LoginWithGoogleEvent extends AuthEvent {}

/// Login with Apple event
class LoginWithAppleEvent extends AuthEvent {}

/// Logout event
class LogoutEvent extends AuthEvent {}

/// Switch candidate profile event
class SwitchCandidateEvent extends AuthEvent {
  /// Candidate ID
  final int candidateId;

  /// Constructor
  const SwitchCandidateEvent(this.candidateId);

  @override
  List<Object?> get props => [candidateId];
}

/// Forgot password event
class ForgotPasswordEvent extends AuthEvent {
  /// Email
  final String email;

  /// Constructor
  const ForgotPasswordEvent({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

/// Change password event
class ChangePasswordEvent extends AuthEvent {
  /// Current password
  final String oldPassword;

  /// New password
  final String newPassword;

  /// Constructor
  const ChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}
