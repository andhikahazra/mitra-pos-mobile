import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/widgets/mitrapos_bottom_nav_bar.dart';
import 'package:mitrapos/core/widgets/mitrapos_sidebar.dart';
import 'package:mitrapos/presentation/home/pages/home_page.dart';
import 'package:mitrapos/presentation/incoming_goods/bloc/incoming_goods_controller.dart';
import 'package:mitrapos/presentation/incoming_goods/pages/incoming_goods_form_page.dart';
import 'package:mitrapos/presentation/incoming_goods/pages/incoming_goods_detail_page.dart';
import 'package:mitrapos/presentation/products/pages/products_page.dart';
import 'package:mitrapos/presentation/history/pages/history_page.dart';
import 'package:mitrapos/presentation/transactions/pages/transactions_page.dart';

class IncomingGoodsPage extends ConsumerStatefulWidget {
  const IncomingGoodsPage({super.key});

  @override
  ConsumerState<IncomingGoodsPage> createState() => _IncomingGoodsPageState();
}

class _IncomingGoodsPageState extends ConsumerState<IncomingGoodsPage> {
  String _filterStatus = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incomingGoodsControllerProvider.notifier).loadIncomingGoodsHistory();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(incomingGoodsControllerProvider.notifier).loadIncomingGoodsHistory();
  }

  bool _matchesFilter(Map<String, dynamic> item) {
    final status = item['status'] ?? 'Pending';
    if (_filterStatus != 'Semua' && status != _filterStatus) {
      return false;
    }
    if (_searchQuery.isNotEmpty) {
      final kode = (item['kode'] ?? '').toString().toLowerCase();
      final supplier = (item['supplier']?['nama'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      if (!kode.contains(q) && !supplier.contains(q)) {
        return false;
      }
    }
    return true;
  }

  Color _statusColor(String s) {
    if (s == 'Diterima' || s == 'Disetujui' || s == 'Selesai') {
      return AppColors.success;
    }
    if (s == 'Ditolak') {
      return AppColors.error;
    }
    return AppColors.warning;
  }

  Color _statusBg(String s) {
    if (s == 'Diterima' || s == 'Disetujui' || s == 'Selesai') {
      return AppColors.successLight;
    }
    if (s == 'Ditolak') {
      return AppColors.errorLight;
    }
    return AppColors.warningLight;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incomingGoodsControllerProvider);
    final allItems = state.incomingGoods;
    final filteredItems = allItems.where(_matchesFilter).toList();
    final isTablet = MediaQuery.of(context).size.width >= 800;

    void handleNav(int index) {
      if (index == 0) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else if (index == 1) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsPage()));
      } else if (index == 2) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TransactionsPage()));
      } else if (index == 3) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
      }
    }

    Widget incomingBody() {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Cari kode atau supplier',
                      hintStyle: AppTypePairing.bodySm(),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      isDense: true,
                    ),
                    style: AppTypePairing.bodySm(color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (context, index) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      const opts = ['Semua', 'Pending', 'Diterima', 'Selesai', 'Ditolak'];
                      final opt = opts[index];
                      final active = _filterStatus == opt;
                      return GestureDetector(
                        onTap: () => setState(() => _filterStatus = opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: active ? AppColors.primary : AppColors.border,
                              width: active ? 0 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            opt,
                            style: AppTypePairing.labelSmCaps(
                              color: active ? AppColors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text('Daftar Barang Masuk', style: AppTypePairing.titleMd()),
                    const Spacer(),
                    Text(
                      '${filteredItems.length} dokumen',
                      style: AppTypePairing.bodySm(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            if (filteredItems.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Tidak ada hasil',
                    subtitle: 'Coba ubah filter atau kata kunci pencarian.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _IncomingItemCard(
                    item: filteredItems[index],
                    statusColor: _statusColor,
                    statusBg: _statusBg,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (isTablet) {
      return Scaffold(
        backgroundColor: AppColors.surfaceContainerLowest,
        body: SafeArea(
          child: Row(
            children: [
              MitraPOSSidebar(currentIndex: 4, onTap: handleNav),
              Expanded(child: incomingBody()),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Penerimaan Barang',
          style: AppTypePairing.titleMd(color: AppColors.textPrimary, weight: FontWeight.w800),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomingGoodsFormPage()));
                _onRefresh();
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Baru'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: AppTypePairing.labelSmCaps(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MitraPOSBottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsPage()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TransactionsPage()));
          } else if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
          }
        },
      ),
      body: incomingBody(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(title, style: AppTypePairing.titleMd(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTypePairing.bodySm(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _IncomingItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color Function(String) statusColor;
  final Color Function(String) statusBg;

  const _IncomingItemCard({
    required this.item,
    required this.statusColor,
    required this.statusBg,
  });

  @override
  Widget build(BuildContext context) {
    final supplierName = item['supplier']?['nama'] ?? 'Unknown';
    final dateStr = item['tanggal_terima'] ?? item['tanggal_pesan'] ?? '';
    final formattedDate = dateStr.isNotEmpty
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr).toLocal())
        : '-';
    final status = item['status'] ?? 'Pending';
    final totalItems = (item['detail'] as List?)?.length ?? 0;
    final initial = supplierName.isNotEmpty ? supplierName[0].toUpperCase() : '?';

    double totalAmount = 0;
    for (var d in (item['detail'] as List?) ?? []) {
      final price = double.tryParse(d['harga'].toString()) ?? 0;
      final qty = int.tryParse(d['jumlah'].toString()) ?? 0;
      totalAmount += price * qty;
    }

    String rupiah(double v) {
      final d = v.toInt().toString();
      final buf = StringBuffer();
      for (var i = 0; i < d.length; i++) {
        buf.write(d[i]);
        final ri = d.length - i;
        if (ri > 1 && ri % 3 == 1) {
          buf.write('.');
        }
      }
      return buf.toString();
    }

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IncomingGoodsDetailPage(data: item)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(initial, style: AppTypePairing.titleMd(color: AppColors.primary, weight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['kode'] ?? '-',
                            style: AppTypePairing.valueMd(color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBg(status),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(status, style: AppTypePairing.labelSmCaps(color: statusColor(status))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(supplierName, style: AppTypePairing.bodySm(color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(formattedDate, style: AppTypePairing.labelSmCaps(color: AppColors.textTertiary)),
                        const SizedBox(width: 10),
                        Text('$totalItems item', style: AppTypePairing.labelSmCaps(color: AppColors.textTertiary)),
                        if (totalAmount > 0) ...[
                          const SizedBox(width: 10),
                          Text(
                            'Rp ${rupiah(totalAmount)}',
                            style: AppTypePairing.labelSmCaps(color: AppColors.primary, weight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}