import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> logout();
  Future<Map<String, dynamic>> getProfile();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dioClient.instance.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan pada server');
      }
      throw Exception('Koneksi internet bermasalah');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.instance.post('/logout');
    } catch (e) {
      // Even if logout fails on server, we might want to clear local data
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dioClient.instance.get('/user');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Gagal mengambil data profil');
      }
      throw Exception('Koneksi internet bermasalah');
    }
  }
}
