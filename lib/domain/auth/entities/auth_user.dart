import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool status;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, email, role, status];
}
