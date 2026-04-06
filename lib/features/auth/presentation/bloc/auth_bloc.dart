import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Auth repository
  final AuthRepository authRepository;

  /// Constructor
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<LoginWithAppleEvent>(_onLoginWithApple);
    on<LogoutEvent>(_onLogout);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<SwitchCandidateEvent>(_onSwitchCandidate);
  }

  /// Handle switch candidate event
  Future<void> _onSwitchCandidate(
    SwitchCandidateEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is Authenticated) {
      emit(AuthLoading());
      final result = await authRepository.switchProfile(event.candidateId);
      result.fold(
        (failure) => emit(Authenticated(currentState.user)), // Revert to old user on failure
        (user) => emit(Authenticated(user)),
      );
    }
  }

  /// Handle check auth status event
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.checkAuth();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  /// Handle login event
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.login(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (user) => emit(Authenticated(user)),
    );
  }

  /// Handle register event
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.register(
      name: event.name,
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (user) => emit(Authenticated(user)),
    );
  }

  /// Handle login with Google event
  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.loginWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (user) => emit(Authenticated(user)),
    );
  }

  /// Handle login with Apple event
  Future<void> _onLoginWithApple(
    LoginWithAppleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.loginWithApple();
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (user) => emit(Authenticated(user)),
    );
  }

  /// Handle logout event
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.logout();
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (_) => emit(Unauthenticated()),
    );
  }

  /// Handle forgot password event
  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.forgotPassword(email: event.email);
    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (_) => emit(const PasswordResetSent('Password reset instructions have been sent to your email')),
    );
  }
}
