import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/utils/currency_formatter.dart';
import 'package:mitrapos/core/widgets/mitrapos_bottom_nav_bar.dart';
import 'package:mitrapos/core/widgets/mitrapos_sidebar.dart';
import 'package:mitrapos/core/widgets/skeleton.dart';
import 'package:mitrapos/presentation/history/controller/history_controller.dart';
import 'package:mitrapos/domain/history/entities/history_transaction.dart';
import 'package:mitrapos/presentation/home/pages/home_page.dart';
import 'package:mitrapos/presentation/incoming_goods/pages/incoming_goods_page.dart';
import 'package:mitrapos/presentation/products/pages/products_page.dart';
import 'package:mitrapos/presentation/transactions/pages/transactions_page.dart';
import 'package:mitrapos/core/services/thermal_printer_service.dart';
import 'package:mitrapos/presentation/settings/controller/settings_controller.dart';
import 'package:intl/intl.dart';

String _formatShortDateTime(DateTime dateTime) {
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final date = dateTime.day.toString().padLeft(2, '0');
  final month = bulan[dateTime.month - 1];
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$date $month, $hour:$minute';
}

String _formatShortDate(DateTime dateTime) {
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final date = dateTime.day.toString().padLeft(2, '0');
  final month = bulan[dateTime.month - 1];
  final year = dateTime.year;
  return '$date $month $year';
}

