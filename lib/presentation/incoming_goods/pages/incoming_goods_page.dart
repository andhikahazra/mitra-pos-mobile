import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/widgets/mitrapos_bottom_nav_bar.dart';
import 'package:mitrapos/core/widgets/mitrapos_sidebar.dart';
import 'package:mitrapos/core/widgets/skeleton.dart';
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

  Widget _incomingItemCard(Map<String, dynamic> item) {
    final supplierName = item['supplier']?['nama'] ?? 'Supplier Unknown';
    final dateStr = item['tanggal_terima'] ?? item['tanggal_pesan'] ?? '';
    final formattedDate = dateStr.isNotEmpty 
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr).toLocal())
        : '-';
    final status = item['status'] ?? 'Pending';
    final totalItems = (item['detail'] as List?)?.length ?? 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncomingGoodsDetailPage(data: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 17, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['kode'] ?? '-',
                    style: AppTypePairing.titleMd(weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$supplierName • $formattedDate',
                    style: AppTypePairing.bodySm(),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '$totalItems item',
                        style: AppTypePairing.labelSmCaps(),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'Diterima' || status == 'Disetujui' || status == 'Selesai'
                              ? AppColors.successLight
                              : (status == 'Ditolak' 
                                  ? AppColors.errorLight 
                                  : AppColors.warningLight),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status,
                          style: AppTypePairing.labelSmCaps(
                            color: status == 'Diterima' || status == 'Disetujui' || status == 'Selesai'
                                ? AppColors.success
                                : (status == 'Ditolak' 
                                    ? AppColors.error 
                                    : AppColors.warning),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incomingGoodsControllerProvider);
    final incomingItems = state.incomingGoods;
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
          physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                gradient: AppColors.indigoActionGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.move_to_inbox_outlined, color: AppColors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Barang Masuk',
                        style: AppTypePairing.titleMd(color: AppColors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelola dokumen penerimaan barang dari supplier dengan lebih cepat.',
                    style: AppTypePairing.bodySm(color: AppColors.white.withValues(alpha: 0.88)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const IncomingGoodsFormPage()),
                        );
                        _onRefresh(); // Refresh after return from form
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Tambah Penerimaan'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(0, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (state.isLoading && incomingItems.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: IncomingGoodsSkeleton(),
              )
            else if (incomingItems.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textTertiary.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text('Belum ada data penerimaan', style: AppTypePairing.bodySm(color: AppColors.textTertiary)),
                    const SizedBox(height: 40),
                  ],
                ),
              )
            else ...[
              Row(
                children: [
                  Text('Daftar Barang Masuk', style: AppTypePairing.titleMd()),
                  const Spacer(),
                  Text('${incomingItems.length} dokumen', style: AppTypePairing.bodySm()),
                ],
              ),
              const SizedBox(height: 8),
              ...incomingItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _incomingItemCard(item),
                ),
              ),
            ],
          ],
        ),
      );
  }

    if (isTablet) {
      return Scaffold(
        backgroundColor: AppColors.surface,
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Penerimaan Barang',
          style: AppTypePairing.titleMd(
            color: const Color(0xFF000B60),
            weight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
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
