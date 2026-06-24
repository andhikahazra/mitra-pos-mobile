import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class DioClient {
  final Dio _dio;
  final SharedPreferences _prefs;

  DioClient(this._dio, this._prefs) {
    _dio
      ..options.baseUrl = AppConstants.baseUrl
      ..options.connectTimeout = AppConstants.apiTimeout
      ..options.receiveTimeout = AppConstants.apiTimeout
      ..options.responseType = ResponseType.json
      ..options.headers['Accept'] = 'application/json'
      ..interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ))
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // You can handle global errors here, like 401 for auto logout
          return handler.next(e);
        },
      ));
  }

  Dio get instance => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }
}