String _formatFullDateTime(DateTime dateTime) {
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final date = dateTime.day.toString().padLeft(2, '0');
  final month = bulan[dateTime.month - 1];
  final year = dateTime.year;
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$date $month $year, $hour:$minute';
}

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String _searchKeyword = '';
  bool _onlySuccess = false;

  // API values for range filter
  final List<String> _rangeApiValues = const ['hari', '7hari', '14hari'];

  bool _matchesSearch(HistoryTransaction entry) {
    if (_onlySuccess && entry.status.toLowerCase() != 'selesai') {
      return false;
    }
    final keyword = _searchKeyword.trim().toLowerCase();
    if (keyword.isEmpty) return true;

    return entry.kode.toLowerCase().contains(keyword) ||
        entry.cashierName.toLowerCase().contains(keyword) ||
        entry.metodePembayaran.toLowerCase().contains(keyword);
  }

  bool _isNavigating = false;

  void _openDetail(HistoryTransaction entry) {
    if (_isNavigating) return;
    _isNavigating = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _HistoryDetailPage(entry: entry),
      ),
    ).then((_) {
      _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyControllerProvider);
    final notifier = ref.read(historyControllerProvider.notifier);
    final isTablet = MediaQuery.of(context).size.width >= 800;

    final filteredEntries = state.transactions.where(_matchesSearch).toList();

    // Map API range to index for UI
    int activeRangeIndex = _rangeApiValues.indexWhere(
      (v) => v.toLowerCase() == state.activeRange.toLowerCase(),
    );
    if (activeRangeIndex == -1) activeRangeIndex = 0;

    void handleNav(int index) {
      if (index == 0) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else if (index == 1) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsPage()));
      } else if (index == 2) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TransactionsPage()));
      } else if (index == 4) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const IncomingGoodsPage()));
      }
    }

    Widget historyBody() {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                child: TextField(
                  onChanged: (value) =>
                      setState(() => _searchKeyword = value),
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi...',
                    hintStyle: AppTypePairing.bodySm(
                      color: const Color(0xFF9E9E9E),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 20, color: Color(0xFF757575)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
            ),
          ),
          // Horizontal scrolling filter chips
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFilterChip(
                  label: 'Hari Ini',
                  isSelected: state.activeRange.toLowerCase() == 'hari' &&
                      state.selectedDate == null &&
                      !_onlySuccess,
                  onTap: () {
                    setState(() {
                      _onlySuccess = false;
                    });
                    notifier.setRange('hari');
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: '7 Hari',
                  isSelected: state.activeRange.toLowerCase() == '7hari' &&
                      state.selectedDate == null &&
                      !_onlySuccess,
                  onTap: () {
                    setState(() {
                      _onlySuccess = false;
                    });
                    notifier.setRange('7hari');
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: '14 Hari',
                  isSelected: state.activeRange.toLowerCase() == '14hari' &&
                      state.selectedDate == null &&
                      !_onlySuccess,
                  onTap: () {
                    setState(() {
                      _onlySuccess = false;
                    });
                    notifier.setRange('14hari');
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: state.selectedDate == null
                      ? 'Pilih Tanggal...'
                      : _formatShortDate(state.selectedDate!),
                  icon: Icons.calendar_today_outlined,
                  isSelected: state.selectedDate != null,
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: state.selectedDate ?? now,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(now.year + 1, 12, 31),
                    );
                    if (picked != null) {
                      notifier.setDate(DateTime(picked.year, picked.month, picked.day));
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const HistorySkeleton()
                : state.errorMessage != null
                    ? Center(child: Text(state.errorMessage!))
                    : RefreshIndicator(
                        onRefresh: () async {
                          await notifier.loadHistory();
                        },
                        color: context.indigoPrimary,
                        child: filteredEntries.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(20),
                                children: const [
                                  _EmptyListState(
                                    title: 'Riwayat Kosong',
                                    subtitle: 'Belum ada transaksi di periode ini.',
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                itemCount: filteredEntries.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 0),
                                itemBuilder: (context, index) => _HistoryListCard(
                                  entry: filteredEntries[index],
                                  onTap: () =>
                                      _openDetail(filteredEntries[index]),
                                ),
                              ),
                      ),
          ),
        ],
      );
  }

    if (isTablet) {
      return Scaffold(
        backgroundColor: context.surfaceContainerLowest,
        body: SafeArea(
          child: Row(
            children: [
              MitraPOSSidebar(currentIndex: 3, onTap: handleNav),
              Expanded(child: historyBody()),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: context.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Riwayat Transaksi',
          style: AppTypePairing.titleMd(
            color: const Color(0xFF000B60),
            weight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: MitraPOSBottomNavBar(
        currentIndex: 3,
onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
                } else if (index == 1) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsPage()));
                } else if (index == 2) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TransactionsPage()));
                } else if (index == 4) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const IncomingGoodsPage()));
                }
              },
      ),
      body: historyBody(),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8F0FE)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF000B60)
                : const Color(0xFFDFE6E9),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: isSelected ? const Color(0xFF000B60) : const Color(0xFF636E72),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF000B60) : const Color(0xFF636E72),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({this.color = const Color(0xFFDFE6E9)});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HistoryListCard extends StatelessWidget {
  final HistoryTransaction entry;
  final VoidCallback onTap;

  const _HistoryListCard({
    required this.entry,
    required this.onTap,
  });

  IconData _getIconForTransaction(HistoryTransaction entry) {
    final method = entry.metodePembayaran.toLowerCase();
    final firstProduct = entry.details.isNotEmpty ? entry.details.first.productName.toLowerCase() : '';

    if (method.contains('bank') || method.contains('transfer') || method.contains('bca') || method.contains('mandiri')) {
      return Icons.account_balance_rounded;
    }
    if (method.contains('listrik') || method.contains('pln') || firstProduct.contains('listrik') || firstProduct.contains('pln')) {
      return Icons.receipt_rounded;
    }
    if (method.contains('wallet') || method.contains('gopay') || method.contains('ovo') || method.contains('dana') || method.contains('linkaja') || firstProduct.contains('gopay') || firstProduct.contains('wallet')) {
      return Icons.phone_android_rounded;
    }
    if (method.contains('qris') || method.contains('merchant') || firstProduct.contains('qris')) {
      return Icons.shopping_bag_rounded;
    }

    return Icons.shopping_bag_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF0F3F8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F0FE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForTransaction(entry),
                        color: const Color(0xFF000B60),
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.kode,
                                style: const TextStyle(
                                  color: Color(0xFF4955B3),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                _formatShortDateTime(entry.tanggal),
                                style: const TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.metodePembayaran,
                                  style: const TextStyle(
                                    color: Color(0xFF191C1D),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${entry.totalItems} item',
                                style: const TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              _StatusBadge(status: entry.status),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: _DashedLinePainter(color: const Color(0xFFE5EAF2)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    CurrencyFormatter.format(entry.totalHarga, symbol: 'Rp'),
                    style: const TextStyle(
                      color: Color(0xFF191C1D),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isSelesai = status.toLowerCase() == 'selesai';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isSelesai
            ? const Color(0xFFE2F0D9)
            : const Color(0xFFFCE8E6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isSelesai
              ? const Color(0xFF388E3C)
              : const Color(0xFFC5221F),
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }
}

class _EmptyListState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyListState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: context.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.indigoSurfaceTint.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              size: 32, color: context.textSecondary),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTypePairing.titleMd(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: AppTypePairing.bodySm(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HistoryDetailPage extends ConsumerWidget {
  final HistoryTransaction entry;

  const _HistoryDetailPage({
    required this.entry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);
    final appSettings = settingsState.appSettings;
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Transaksi',
          style: AppTextStyles.headingSmall.copyWith(color: context.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          const SizedBox(height: 8),
          _StatusCard(entry: entry),
          const SizedBox(height: 12),
          _InfoCard(entry: entry, appSettings: appSettings),
          const SizedBox(height: 16),
          _ItemsCard(entry: entry),
          const SizedBox(height: 16),
          _SummaryCard(entry: entry),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (settingsState.isLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tunggu sebentar, data toko sedang dimuat...')),
                  );
                  return;
                }

                if (appSettings == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memuat rincian toko. Mencoba memuat kembali...'),
                      backgroundColor: context.error,
                    ),
                  );
                  ref.read(settingsControllerProvider.notifier).loadSettings();
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menyiapkan data cetak...'),
                    duration: Duration(milliseconds: 500),
                  ),
                );

                final formattedItems = entry.details.map((d) => _PurchasedItemData(
                  name: d.productName, qty: d.qty, lineTotal: d.subtotal,
                )).toList();

                final tanggalJamStr = DateFormat('dd MMM yyyy, HH:mm').format(entry.tanggal);

                final success = await ThermalPrinterService.printReceipt(
                  storeName: appSettings['nama_toko'] ?? 'MITRA POS',
                  address: null,
                  slogan: appSettings['deskripsi']?['slogan'],
                  orderId: entry.kode,
                  tanggalJam: tanggalJamStr,
                  items: formattedItems,
                  subtotal: entry.totalHarga,
                  biayaAdmin: entry.biayaAdmin,
                  total: entry.totalHarga + entry.biayaAdmin,
                  metodePembayaran: entry.metodePembayaran,
                  footer: appSettings['footer_nota'],
                  appSettings: appSettings,
                );

                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Struk berhasil dicetak ulang!'), backgroundColor: context.success),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mencetak struk. Pastikan printer terhubung.'), backgroundColor: context.error),
                    );
                  }
                }
              },
              icon: const Icon(Icons.print_rounded, size: 20),
              label: const Text('Cetak Ulang Struk', style: TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.indigoPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: AppTextStyles.button,
              ),
            ),
          ),
          if (entry.metodePembayaran == 'Piutang' && entry.status != 'Selesai') ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showSettleDialog(context, ref, entry),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: const Text('Pelunasan Piutang', style: TextStyle(fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: context.indigoPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  side: BorderSide(color: context.border, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: AppTextStyles.button.copyWith(color: context.indigoPrimary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;

  const _DashboardCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusCard extends StatelessWidget {
  final HistoryTransaction entry;

  const _StatusCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isCompleted = entry.status.toLowerCase() == 'selesai';
    final isPiutang = entry.metodePembayaran.toLowerCase() == 'piutang';
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (isCompleted) {
      statusColor = context.success;
      statusIcon = Icons.check_circle_rounded;
      statusText = 'Selesai';
    } else if (isPiutang) {
      statusColor = context.warning;
      statusIcon = Icons.schedule_rounded;
      statusText = 'Piutang';
    } else {
      statusColor = context.textSecondary;
      statusIcon = Icons.info_outline_rounded;
      statusText = entry.status;
    }

    return _DashboardCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.kode,
                  style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatFullDateTime(entry.tanggal),
                  style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: AppTextStyles.labelSmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final HistoryTransaction entry;
  final Map<String, dynamic>? appSettings;

  const _InfoCard({required this.entry, this.appSettings});

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Transaksi',
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Kasir', value: entry.cashierName.isNotEmpty ? entry.cashierName : '-'),
          const SizedBox(height: 12),
          _InfoRow(label: 'Metode Bayar', value: entry.metodePembayaran),
          if (entry.catatan.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(label: 'Catatan', value: entry.catatan),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
          ),
        ),
        Text(':', style: AppTextStyles.bodySmall),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final HistoryTransaction entry;

  const _ItemsCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Produk',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${entry.totalSku} item',
                style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entry.details.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Tidak ada item',
                  style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
                ),
              ),
            )
          else
            Column(
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Produk',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Qty',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Harga',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Subtotal',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 8),
                // Items
                ...entry.details.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ItemRow(item: item),
                    )),
              ],
            ),
          ],
        )); 
  }
}

