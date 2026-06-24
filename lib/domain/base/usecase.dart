import 'package:dartz/dartz.dart';
import 'package:mitrapos/core/error/failure.dart';

/// Base use case with parameters
abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

/// Base use case without parameters
abstract class UseCaseNoParams<Result> {
  Future<Either<Failure, Result>> call();
}
