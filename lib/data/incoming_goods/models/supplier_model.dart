import 'package:equatable/equatable.dart';

class SupplierModel extends Equatable {
  final int id;
  final String nama;
  final String? alamat;
  final String? telepon;

  const SupplierModel({
    required this.id,
    required this.nama,
    this.alamat,
    this.telepon,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      nama: json['nama'],
      alamat: json['alamat'],
      telepon: json['telepon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'telepon': telepon,
    };
  }

  @override
  List<Object?> get props => [id, nama, alamat, telepon];
}
