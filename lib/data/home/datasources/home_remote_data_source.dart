import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/network/dio_client.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getDashboardData(String period);
}

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSourceImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> getDashboardData(String period) async {
    final response = await _dioClient.get(
      '/dashboard',
      queryParameters: {'period': period},
    );
    return response.data;
  }
}