class _ItemRow extends StatelessWidget {
  final HistoryDetail item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final hargaPerItem = item.qty > 0 ? item.subtotal ~/ item.qty : item.harga;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            item.productName,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            item.qty.toString(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            CurrencyFormatter.format(hargaPerItem, symbol: ''),
            textAlign: TextAlign.right,
            style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            CurrencyFormatter.format(item.subtotal, symbol: ''),
            textAlign: TextAlign.right,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final HistoryTransaction entry;

  const _SummaryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final grandTotal = entry.totalHarga + entry.biayaAdmin;
    
    return _DashboardCard(
      child: Column(
        children: [
          _SummaryRow(label: 'Jumlah Item', value: entry.totalItems.toString()),
          _SummaryRow(label: 'Subtotal', value: CurrencyFormatter.format(entry.totalHarga, symbol: 'Rp ')),
          if (entry.biayaAdmin > 0)
            _SummaryRow(label: 'Biaya Admin', value: CurrencyFormatter.format(entry.biayaAdmin, symbol: 'Rp ')),
          _SummaryRow(label: 'Metode Bayar', value: entry.metodePembayaran),
          const SizedBox(height: 4),
          const Divider(height: 1, thickness: 1.5),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Grand Total',
            value: CurrencyFormatter.format(grandTotal, symbol: 'Rp '),
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = isTotal
        ? AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w700)
        : AppTextStyles.bodyMedium.copyWith(color: context.textSecondary);
    final valueStyle = isTotal
        ? AppTextStyles.headingMedium.copyWith(fontWeight: FontWeight.w800, color: context.indigoPrimary)
        : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

void _showSettleDialog(BuildContext context, WidgetRef ref, HistoryTransaction entry) {
    final settingsState = ref.read(settingsControllerProvider);
    final appSettings = settingsState.appSettings;
    final totalHutang = entry.totalHarga + entry.biayaAdmin;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Set default admin fee if QRIS is already pre-calculated in settings
            String defaultAdminFee = '0';
            if (appSettings != null && appSettings['biaya_admin_qris'] != null) {
                defaultAdminFee = appSettings['biaya_admin_qris'].toString();
            }

            return _SettleDialogContent(
              entry: entry,
              totalHutang: totalHutang,
              initialAdminFee: double.tryParse(defaultAdminFee) ?? 0,
              onSettle: (method, adminFee) async {
                try {
                  await ref
                      .read(historyControllerProvider.notifier)
                      .settleTransaction(entry.id, method, biayaAdmin: adminFee);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Piutang berhasil dilunasi via $method'),
                        backgroundColor: context.success,
                      ),
                    );
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close detail page
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal melunasi piutang: $e'),
                        backgroundColor: context.error,
                      ),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
}

class _SettleDialogContent extends ConsumerStatefulWidget {
  final HistoryTransaction entry;
  final int totalHutang;
  final double initialAdminFee;
  final Function(String method, double? adminFee) onSettle;

  const _SettleDialogContent({
    required this.entry,
    required this.totalHutang,
    required this.initialAdminFee,
    required this.onSettle,
  });

  @override
  ConsumerState<_SettleDialogContent> createState() => _SettleDialogContentState();
}

class _SettleDialogContentState extends ConsumerState<_SettleDialogContent> {
  String? _selectedMethod;
  final TextEditingController _cashController = TextEditingController();
  int _uangBayar = 0;
  bool _applyAdminFee = true;
  String? _selectedBank;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _updateUangBayar(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      _uangBayar = int.tryParse(cleanValue) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsControllerProvider);
    final bankList = settingsState.appSettings?['rekening_bank'] as List? ?? [];
    
    final adminFeeVal = _applyAdminFee ? widget.initialAdminFee : 0.0;
    final totalTagihan = widget.totalHutang + (_selectedMethod == 'QRIS' ? adminFeeVal : 0);
    final kembalian = _uangBayar - totalTagihan;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Pelunasan Piutang', style: AppTypePairing.titleMd(weight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            'Invoice: ${widget.entry.kode}',
            style: AppTypePairing.bodySm(color: context.textSecondary, weight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          
          if (_selectedMethod == null) ...[
            Text('Pilih Metode Pembayaran', style: AppTypePairing.bodyMd(weight: FontWeight.w800)),
            const SizedBox(height: 16),
            _PaymentMethodOption(
              label: 'Tunai',
              icon: Icons.payments_rounded,
              onTap: () => setState(() => _selectedMethod = 'Tunai'),
            ),
            const SizedBox(height: 12),
            _PaymentMethodOption(
              label: 'QRIS',
              icon: Icons.qr_code_scanner_rounded,
              onTap: () => setState(() => _selectedMethod = 'QRIS'),
            ),
            const SizedBox(height: 12),
            _PaymentMethodOption(
              label: 'Transfer',
              icon: Icons.account_balance_rounded,
              onTap: () => setState(() => _selectedMethod = 'Transfer'),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primaryFixed.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedMethod == 'Tunai'
                      ? Icons.payments_rounded
                      : (_selectedMethod == 'QRIS' ? Icons.qr_code_scanner_rounded : Icons.account_balance_rounded),
                    color: context.indigoPrimary,
                  ),
                  const SizedBox(width: 10),
                  Text(_selectedMethod!, style: AppTypePairing.bodySm(weight: FontWeight.w900, color: context.indigoPrimary)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedMethod = null;
                      _uangBayar = 0;
                      _applyAdminFee = true;
                      _selectedBank = null;
                      _cashController.clear();
                    }),
                    child: const Text('Ubah'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Tagihan', style: AppTypePairing.bodySm(color: context.textSecondary)),
                Text(
                  CurrencyFormatter.format(widget.totalHutang, symbol: 'Rp'),
                  style: AppTypePairing.bodyMd(weight: FontWeight.w800),
                ),
              ],
            ),
            
            if (_selectedMethod == 'QRIS' && widget.initialAdminFee > 0) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: _applyAdminFee,
                      activeColor: context.indigoPrimary,
                      onChanged: (v) => setState(() => _applyAdminFee = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Biaya Admin QRIS: ${CurrencyFormatter.format(widget.initialAdminFee.toInt(), symbol: 'Rp')}',
                    style: AppTypePairing.bodySm(weight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Akhir', style: AppTypePairing.bodySm(weight: FontWeight.w800)),
                  Text(
                    CurrencyFormatter.format(totalTagihan.toInt(), symbol: 'Rp'),
                    style: AppTypePairing.bodyMd(color: context.indigoPrimary, weight: FontWeight.w900),
                  ),
                ],
              ),
            ],

            if (_selectedMethod == 'Transfer' && bankList.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Text('Pilih Bank Tujuan:', style: AppTypePairing.bodySm(weight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: bankList.map((bank) {
                  final String bankName = bank['bank'] ?? '-';
                  final isSelected = _selectedBank == bankName;
                  return ChoiceChip(
                    label: Text(bankName),
                    selected: isSelected,
                    onSelected: (s) => setState(() => _selectedBank = s ? bankName : null),
                    selectedColor: context.primaryFixed,
                    labelStyle: AppTypePairing.bodySm(
                      color: isSelected ? context.indigoPrimary : context.textPrimary,
                      weight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ],

if (_selectedMethod == 'Tunai') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: _updateUangBayar,
                decoration: InputDecoration(
                  labelText: 'Uang Diterima',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kembalian >= 0 ? context.successLight.withValues(alpha: 0.1) : context.errorLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      kembalian >= 0 ? 'Kembalian' : 'Kekurangan',
                      style: AppTypePairing.bodySm(weight: FontWeight.w700),
                    ),
                    Text(
                      CurrencyFormatter.format(kembalian.abs().toInt(), symbol: 'Rp'),
                      style: AppTypePairing.bodyMd(
                        color: kembalian >= 0 ? context.success : context.error,
                        weight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: (_selectedMethod == 'Tunai' && kembalian < 0) || (_selectedMethod == 'Transfer' && _selectedBank == null)
                  ? null
                  : () => widget.onSettle(_selectedMethod!, _selectedMethod == 'QRIS' && _applyAdminFee ? widget.initialAdminFee : 0),
                style: FilledButton.styleFrom(
                  backgroundColor: context.indigoPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Konfirmasi Pelunasan',
                  style: AppTypePairing.bodySm(color: Colors.white, weight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: context.indigoPrimary, size: 20),
            ),
            const SizedBox(width: 14),
            Text(label, style: AppTypePairing.bodySm(weight: FontWeight.w800)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: context.textTertiary),
          ],
        ),
      ),
    );
  }
}



class _PurchasedItemData {
  final String name;
  final int qty;
  final int lineTotal;

  _PurchasedItemData({
    required this.name,
    required this.qty,
    required this.lineTotal,
  });
}

