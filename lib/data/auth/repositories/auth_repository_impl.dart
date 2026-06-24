import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/error/failure.dart';
import 'package:mitrapos/data/auth/datasources/auth_remote_datasource.dart';
import 'package:mitrapos/domain/auth/entities/auth_user.dart';
import 'package:mitrapos/domain/auth/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  AuthRepositoryImpl(this._remoteDataSource, this._prefs);

  @override
  Future<Either<Failure, AuthUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(email, password);
      
      if (response['success'] == true) {
        final userData = response['data']['user'];
        final token = response['data']['token'];
        
        // Save token to SharedPreferences
        await _prefs.setString('auth_token', token);
        
        final user = AuthUser(
          id: userData['id'].toString(),
          name: userData['nama'],
          email: userData['email'],
          role: userData['role'],
          status: userData['status'] is int ? userData['status'] == 1 : userData['status'],
        );
        
        return Right(user);
      } else {
        return Left(ServerFailure(response['message'] ?? 'Login gagal'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _prefs.remove('auth_token');
      return const Right(null);
    } catch (e) {
      // Still remove token locally even if server logout fails
      await _prefs.remove('auth_token');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> getProfile() async {
    try {
      final response = await _remoteDataSource.getProfile();
      
      if (response['success'] == true) {
        final userData = response['data'];
        
        final user = AuthUser(
          id: userData['id'].toString(),
          name: userData['nama'],
          email: userData['email'],
          role: userData['role'],
          status: userData['status'] is int ? userData['status'] == 1 : userData['status'],
        );
        
        return Right(user);
      } else {
        return Left(ServerFailure(response['message'] ?? 'Gagal mengambil profil'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
