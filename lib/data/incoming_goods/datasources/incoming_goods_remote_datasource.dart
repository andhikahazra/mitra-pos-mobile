import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/network/dio_client.dart';
import 'package:mitrapos/data/incoming_goods/models/supplier_model.dart';
import 'package:dio/dio.dart' as dio;

abstract class IncomingGoodsRemoteDataSource {
  Future<List<SupplierModel>> getSuppliers();
  Future<Map<String, dynamic>> saveIncomingGoods(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getIncomingGoods({int page = 1});
}

@LazySingleton(as: IncomingGoodsRemoteDataSource)
class IncomingGoodsRemoteDataSourceImpl implements IncomingGoodsRemoteDataSource {
  final DioClient _dioClient;

  IncomingGoodsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<SupplierModel>> getSuppliers() async {
    final response = await _dioClient.get('/suppliers');
    final List data = response.data['data'];
    return data.map((item) => SupplierModel.fromJson(item)).toList();
  }

  @override
  Future<Map<String, dynamic>> saveIncomingGoods(Map<String, dynamic> data) async {
    final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
    final String? filePath = payload.remove('foto_struk_path') as String?;

    dynamic requestData;

    if (filePath != null && filePath.isNotEmpty) {
      final formData = dio.FormData();

      // Add simple fields
      formData.fields.add(MapEntry<String, String>('supplier_id', payload['supplier_id'].toString()));
      formData.fields.add(MapEntry<String, String>('tanggal_terima', payload['tanggal_terima'].toString()));
      if (payload['catatan'] != null) {
        formData.fields.add(MapEntry<String, String>('catatan', payload['catatan'].toString()));
      }

      // Add items
      final List items = payload['items'] as List;
      for (int i = 0; i < items.length; i++) {
        final item = items[i] as Map;
        formData.fields.add(MapEntry<String, String>('items[$i][produk_id]', item['produk_id'].toString()));
        formData.fields.add(MapEntry<String, String>('items[$i][jumlah]', item['jumlah'].toString()));
        formData.fields.add(MapEntry<String, String>('items[$i][harga]', item['harga'].toString()));
      }

      // Add file
      final fileName = filePath.split('/').last;
      formData.files.add(MapEntry<String, dio.MultipartFile>(
        'foto_struk',
        await dio.MultipartFile.fromFile(filePath, filename: fileName),
      ));

      requestData = formData;
    } else {
      requestData = payload;
    }

    final response = await _dioClient.post('/incoming-goods', data: requestData);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getIncomingGoods({int page = 1}) async {
    final response = await _dioClient.get(
      '/incoming-goods',
      queryParameters: {'page': page},
    );
    return response.data;
  }
}
