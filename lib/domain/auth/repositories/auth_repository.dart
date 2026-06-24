import 'package:dartz/dartz.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/auth/entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthUser>> getProfile();
}
