part of 'transactions_controller.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProdukTransaksi extends TransactionsEvent {
  const LoadProdukTransaksi();
}

class CariProdukTransaksi extends TransactionsEvent {
  final String keyword;

  const CariProdukTransaksi(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class FilterKategoriTransaksi extends TransactionsEvent {
  final String kategori;

  const FilterKategoriTransaksi(this.kategori);

  @override
  List<Object?> get props => [kategori];
}

class TambahProdukKeranjang extends TransactionsEvent {
  final TransactionProduct produk;

  const TambahProdukKeranjang(this.produk);

  @override
  List<Object?> get props => [produk];
}

class KurangProdukKeranjang extends TransactionsEvent {
  final int productId; // Changed from String to int

  const KurangProdukKeranjang(this.productId);

  @override
  List<Object?> get props => [productId];
}

class HapusProdukKeranjang extends TransactionsEvent {
  final int productId; // Changed from String to int

  const HapusProdukKeranjang(this.productId);

  @override
  List<Object?> get props => [productId];
}

class SetQtyProdukKeranjang extends TransactionsEvent {
  final int productId; // Changed from String to int
  final int qty;

  const SetQtyProdukKeranjang({
    required this.productId,
    required this.qty,
  });

  @override
  List<Object?> get props => [productId, qty];
}

class ResetKeranjang extends TransactionsEvent {
  const ResetKeranjang();
}

class SubmitTransaksi extends TransactionsEvent {
  final String namaPelanggan;
  final String? noHpPelanggan;
  final String metodePembayaran;
  final int biayaAdmin;
  final int? uangCustomer;
  final String? catatan;

  const SubmitTransaksi({
    this.namaPelanggan = '',
    this.noHpPelanggan,
    required this.metodePembayaran,
    this.biayaAdmin = 0,
    this.uangCustomer,
    this.catatan,
  });

  @override
  List<Object?> get props => [namaPelanggan, noHpPelanggan, metodePembayaran, biayaAdmin, uangCustomer, catatan];
}

class ResetTransactionStatus extends TransactionsEvent {
  const ResetTransactionStatus();
}
