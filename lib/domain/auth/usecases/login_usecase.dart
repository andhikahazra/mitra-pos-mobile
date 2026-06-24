import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/auth/entities/auth_user.dart';
import 'package:mitrapos/domain/auth/repositories/auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, AuthUser>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
