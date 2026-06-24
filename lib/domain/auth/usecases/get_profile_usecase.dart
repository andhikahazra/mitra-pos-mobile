import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/domain/auth/entities/auth_user.dart';
import 'package:mitrapos/domain/auth/repositories/auth_repository.dart';

@lazySingleton
class GetProfileUseCase {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call() async {
    return await repository.getProfile();
  }
}
