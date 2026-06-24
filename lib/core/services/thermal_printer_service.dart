import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:mitrapos/core/utils/currency_formatter.dart';

class ThermalPrinterService {
  static final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  static Future<bool> printReceipt({
    required String storeName,
    required String? address,
    required String? slogan,
    required String orderId,
    required String tanggalJam,
    required List<dynamic> items,
    required int subtotal,
    required int biayaAdmin,
    required int total,
    required String metodePembayaran,
    required String? footer,
    int? uangCustomer,
    int? kembalian,
    Map<String, dynamic>? appSettings,
  }) async {
    bool? isConnected = await _bluetooth.isConnected;
    if (isConnected != true) return false;

    const String divider = '--------------------------------';

    try {
      await _bluetooth.printNewLine();
      
      // --- HEADER (Centered) ---
      await _bluetooth.printCustom(storeName.toUpperCase(), 0, 1);
      
      if (slogan != null && slogan.isNotEmpty) {
        await _bluetooth.printCustom(slogan.toUpperCase(), 0, 1);
      }
      
      final String? keterangan = appSettings?['deskripsi']?['keterangan'];
      if (keterangan != null && keterangan.isNotEmpty) {
        await _bluetooth.printCustom(keterangan.toUpperCase(), 0, 1);
      }
      
      final Map<String, dynamic>? alamat = appSettings?['alamat_toko'];
      if (alamat != null) {
        if (alamat['jalan']?.toString().isNotEmpty ?? false) {
          await _bluetooth.printCustom(alamat['jalan'].toString().toUpperCase(), 0, 1);
        }
        if (alamat['kota']?.toString().isNotEmpty ?? false) {
          await _bluetooth.printCustom(alamat['kota'].toString().toUpperCase(), 0, 1);
        }
        if (alamat['provinsi']?.toString().isNotEmpty ?? false) {
          await _bluetooth.printCustom(alamat['provinsi'].toString().toUpperCase(), 0, 1);
        }
      }
      
      final String? noHp = appSettings?['no_hp'];
      if (noHp != null && noHp.isNotEmpty) {
        await _bluetooth.printCustom(noHp, 0, 1);
      }
      
      await _bluetooth.printCustom(divider, 0, 1);
      
      // --- TRANSACTION INFO ---
      await _bluetooth.printCustom(orderId, 0, 0);
      await _bluetooth.printCustom(tanggalJam, 0, 0);
      
      await _bluetooth.printCustom(divider, 0, 1);
      
      // --- ITEMS ---
      for (final item in items) {
        await _bluetooth.printCustom(item.name.toUpperCase(), 0, 0);
        
        final String qtyPrice = '${item.qty} x ${CurrencyFormatter.format(item.lineTotal ~/ item.qty, symbol: '')}';
        final String lineTotal = CurrencyFormatter.format(item.lineTotal, symbol: '');
        
        final int spaceCount = 32 - qtyPrice.length - lineTotal.length;
        final String space = spaceCount > 0 ? ' ' * spaceCount : ' ';
        
        await _bluetooth.printCustom('$qtyPrice$space$lineTotal', 0, 0);
      }
      
      await _bluetooth.printCustom(divider, 0, 1);
      
      // --- SUMMARY ---
      final int totalItem = items.fold(0, (sum, item) => sum + (item.qty as int));
      await _bluetooth.printLeftRight('Jumlah Item', '$totalItem', 0);
      await _bluetooth.printLeftRight('Subtotal', CurrencyFormatter.format(subtotal, symbol: ''), 0);
      await _bluetooth.printLeftRight('Metode', metodePembayaran.toUpperCase(), 0);
      
      if (biayaAdmin > 0) {
        await _bluetooth.printLeftRight('Biaya Admin', CurrencyFormatter.format(biayaAdmin, symbol: ''), 0);
      }
      
      if (metodePembayaran.toLowerCase().contains('tunai')) {
        if (uangCustomer != null && uangCustomer > 0) {
          await _bluetooth.printLeftRight('Bayar', CurrencyFormatter.format(uangCustomer, symbol: ''), 0);
          await _bluetooth.printLeftRight('Kembali', CurrencyFormatter.format(kembalian ?? 0, symbol: ''), 0);
        }
      } else if (metodePembayaran.toLowerCase().contains('transfer')) {
        // Option to show bank info if available in appSettings or response
      }
      
      await _bluetooth.printCustom(divider, 0, 1);
      
      // --- TOTAL ---
      await _bluetooth.printLeftRight('GRAND TOTAL', CurrencyFormatter.format(total, symbol: 'Rp '), 0);
      
      await _bluetooth.printNewLine();
      
      // --- FOOTER ---
      if (footer != null && footer.isNotEmpty) {
        await _bluetooth.printCustom(footer.toUpperCase(), 0, 1);
      } else {
        await _bluetooth.printCustom('TERIMAKASIH', 0, 1);
        await _bluetooth.printCustom('SILAKAN DATANG KEMBALI', 0, 1);
      }
      
      await _bluetooth.printNewLine();
      await _bluetooth.printNewLine();
      await _bluetooth.printNewLine();
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
