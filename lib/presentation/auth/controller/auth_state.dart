part of 'auth_controller.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;
  final AuthUser? user;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
    AuthUser? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [isLoading, isAuthenticated, errorMessage, user];
}
