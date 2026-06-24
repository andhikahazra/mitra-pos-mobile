part of 'auth_controller.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class GetProfileRequested extends AuthEvent {
  const GetProfileRequested();
}
