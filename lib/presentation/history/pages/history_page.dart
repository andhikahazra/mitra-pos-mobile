import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/utils/currency_formatter.dart';
import 'package:mitrapos/core/widgets/mitrapos_bottom_nav_bar.dart';
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

  final List<String> _rangeLabels = const ['All', 'Hari', 'Minggu', 'Bulan'];

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

    final filteredEntries = state.transactions.where(_matchesSearch).toList();

    // Map label to index for UI
    int activeRangeIndex = _rangeLabels.indexWhere(
      (l) => l.toLowerCase() == state.activeRange.toLowerCase(),
    );
    if (activeRangeIndex == -1) activeRangeIndex = 0;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF000B60),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
          },
        ),
        title: Text(
          'Riwayat Transaksi',
          style: AppTypePairing.headlineLg(
            color: const Color(0xFF000B60),
            weight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF000B60),
            ),
            onPressed: () {
              // Menu action
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: MitraPOSBottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProductsPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TransactionsPage()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const IncomingGoodsPage()),
            );
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FB),
                      borderRadius: BorderRadius.circular(14),
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
                            size: 22, color: Color(0xFF757575)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: const Color(0xFFF4F7FB),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      int tempRange = activeRangeIndex;
                      DateTime? tempDate = state.selectedDate;

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (sheetContext) {
                          return StatefulBuilder(
                            builder: (context, setSheetState) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                ),
                                padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 44,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: AppColors.borderLight,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    Text('Filter Periode',
                                        style: AppTypePairing.titleMd(
                                            weight: FontWeight.w900)),
                                    const SizedBox(height: 18),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: List.generate(
                                          _rangeLabels.length, (index) {
                                        final isSelected = tempRange == index;
                                        return InkWell(
                                          onTap: () => setSheetState(
                                              () => tempRange = index),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 18, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors
                                                      .surfaceContainerLow,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected ? AppColors.primary : Colors.transparent,
                                              ),
                                            ),
                                            child: Text(
                                              _rangeLabels[index],
                                              style: AppTypePairing.bodySm(
                                                color: isSelected
                                                    ? AppColors.white
                                                    : AppColors.textPrimary,
                                                weight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 28),
                                    Text('Tanggal Spesifik',
                                        style: AppTypePairing.titleMd(
                                            weight: FontWeight.w900)),
                                    const SizedBox(height: 14),
                                    InkWell(
                                      onTap: () async {
                                        final now = DateTime.now();
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: tempDate ?? now,
                                          firstDate: DateTime(2020),
                                          lastDate:
                                              DateTime(now.year + 1, 12, 31),
                                        );
                                        if (picked != null) {
                                          setSheetState(() {
                                            tempDate = DateTime(picked.year,
                                                picked.month, picked.day);
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainerLow,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.calendar_month_rounded,
                                                size: 20,
                                                color: AppColors.primary),
                                            const SizedBox(width: 14),
                                            Text(
                                              tempDate == null
                                                  ? 'Pilih Tanggal'
                                                  : _formatShortDate(tempDate!),
                                              style: AppTypePairing.bodyMd(
                                                weight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (tempDate != null)
                                              IconButton(
                                                onPressed: () => setSheetState(
                                                    () => tempDate = null),
                                                icon: const Icon(Icons.close,
                                                    size: 20),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 36),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () {
                                              notifier.setRange('all');
                                              notifier.setDate(null);
                                              Navigator.pop(sheetContext);
                                            },
                                            child: Text('Reset',
                                                style: AppTypePairing.bodyMd(
                                                    color:
                                                        AppColors.textSecondary,
                                                    weight: FontWeight.w800)),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: FilledButton(
                                            onPressed: () {
                                              notifier.setRange(
                                                  _rangeLabels[tempRange]);
                                              notifier.setDate(tempDate);
                                              Navigator.pop(sheetContext);
                                            },
                                            style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              minimumSize:
                                                  const Size.fromHeight(56),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16)),
                                              elevation: 2,
                                              shadowColor: AppColors.primary.withValues(alpha: 0.3),
                                            ),
                                            child: Text('Terapkan Filter',
                                                style: AppTypePairing.bodyMd(
                                                    color: AppColors.white,
                                                    weight: FontWeight.w800)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: const Icon(Icons.tune_rounded,
                          color: Color(0xFF555555), size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Horizontal scrolling filter chips
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  isSelected: state.activeRange.toLowerCase() == 'all' &&
                      state.selectedDate == null &&
                      !_onlySuccess,
                  onTap: () {
                    setState(() {
                      _onlySuccess = false;
                    });
                    notifier.setRange('all');
                    notifier.setDate(null);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Bulan Ini',
                  isSelected: state.activeRange.toLowerCase() == 'bulan',
                  onTap: () {
                    if (state.activeRange.toLowerCase() == 'bulan') {
                      notifier.setRange('all');
                    } else {
                      notifier.setRange('Bulan');
                    }
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Sukses',
                  isSelected: _onlySuccess,
                  onTap: () {
                    setState(() {
                      _onlySuccess = !_onlySuccess;
                    });
                  },
                ),
                const SizedBox(width: 8),
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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF000B60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Daftar Transaksi',
                  style: TextStyle(
                    color: const Color(0xFF000B60),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? Center(child: Text(state.errorMessage!))
                    : RefreshIndicator(
                        onRefresh: () async {
                          await notifier.loadHistory();
                        },
                        color: AppColors.primary,
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
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8F0FE)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
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
                size: 14,
                color: isSelected ? const Color(0xFF000B60) : const Color(0xFF636E72),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF000B60) : const Color(0xFF636E72),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
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

  String _getTransactionDetailText(HistoryTransaction entry) {
    if (entry.details.isEmpty) {
      return '${entry.totalItems} Item';
    }
    final firstProduct = entry.details.first.productName;
    final method = entry.metodePembayaran.toLowerCase();
    if (method.contains('bank') || method.contains('transfer') || method.contains('tunai') || method.isEmpty) {
      final unit = entry.totalItems == 1 ? 'Item' : 'Items';
      return '${entry.totalItems} $unit • $firstProduct';
    } else {
      return firstProduct;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF0F3F8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F0FE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForTransaction(entry),
                        color: const Color(0xFF000B60),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatShortDateTime(entry.tanggal),
                                style: const TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.metodePembayaran,
                                  style: const TextStyle(
                                    color: Color(0xFF191C1D),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusBadge(status: entry.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getTransactionDetailText(entry),
                            style: const TextStyle(
                              color: Color(0xFF757575),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: _DashedLinePainter(color: const Color(0xFFE5EAF2)),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    CurrencyFormatter.format(entry.totalHarga, symbol: 'Rp'),
                    style: const TextStyle(
                      color: Color(0xFF191C1D),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelesai
            ? const Color(0xFFE2F0D9)
            : const Color(0xFFFCE8E6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isSelesai
              ? const Color(0xFF388E3C)
              : const Color(0xFFC5221F),
          fontWeight: FontWeight.bold,
          fontSize: 10,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.indigoSurfaceTint.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_rounded,
              size: 36, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypePairing.titleMd(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
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
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Detail Transaksi',
          style: AppTypePairing.titleMd(weight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          // Premium Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Total Pembayaran',
                  style: AppTypePairing.bodySm(
                    color: AppColors.white.withValues(alpha: 0.8),
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.format(entry.totalHarga, symbol: 'Rp'),
                  style: AppTypePairing.headlineLg(
                    color: AppColors.white,
                    weight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        entry.status == 'Selesai'
                            ? Icons.verified_rounded
                            : Icons.pending_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.status.toUpperCase(),
                        style: AppTypePairing.labelSmCaps(
                          color: AppColors.white,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Transaction Info Grid
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'ID Transaksi',
                  value: entry.kode,
                  icon: Icons.qr_code_2_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoTile(
                  label: 'Waktu',
                  value: _formatFullDateTime(entry.tanggal),
                  icon: Icons.schedule_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Kasir',
                  value: entry.cashierName,
                  icon: Icons.person_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoTile(
                  label: 'Metode',
                  value: entry.metodePembayaran,
                  icon: Icons.wallet_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          Text(
            'Item Terjual (${entry.totalItems})',
            style: AppTypePairing.titleMd(weight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          ...entry.details.map((item) => _ItemCard(item: item)),

          const SizedBox(height: 32),
          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                 _SummaryRow(label: 'Subtotal', value: entry.totalHarga),
                if (entry.biayaAdmin > 0)
                  _SummaryRow(label: 'Biaya Admin', value: entry.biayaAdmin),
                _SummaryRow(label: 'Diskon', value: 0),
                _SummaryRow(label: 'Pajak', value: 0),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Akhir',
                      style: AppTypePairing.bodyMd(weight: FontWeight.w800),
                    ),
                    Text(
                      CurrencyFormatter.format(entry.totalHarga + entry.biayaAdmin, symbol: 'Rp'),
                      style: AppTypePairing.titleMd(
                        color: AppColors.primary,
                        weight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () async {
                if (settingsState.isLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tunggu sebentar, data toko sedang dimuat...')),
                  );
                  return;
                }

                if (appSettings == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal memuat rincian toko. Mencoba memuat kembali...'),
                      backgroundColor: AppColors.error,
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
                  name: d.productName,
                  qty: d.qty,
                  lineTotal: d.subtotal,
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
                      const SnackBar(
                        content: Text('Struk berhasil dicetak ulang!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal mencetak struk. Pastikan printer terhubung.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.print_rounded),
              label: Text(
                'Cetak Ulang Struk',
                style: AppTypePairing.bodyMd(
                  color: AppColors.white,
                  weight: FontWeight.w800,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (entry.metodePembayaran == 'Piutang' && entry.status != 'Selesai') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _showSettleDialog(context, ref, entry),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  'Pelunasan Piutang',
                  style: AppTypePairing.bodyMd(
                    color: AppColors.primary,
                    weight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
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
                        backgroundColor: AppColors.success,
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
                        backgroundColor: AppColors.error,
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('Pelunasan Piutang', style: AppTypePairing.titleMd(weight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            'Invoice: ${widget.entry.kode}',
            style: AppTypePairing.bodySm(color: AppColors.textSecondary, weight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedMethod == 'Tunai' 
                      ? Icons.payments_rounded 
                      : (_selectedMethod == 'QRIS' ? Icons.qr_code_scanner_rounded : Icons.account_balance_rounded),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(_selectedMethod!, style: AppTypePairing.bodyMd(weight: FontWeight.w900, color: AppColors.primary)),
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
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Tagihan', style: AppTypePairing.bodyMd(color: AppColors.textSecondary)),
                Text(
                  CurrencyFormatter.format(widget.totalHutang, symbol: 'Rp'),
                  style: AppTypePairing.titleMd(weight: FontWeight.w800),
                ),
              ],
            ),
            
            if (_selectedMethod == 'QRIS' && widget.initialAdminFee > 0) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _applyAdminFee,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _applyAdminFee = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Biaya Admin QRIS: ${CurrencyFormatter.format(widget.initialAdminFee.toInt(), symbol: 'Rp')}',
                    style: AppTypePairing.bodySm(weight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Akhir', style: AppTypePairing.bodyMd(weight: FontWeight.w800)),
                  Text(
                    CurrencyFormatter.format(totalTagihan.toInt(), symbol: 'Rp'),
                    style: AppTypePairing.titleMd(color: AppColors.primary, weight: FontWeight.w900),
                  ),
                ],
              ),
            ],

            if (_selectedMethod == 'Transfer' && bankList.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Text('Pilih Bank Tujuan:', style: AppTypePairing.bodySm(weight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: bankList.map((bank) {
                  final String bankName = bank['bank'] ?? '-';
                  final isSelected = _selectedBank == bankName;
                  return ChoiceChip(
                    label: Text(bankName),
                    selected: isSelected,
                    onSelected: (s) => setState(() => _selectedBank = s ? bankName : null),
                    selectedColor: AppColors.primaryFixed,
                    labelStyle: AppTypePairing.bodySm(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      weight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ],

            if (_selectedMethod == 'Tunai') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: _updateUangBayar,
                decoration: InputDecoration(
                  labelText: 'Uang Diterima',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kembalian >= 0 ? AppColors.successLight.withValues(alpha: 0.1) : AppColors.errorLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      kembalian >= 0 ? 'Kembalian' : 'Kekurangan',
                      style: AppTypePairing.bodyMd(weight: FontWeight.w700),
                    ),
                    Text(
                      CurrencyFormatter.format(kembalian.abs().toInt(), symbol: 'Rp'),
                      style: AppTypePairing.titleMd(
                        color: kembalian >= 0 ? AppColors.success : AppColors.error,
                        weight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: (_selectedMethod == 'Tunai' && kembalian < 0) || (_selectedMethod == 'Transfer' && _selectedBank == null)
                  ? null 
                  : () => widget.onSettle(_selectedMethod!, _selectedMethod == 'QRIS' && _applyAdminFee ? widget.initialAdminFee : 0),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Konfirmasi Pelunasan',
                  style: AppTypePairing.bodyMd(color: AppColors.white, weight: FontWeight.w800),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Text(label, style: AppTypePairing.bodyMd(weight: FontWeight.w800)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
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

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTypePairing.labelSmCaps(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypePairing.bodySm(
              weight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final HistoryDetail item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTypePairing.bodyMd(weight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.qty} x ${CurrencyFormatter.format(item.harga, symbol: 'Rp')}',
                  style: AppTypePairing.bodySm(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(item.subtotal, symbol: 'Rp'),
            style: AppTypePairing.bodyMd(
              weight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final int value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypePairing.bodySm(color: AppColors.textSecondary)),
          Text(
            CurrencyFormatter.format(value, symbol: 'Rp'),
            style: AppTypePairing.bodySm(weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

