import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';
import 'package:mitrapos/core/utils/currency_formatter.dart';

import 'package:mitrapos/data/transactions/repositories/transactions_repository_impl.dart';
import 'package:mitrapos/domain/transactions/entities/transaction_product.dart';
import 'package:mitrapos/domain/transactions/usecases/get_transaction_products.dart';
import 'package:mitrapos/presentation/home/pages/home_page.dart';
import 'package:mitrapos/presentation/home/widgets/period_filter_chip.dart';
import 'package:mitrapos/domain/transactions/usecases/save_transaction.dart';
import 'package:mitrapos/domain/transactions/usecases/get_customer_history.dart';
import 'package:mitrapos/data/transactions/datasources/transactions_remote_data_source.dart';
import 'package:mitrapos/core/network/dio_client.dart';
import 'package:mitrapos/core/di/injection.dart';
import 'package:mitrapos/presentation/transactions/controller/transactions_controller.dart';

import 'package:mitrapos/core/widgets/order_summary_widget.dart';
import 'package:mitrapos/core/widgets/mitrapos_bottom_nav_bar.dart';
import 'package:mitrapos/core/widgets/mitrapos_sidebar.dart';
import 'package:mitrapos/core/widgets/skeleton.dart';
import 'package:mitrapos/presentation/incoming_goods/pages/incoming_goods_page.dart';
import 'package:mitrapos/presentation/products/pages/products_page.dart';
import 'package:mitrapos/presentation/history/pages/history_page.dart';
import 'package:mitrapos/core/services/thermal_printer_service.dart';

const Color _posBlueDark = AppColors.indigoPrimary;
const Color _posBlueSoft = AppColors.primaryFixed;

String _formatTanggalJamIndonesia(DateTime date) {
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

  final d = date.day.toString().padLeft(2, '0');
  final m = bulan[date.month - 1];
  final y = date.year;
  final h = date.hour.toString().padLeft(2, '0');
  final min = date.minute.toString().padLeft(2, '0');
  return '$d $m $y, $h:$min';
}

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        transactionsControllerProvider.overrideWith((providerRef) {
          final dioClient = getIt<DioClient>();
          final remoteDataSource = TransactionsRemoteDataSourceImpl(dioClient);
          final repository = TransactionsRepositoryImpl(remoteDataSource);

          return TransactionsController(
            getTransactionProducts: GetTransactionProducts(repository),
            saveTransaction: SaveTransaction(repository),
            getCustomerHistory: GetCustomerHistory(repository),
          )..add(const LoadProdukTransaksi());
        }),
      ],
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends ConsumerWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionsControllerProvider);

    ref.listen(transactionsControllerProvider, (previous, next) {
      if (next.isSuccess && next.lastTransactionResponse != null) {
        final data = next.lastTransactionResponse!['data'];
        final String orderId = data['kode'] ?? '-';
        final String tanggalStr = data['tanggal'] ?? DateTime.now().toString();
        final DateTime tanggal =
            DateTime.tryParse(tanggalStr) ?? DateTime.now();

        final details = data['detail_transaksi'] as List? ?? [];
        final purchasedItems = details.map((d) {
          return _PurchasedItemData(
            name: d['produk']?['nama'] ?? '-',
            qty: d['jumlah'] ?? 0,
            lineTotal: double.tryParse(d['subtotal'].toString())?.toInt() ?? 0,
          );
        }).toList();

        final int subtotalVal =
            double.tryParse(data['total_harga'].toString())?.toInt() ?? 0;
        final double? adminFeeRaw = double.tryParse(
          data['biaya_admin']?.toString() ?? '0',
        );
        final int biayaAdminVal = adminFeeRaw?.toInt() ?? 0;
        final int totalVal = subtotalVal + biayaAdminVal;
        final String metodeVal = data['metode_pembayaran'] ?? '-';

        final int? uCustomer = next.lastUangCustomer;
        int? kbalian;
        if (uCustomer != null && uCustomer > 0) {
          kbalian = (uCustomer - totalVal).clamp(0, 1 << 30);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _OrderSuccessScreen(
              orderId: orderId,
              tanggalJam: _formatTanggalJamIndonesia(tanggal),
              subtotal: subtotalVal,
              total: totalVal,
              biayaAdmin: biayaAdminVal,
              jumlahItem: purchasedItems.fold(0, (sum, item) => sum + item.qty),
              metodePembayaran: metodeVal,
              namaPembeli: data['nama_pelanggan'] ?? '-',
              uangCustomer: uCustomer,
              kembalian: kbalian,
              purchasedItems: purchasedItems,
              appSettings: state.appSettings,
            ),
          ),
        ).then((_) {
          ref
              .read(transactionsControllerProvider.notifier)
              .add(const ResetTransactionStatus());
          ref
              .read(transactionsControllerProvider.notifier)
              .add(const LoadProdukTransaksi());
        });
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        ref
            .read(transactionsControllerProvider.notifier)
            .add(const ResetTransactionStatus());
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const TransactionsSkeleton();
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 44,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.errorMessage!,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(transactionsControllerProvider.notifier)
                          .add(const LoadProdukTransaksi()),
                      child: const Text('Muat Ulang'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _KasirMainScreen(state: state);
        },
      ),
    );
  }
}

class _KasirMainScreen extends ConsumerStatefulWidget {
  final TransactionsState state;

  const _KasirMainScreen({required this.state});

  @override
  ConsumerState<_KasirMainScreen> createState() => _KasirMainScreenState();
}

class _KasirMainScreenState extends ConsumerState<_KasirMainScreen> {
  bool _isGridView = false;

  Future<void> _showQuantityInputDialog({
    required TransactionProduct product,
    required int currentQty,
  }) async {
    final result = await showDialog<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (_) => _QuantityInputDialog(
        product: product,
        initialQty: currentQty > 0 ? currentQty : 1,
      ),
    );

    if (!mounted || result == null) return;

    final qty = result < 0 ? 0 : result;
    ref
        .read(transactionsControllerProvider.notifier)
        .add(SetQtyProdukKeranjang(productId: product.id, qty: qty));
  }

  void _handleBottomNavTap(int index) {
    if (index == 2) return;

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
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HistoryPage()),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const IncomingGoodsPage()),
      );
    }
  }

  void _handleBackNavigation() {
    if (!mounted) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 800;
    final kategoriList = _kategori(state.allProducts);
    final totalItem = _totalItem(state);
    final totalHarga = _totalHarga(state);
    final hasCartItems = state.cartItems.isNotEmpty;
    final displayedProducts = state.visibleProducts;

    if (isTablet) {
      return _TabletTransactionLayout(state: state);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLowest,
        bottomNavigationBar: MitraPOSBottomNavBar(
          currentIndex: 2,
          onTap: _handleBottomNavTap,
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                    child: _KasirHeader(
                      hasCartItems: hasCartItems,
                      onResetCart: () => ref
                          .read(transactionsControllerProvider.notifier)
                          .add(const ResetKeranjang()),
                      isGridView: _isGridView,
                      onListViewTap: () => setState(() => _isGridView = false),
                      onGridViewTap: () => setState(() => _isGridView = true),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _SearchKasir(
                      onChanged: (value) => ref
                          .read(transactionsControllerProvider.notifier)
                          .add(CariProdukTransaksi(value)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final label = kategoriList[index];
                          final isSelected = label == state.selectedKategori;
                          return PeriodFilterChip(
                            label: label,
                            isSelected: isSelected,
                            onTap: () => ref
                                .read(transactionsControllerProvider.notifier)
                                .add(FilterKategoriTransaksi(label)),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 6),
                        itemCount: kategoriList.length,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0.0, 0.04),
                          end: Offset.zero,
                        ).animate(animation);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<String>(
                          '${state.selectedKategori}-${state.searchKeyword}-${_isGridView ? 'grid' : 'list'}-${displayedProducts.length}',
                        ),
                        child: displayedProducts.isEmpty
                            ? Center(
                                child: Text(
                                  'Produk tidak ditemukan',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              )
                            : _isGridView
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  const horizontalPadding = 14.0;
                                  const spacing = 12.0;
                                  final availableWidth =
                                      constraints.maxWidth -
                                      (horizontalPadding * 2);

                                  final crossAxisCount = availableWidth >= 980
                                      ? 5
                                      : availableWidth >= 560
                                      ? 3
                                      : 2;
                                  final aspectRatio = 0.82;

                                  return GridView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      horizontalPadding,
                                      0,
                                      horizontalPadding,
                                      104,
                                    ),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: spacing,
                                          mainAxisSpacing: spacing,
                                          childAspectRatio: aspectRatio,
                                        ),
                                    itemCount: displayedProducts.length,
                                    itemBuilder: (context, index) {
                                      final p = displayedProducts[index];
                                      return _KasirProductGridCard(
                                        product: p,
                                        qty: state.cartItems[p.id] ?? 0,
                                        highlighted: state.cartItems
                                            .containsKey(p.id),
                                        onTambah: () => ref
                                            .read(
                                              transactionsControllerProvider
                                                  .notifier,
                                            )
                                            .add(TambahProdukKeranjang(p)),
                                        onTapProduct: () =>
                                            _showQuantityInputDialog(
                                              product: p,
                                              currentQty:
                                                  state.cartItems[p.id] ?? 0,
                                            ),
                                      );
                                    },
                                  );
                                },
                              )
                            : ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  0,
                                  14,
                                  104,
                                ),
                                children: displayedProducts
                                    .map(
                                      (p) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: _KasirProductTile(
                                          product: p,
                                          qty: state.cartItems[p.id] ?? 0,
                                          highlighted: state.cartItems
                                              .containsKey(p.id),
                                          onTambah: () => ref
                                              .read(
                                                transactionsControllerProvider
                                                    .notifier,
                                              )
                                              .add(TambahProdukKeranjang(p)),
                                          onKurang: () => ref
                                              .read(
                                                transactionsControllerProvider
                                                    .notifier,
                                              )
                                              .add(KurangProdukKeranjang(p.id)),
                                          onTapProduct: () =>
                                              _showQuantityInputDialog(
                                                product: p,
                                                currentQty:
                                                    state.cartItems[p.id] ?? 0,
                                              ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasCartItems)
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: _ProceedButton(
                  disabled: false,
                  totalItem: totalItem,
                  totalHarga: totalHarga,
                  onTap: () {
                    final container = ProviderScope.containerOf(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UncontrolledProviderScope(
                          container: container,
                          child: const _OrderSummaryScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _kategori(List<TransactionProduct> products) {
    final set = <String>{'Semua'};
    for (final item in products) {
      set.add(item.kategori);
    }
    return set.toList();
  }

  int _totalItem(TransactionsState state) {
    return state.cartItems.values.fold(0, (sum, qty) => sum + qty);
  }

  int _totalHarga(TransactionsState state) {
    final map = {for (final item in state.allProducts) item.id: item};
    var total = 0;
    for (final entry in state.cartItems.entries) {
      final p = map[entry.key];
      if (p == null) continue;
      total += p.harga * entry.value;
    }
    return total;
  }
}

class _TabletTransactionLayout extends ConsumerStatefulWidget {
  final TransactionsState state;
  const _TabletTransactionLayout({required this.state});

  @override
  ConsumerState<_TabletTransactionLayout> createState() => _TabletTransactionLayoutState();
}

class _TabletTransactionLayoutState extends ConsumerState<_TabletTransactionLayout> {
  bool _isGridView = true;
  String? _metodePembayaran;
  bool _applyAdminFee = true;
  String? _selectedBank;
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int _parseNominal(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.tryParse(digits) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = ref.read(transactionsControllerProvider.notifier);
    final kategoriList = _kategoriList(state.allProducts);
    final displayedProducts = state.visibleProducts;
    final cartEntries = state.cartItems.entries.toList();
    final productMap = {for (final p in state.allProducts) p.id: p};

    var subtotal = 0;
    var jumlah = 0;
    for (final entry in cartEntries) {
      final p = productMap[entry.key];
      if (p == null) continue;
      subtotal += p.harga * entry.value;
      jumlah += entry.value;
    }

    final total = _metodePembayaran == 'Internal' ? 0 : subtotal;
    final isTunai = _metodePembayaran == 'Tunai';
    final isInternal = _metodePembayaran == 'Internal';

    int finalAdminFee = 0;
    if (_metodePembayaran == 'QRIS' && _applyAdminFee) {
      final dynamic rawAdminFee = state.appSettings?['biaya_admin_qris'];
      finalAdminFee = double.tryParse(rawAdminFee?.toString() ?? '0')?.toInt() ?? 0;
    }

    final uangCustomer = _parseNominal(_cashController.text);
    final kembalian = (uangCustomer - total - finalAdminFee).clamp(0, 1 << 30);
    final isTunaiKurang = isTunai && uangCustomer < (total + finalAdminFee);
    final metodeBelumDipilih = _metodePembayaran == null;
    final isInternalTanpaCatatan = isInternal && _noteController.text.trim().isEmpty;
    final List bankList = state.appSettings?['rekening_bank'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: Row(
          children: [
            MitraPOSSidebar(
              currentIndex: 2,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
                } else if (index == 1) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsPage()));
                } else if (index == 3) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
                } else if (index == 4) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const IncomingGoodsPage()));
                }
              },
            ),
            Expanded(
              flex: 6,
              child: _buildProductPanel(state, controller, kategoriList, displayedProducts),
            ),
            Container(width: 1, color: AppColors.borderLight),
            Expanded(
              flex: 4,
              child: _buildCartPanel(state, controller, cartEntries, productMap, subtotal, jumlah, total, finalAdminFee, uangCustomer, kembalian, isTunaiKurang, metodeBelumDipilih, isInternalTanpaCatatan, bankList, isTunai, isInternal, finalAdminFee, total),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _kategoriList(List<TransactionProduct> products) {
    final set = <String>{'Semua'};
    for (final item in products) {
      set.add(item.kategori);
    }
    return set.toList();
  }

  Widget _buildProductPanel(TransactionsState state, TransactionsController controller, List<String> kategoriList, List<TransactionProduct> displayedProducts) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Text('Produk', style: AppTypePairing.titleMd(color: _posBlueDark, weight: FontWeight.w800)),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.indigoSurfaceTint.withValues(alpha: 0.14)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewToggleButton(icon: Icons.view_list_rounded, selected: !_isGridView, onTap: () => setState(() => _isGridView = false)),
                    _ViewToggleButton(icon: Icons.grid_view_rounded, selected: _isGridView, onTap: () => setState(() => _isGridView = true)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SearchKasir(onChanged: (value) => controller.add(CariProdukTransaksi(value))),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              final label = kategoriList[index];
              final isSelected = label == state.selectedKategori;
              return PeriodFilterChip(label: label, isSelected: isSelected, onTap: () => controller.add(FilterKategoriTransaksi(label)));
            },
            separatorBuilder: (context, index) => const SizedBox(width: 6),
            itemCount: kategoriList.length,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: displayedProducts.isEmpty
              ? Center(child: Text('Produk tidak ditemukan', style: AppTextStyles.bodyMedium))
              : _isGridView
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        const hp = 20.0;
                        const sp = 12.0;
                        final aw = constraints.maxWidth - (hp * 2);
                        final cac = aw >= 600 ? 4 : aw >= 440 ? 3 : 2;
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(hp, 0, hp, 20),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cac, crossAxisSpacing: sp, mainAxisSpacing: sp, childAspectRatio: 0.82),
                          itemCount: displayedProducts.length,
                          itemBuilder: (context, index) {
                            final p = displayedProducts[index];
                            return _KasirProductGridCard(
                              product: p, qty: state.cartItems[p.id] ?? 0, highlighted: state.cartItems.containsKey(p.id),
                              onTambah: () => controller.add(TambahProdukKeranjang(p)),
                              onTapProduct: () => _showQuantityInputDialog(product: p, currentQty: state.cartItems[p.id] ?? 0),
                            );
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: displayedProducts.length,
                      itemBuilder: (context, index) {
                        final p = displayedProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _KasirProductTile(
                            product: p,
                            qty: state.cartItems[p.id] ?? 0,
                            highlighted: state.cartItems.containsKey(p.id),
                            onTambah: () => controller.add(TambahProdukKeranjang(p)),
                            onKurang: () => controller.add(KurangProdukKeranjang(p.id)),
                            onTapProduct: () => _showQuantityInputDialog(product: p, currentQty: state.cartItems[p.id] ?? 0),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Future<void> _showQuantityInputDialog({required TransactionProduct product, required int currentQty}) async {
    final result = await showDialog<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (_) => _QuantityInputDialog(product: product, initialQty: currentQty > 0 ? currentQty : 1),
    );
    if (!mounted || result == null) return;
    final qty = result < 0 ? 0 : result;
    ref.read(transactionsControllerProvider.notifier).add(SetQtyProdukKeranjang(productId: product.id, qty: qty));
  }

  Widget _buildCartPanel(
    TransactionsState state, TransactionsController controller,
    List<MapEntry<int, int>> cartEntries, Map<int, TransactionProduct> productMap,
    int subtotal, int jumlah, int total, int finalAdminFee,
    int uangCustomer, int kembalian, bool isTunaiKurang, bool metodeBelumDipilih,
    bool isInternalTanpaCatatan, List bankList, bool isTunai, bool isInternal,
    int totalHarga, int totalValue,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Text('Ringkasan Order', style: AppTypePairing.titleMd(color: _posBlueDark, weight: FontWeight.w800)),
              const Spacer(),
              if (cartEntries.isNotEmpty)
                TextButton.icon(
                  onPressed: () => controller.add(const ResetKeranjang()),
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(foregroundColor: _posBlueDark, backgroundColor: _posBlueSoft, visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
                ),
            ],
          ),
        ),
        Expanded(
          child: cartEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.textTertiary.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text('Belum ada item', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Tap produk untuk menambahkan', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                )
              : OrderSummaryWidget(
                  title: 'Ringkasan Order',
                  items: cartEntries.map((entry) {
                    final product = productMap[entry.key];
                    if (product == null) return null;
                    return OrderSummaryItem(
                      name: product.nama,
                      quantity: entry.value,
                      unitPrice: product.harga,
                      lineTotal: product.harga * entry.value,
                      imageUrl: product.imageUrl,
                      onIncrement: () => controller.add(TambahProdukKeranjang(product)),
                      onDecrement: () => controller.add(KurangProdukKeranjang(product.id)),
                    );
                  }).whereType<OrderSummaryItem>().toList(),
                  subTotal: subtotal,
                  tax: 0,
                  discount: 0,
                  total: total + finalAdminFee,
                  adminFee: finalAdminFee,
                  itemCount: jumlah,
                ),
        ),
        if (cartEntries.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() { _metodePembayaran = 'Tunai'; _selectedBank = null; _cashController.clear(); }),
                        child: _paymentChip('Tunai', _metodePembayaran == 'Tunai'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() { _metodePembayaran = 'QRIS'; _selectedBank = null; _cashController.clear(); }),
                        child: _paymentChip('QRIS', _metodePembayaran == 'QRIS'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() { _metodePembayaran = 'Transfer'; _selectedBank = null; _cashController.clear(); }),
                        child: _paymentChip('Transfer', _metodePembayaran == 'Transfer'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() { _metodePembayaran = 'Piutang'; _selectedBank = null; _cashController.clear(); }),
                        child: _paymentChip('Piutang', _metodePembayaran == 'Piutang'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_metodePembayaran == 'QRIS' && finalAdminFee > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  SizedBox(height: 20, width: 20, child: Checkbox(value: _applyAdminFee, activeColor: _posBlueDark, onChanged: (v) => setState(() => _applyAdminFee = v ?? false))),
                  const SizedBox(width: 8),
                  Text('Biaya Admin QRIS', style: AppTextStyles.labelSmall),
                ],
              ),
            ),
          if (_metodePembayaran == 'Transfer' && bankList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: bankList.map((bank) {
                  final String bankName = bank['bank'] ?? '-';
                  final isSelected = _selectedBank == bankName;
                  return ChoiceChip(label: Text(bankName), selected: isSelected, onSelected: (s) => setState(() => _selectedBank = s ? bankName : null), selectedColor: _posBlueSoft, labelStyle: AppTextStyles.labelSmall.copyWith(color: isSelected ? _posBlueDark : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500));
                }).toList(),
              ),
            ),
          if (isTunai)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: TextField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Uang Customer',
                  hintStyle: AppTextStyles.labelLarge.copyWith(color: AppColors.textTertiary),
                  prefixText: 'Rp ',
                  prefixStyle: AppTextStyles.labelLarge.copyWith(color: _posBlueDark, fontWeight: FontWeight.w700),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.indigoSurfaceTint.withValues(alpha: 0.10))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _posBlueDark, width: 1.2)),
                ),
              ),
            ),
          if (metodeBelumDipilih)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 20),
              child: Align(alignment: Alignment.centerLeft, child: Text('Pilih metode pembayaran', style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.w700))),
            ),
          if (isInternalTanpaCatatan)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 20),
              child: Align(alignment: Alignment.centerLeft, child: Text('Wajib isi catatan untuk Internal', style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.w700))),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.indigoPrimary, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                onPressed: jumlah == 0 || metodeBelumDipilih || isTunaiKurang || isInternalTanpaCatatan || state.isSubmitting
                    ? null
                    : () {
                        String finalMethod = _metodePembayaran!;
                        if (_metodePembayaran == 'Transfer' && _selectedBank != null) finalMethod = 'Transfer $_selectedBank';
                        controller.add(SubmitTransaksi(
                          namaPelanggan: '', noHpPelanggan: null, metodePembayaran: finalMethod,
                          biayaAdmin: finalAdminFee, uangCustomer: isTunai ? _parseNominal(_cashController.text) : 0,
                          catatan: _noteController.text.trim(),
                        ));
                      },
                child: state.isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: Skeleton(width: 20, height: 20, borderRadius: 10))
                    : Text('KONFIRMASI TRANSAKSI', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _paymentChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: isSelected ? AppColors.indigoActionGradient : null,
        color: isSelected ? null : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.indigoSurfaceTint.withValues(alpha: 0.10)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.labelSmall.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTabletCartItem(TransactionProduct product, int qty, TransactionsController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.indigoSurfaceTint.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: _posBlueSoft, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Icon(Icons.inventory_2_outlined, size: 20, color: _posBlueDark)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.nama, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text('$qty x ${CurrencyFormatter.format(product.harga, symbol: 'Rp')}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => controller.add(KurangProdukKeranjang(product.id)),
                child: Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(7)),
                  child: const Icon(Icons.remove, size: 16, color: Color(0xFFEF4444)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$qty', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
              ),
              GestureDetector(
                onTap: () => controller.add(TambahProdukKeranjang(product)),
                child: Container(width: 28, height: 28, decoration: BoxDecoration(color: _posBlueDark.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(7)),
                  child: const Icon(Icons.add, size: 16, color: _posBlueDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 30,
        decoration: BoxDecoration(
          color: selected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.border : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: selected ? _posBlueDark : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _OrderSummaryScreen extends ConsumerStatefulWidget {
  const _OrderSummaryScreen();

  @override
  ConsumerState<_OrderSummaryScreen> createState() =>
      _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends ConsumerState<_OrderSummaryScreen> {
  final TextEditingController _buyerController = TextEditingController();
  final TextEditingController _waController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _metodePembayaran;
  bool _applyAdminFee = true;
  String? _selectedBank;

  @override
  void dispose() {
    _buyerController.dispose();
    _waController.dispose();
    _cashController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int _parseNominal(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.tryParse(digits) ?? 0;
  }

  void _toggleMetodePembayaran(String metode) {
    setState(() {
      _metodePembayaran = metode;
      _selectedBank = null; // Reset bank when changing method
      if (metode != 'Tunai') {
        _cashController.clear();
      }
    });
  }

  Future<void> _showAddCustomerDialog() async {
    final nameCtrl = TextEditingController(text: _buyerController.text);
    final waCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Tambah Pelanggan Baru',
            style: AppTextStyles.headingSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Pelanggan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: waCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'No WhatsApp (Cth: 0812...)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.indigoPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  _buyerController.text = nameCtrl.text.trim();
                  _waController.text = waCtrl.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 54,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ringkasan Order',
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          final productMap = {for (final p in state.allProducts) p.id: p};
          final cartEntries = state.cartItems.entries.toList();

          var subtotal = 0;
          var jumlah = 0;
          for (final item in cartEntries) {
            final p = productMap[item.key];
            if (p == null) continue;
            subtotal += p.harga * item.value;
            jumlah += item.value;
          }

          final total = _metodePembayaran == 'Internal' ? 0 : subtotal;
          final isTunai = _metodePembayaran == 'Tunai';
          final isInternal = _metodePembayaran == 'Internal';
          final metodeBelumDipilih = _metodePembayaran == null;

          int finalAdminFee = 0;
          if (_metodePembayaran == 'QRIS' && _applyAdminFee) {
            final dynamic rawAdminFee = state.appSettings?['biaya_admin_qris'];
            finalAdminFee =
                double.tryParse(rawAdminFee?.toString() ?? '0')?.toInt() ?? 0;
          }

          final uangCustomer = _parseNominal(_cashController.text);
          final kembalian = (uangCustomer - total).clamp(0, 1 << 30);
          final isTunaiKurang = isTunai && uangCustomer < total;
          final isInternalTanpaCatatan =
              isInternal && _noteController.text.trim().isEmpty;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    children: [
                      _OrderSectionTitle(title: 'CUSTOMER INFO'),
                      const SizedBox(height: 8),
                      _OrderSectionCard(
                        child: Column(
                          children: [
                            RawAutocomplete<Map<String, dynamic>>(
                              textEditingController: _buyerController,
                              focusNode: FocusNode(),
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return const Iterable<
                                        Map<String, dynamic>
                                      >.empty();
                                    }
                                    return state.customerHistory.where((
                                      Map<String, dynamic> option,
                                    ) {
                                      final name =
                                          (option['nama_pelanggan'] ?? '')
                                              .toString()
                                              .toLowerCase();
                                      return name.contains(
                                        textEditingValue.text.toLowerCase(),
                                      );
                                    });
                                  },
                              displayStringForOption:
                                  (Map<String, dynamic> option) =>
                                      option['nama_pelanggan'] ?? '',
                              onSelected: (Map<String, dynamic> selection) {
                                _waController.text =
                                    selection['no_hp_pelanggan'] ?? '';
                                setState(() {});
                              },
                              fieldViewBuilder:
                                  (
                                    context,
                                    controller,
                                    focusNode,
                                    onFieldSubmitted,
                                  ) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      onChanged: (_) => setState(() {}),
                                      decoration: InputDecoration(
                                        hintText: 'Nama Pelanggan (Opsional)',
                                        hintStyle: AppTextStyles.labelLarge
                                            .copyWith(
                                              color: AppColors.textTertiary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        suffixIcon: Icon(
                                          Icons.person,
                                          color: AppColors.textTertiary
                                              .withValues(alpha: 0.9),
                                          size: 22,
                                        ),
                                        filled: true,
                                        fillColor:
                                            AppColors.surfaceContainerLowest,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.indigoSurfaceTint
                                                .withValues(alpha: 0.10),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: _posBlueDark,
                                            width: 1.2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                              optionsViewBuilder: (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.surfaceContainerLowest,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: 250,
                                        maxWidth:
                                            MediaQuery.of(context).size.width -
                                            32,
                                      ),
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        shrinkWrap: true,
                                        itemCount: options.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index == options.length) {
                                            return ListTile(
                                              leading: const Icon(
                                                Icons.add_circle_outline,
                                                color: _posBlueDark,
                                              ),
                                              title: Text(
                                                'Tambah Pelanggan Baru...',
                                                style: AppTextStyles.bodyMedium
                                                    .copyWith(
                                                      color: _posBlueDark,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              onTap: () {
                                                // Call dialog directly without submitting the autocomplete text
                                                _showAddCustomerDialog();
                                              },
                                            );
                                          }

                                          final option = options.elementAt(
                                            index,
                                          );
                                          final name =
                                              option['nama_pelanggan'] ?? '';
                                          final noHp =
                                              option['no_hp_pelanggan'] ?? '-';
                                          return ListTile(
                                            title: Text(
                                              name,
                                              style: AppTextStyles.bodyMedium,
                                            ),
                                            subtitle: Text(
                                              noHp,
                                              style: AppTextStyles.bodySmall,
                                            ),
                                            onTap: () {
                                              onSelected(option);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Hidden WA Controller is managed by state
                            const SizedBox(height: 14),
                            TextField(
                              controller: _noteController,
                              maxLines: 2,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Catatan Transaksi (Opsional)',
                                hintStyle: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                                suffixIcon: Icon(
                                  Icons.note_alt_outlined,
                                  color: AppColors.textTertiary.withValues(
                                    alpha: 0.9,
                                  ),
                                  size: 22,
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceContainerLowest,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.indigoSurfaceTint
                                        .withValues(alpha: 0.10),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: _posBlueDark,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _OrderSectionTitle(
                        title: 'DAFTAR PRODUK',
                        trailing: '$jumlah Items',
                      ),
                      const SizedBox(height: 8),
                      _OrderSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (cartEntries.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Belum ada item di keranjang',
                                  style: AppTextStyles.bodySmall,
                                ),
                              )
                            else
                              ...cartEntries.map((entry) {
                                final product = productMap[entry.key];
                                if (product == null) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _OrderItemTile(
                                    product: product,
                                    qty: entry.value,
                                    onTambah: () => ref
                                        .read(
                                          transactionsControllerProvider
                                              .notifier,
                                        )
                                        .add(TambahProdukKeranjang(product)),
                                    onKurang: () => ref
                                        .read(
                                          transactionsControllerProvider
                                              .notifier,
                                        )
                                        .add(KurangProdukKeranjang(product.id)),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _OrderSectionTitle(title: 'METODE PEMBAYARAN'),
                      const SizedBox(height: 8),
                      _OrderSectionCard(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final List bankList =
                                state.appSettings?['rekening_bank'] ?? [];
                            final dynamic rawAdminFee =
                                state.appSettings?['biaya_admin_qris'];
                            final int adminFee =
                                double.tryParse(
                                  rawAdminFee?.toString() ?? '0',
                                )?.toInt() ??
                                0;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    SizedBox(
                                      width: (constraints.maxWidth - 8) / 2,
                                      child: _PaymentMethodChip(
                                        label: 'Tunai',
                                        icon: Icons.payments_outlined,
                                        selected: _metodePembayaran == 'Tunai',
                                        onTap: () =>
                                            _toggleMetodePembayaran('Tunai'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (constraints.maxWidth - 8) / 2,
                                      child: _PaymentMethodChip(
                                        label: 'QRIS',
                                        icon: Icons.qr_code_2_rounded,
                                        selected: _metodePembayaran == 'QRIS',
                                        onTap: () =>
                                            _toggleMetodePembayaran('QRIS'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (constraints.maxWidth - 8) / 2,
                                      child: _PaymentMethodChip(
                                        label: 'Transfer',
                                        icon: Icons.account_balance_rounded,
                                        selected:
                                            _metodePembayaran == 'Transfer',
                                        onTap: () =>
                                            _toggleMetodePembayaran('Transfer'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (constraints.maxWidth - 8) / 2,
                                      child: _PaymentMethodChip(
                                        label: 'Piutang',
                                        icon: Icons.hourglass_bottom_rounded,
                                        selected:
                                            _metodePembayaran == 'Piutang',
                                        onTap: () =>
                                            _toggleMetodePembayaran('Piutang'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (constraints.maxWidth - 8) / 2,
                                      child: _PaymentMethodChip(
                                        label: 'Internal',
                                        icon: Icons.inventory_2_outlined,
                                        selected:
                                            _metodePembayaran == 'Internal',
                                        onTap: () =>
                                            _toggleMetodePembayaran('Internal'),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_metodePembayaran == 'QRIS' &&
                                    adminFee > 0) ...[
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: _applyAdminFee,
                                          activeColor: _posBlueDark,
                                          onChanged: (v) => setState(
                                            () => _applyAdminFee = v ?? false,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Biaya Admin QRIS: ${CurrencyFormatter.format(adminFee)}',
                                        style: AppTextStyles.labelMedium,
                                      ),
                                    ],
                                  ),
                                ],
                                if (_metodePembayaran == 'Transfer' &&
                                    bankList.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Pilih Bank Tujuan:',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: bankList.map((bank) {
                                      final String bankName =
                                          bank['bank'] ?? '-';
                                      final isSelected =
                                          _selectedBank == bankName;
                                      return ChoiceChip(
                                        label: Text(bankName),
                                        selected: isSelected,
                                        onSelected: (s) => setState(
                                          () => _selectedBank = s
                                              ? bankName
                                              : null,
                                        ),
                                        selectedColor: _posBlueSoft,
                                        labelStyle: AppTextStyles.labelSmall
                                            .copyWith(
                                              color: isSelected
                                                  ? _posBlueDark
                                                  : AppColors.textPrimary,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                      if (metodeBelumDipilih)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Pilih salah satu metode pembayaran',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (isInternalTanpaCatatan)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Wajib isi catatan untuk Pemakaian Internal',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (isTunai) ...[
                        const SizedBox(height: 10),
                        _OrderSectionCard(
                          child: TextField(
                            controller: _cashController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CurrencyInputFormatter(),
                            ],
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Uang Customer',
                              hintStyle: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              prefixText: 'Rp ',
                              prefixStyle: AppTextStyles.labelLarge.copyWith(
                                color: _posBlueDark,
                                fontWeight: FontWeight.w700,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceContainerLowest,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.indigoSurfaceTint.withValues(
                                    alpha: 0.10,
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: _posBlueDark,
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _OrderPaymentSummaryPanel(
                        subtotal: subtotal,
                        total: total + (finalAdminFee),
                        biayaAdmin: finalAdminFee,
                        metodePembayaran: _metodePembayaran,
                        uangCustomer: isTunai ? uangCustomer : null,
                        kembalian: isTunai ? kembalian : null,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.indigoPrimary,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                          jumlah == 0 ||
                              metodeBelumDipilih ||
                              isTunaiKurang ||
                              isInternalTanpaCatatan ||
                              state.isSubmitting
                          ? null
                          : () {
                              String finalMethod = _metodePembayaran!;
                              if (_metodePembayaran == 'Transfer' &&
                                  _selectedBank != null) {
                                finalMethod = 'Transfer $_selectedBank';
                              }

                              ref
                                  .read(transactionsControllerProvider.notifier)
                                  .add(
                                    SubmitTransaksi(
                                      namaPelanggan: _buyerController.text
                                          .trim(),
                                      noHpPelanggan:
                                          _waController.text.trim().isEmpty
                                          ? null
                                          : _waController.text.trim(),
                                      metodePembayaran: finalMethod,
                                      biayaAdmin: finalAdminFee,
                                      uangCustomer: isTunai
                                          ? _parseNominal(_cashController.text)
                                          : 0,
                                      catatan: _noteController.text.trim(),
                                    ),
                                  );
                            },
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: Skeleton(width: 20, height: 20, borderRadius: 10),
                            )
                          : Text(
                              'KONFIRMASI TRANSAKSI',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.white : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.indigoActionGradient : null,
            color: selected ? null : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : AppColors.indigoSurfaceTint.withValues(alpha: 0.10),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, size: 19, color: fg),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: selected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KasirHeader extends StatelessWidget {
  final bool hasCartItems;
  final VoidCallback onResetCart;
  final bool isGridView;
  final VoidCallback onListViewTap;
  final VoidCallback onGridViewTap;

  const _KasirHeader({
    required this.hasCartItems,
    required this.onResetCart,
    required this.isGridView,
    required this.onListViewTap,
    required this.onGridViewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.24),
            ),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Transaksi',
            style: AppTypePairing.titleMd(
              color: _posBlueDark,
              weight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasCartItems)
              TextButton.icon(
                onPressed: onResetCart,
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: _posBlueDark,
                  backgroundColor: _posBlueSoft,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: const Size(0, 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            if (hasCartItems) const SizedBox(width: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.indigoSurfaceTint.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ViewToggleButton(
                    icon: Icons.view_list_rounded,
                    selected: !isGridView,
                    onTap: onListViewTap,
                  ),
                  _ViewToggleButton(
                    icon: Icons.grid_view_rounded,
                    selected: isGridView,
                    onTap: onGridViewTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchKasir extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchKasir({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari produk / SKU',
        hintStyle: AppTypePairing.bodySm(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.indigoSurfaceTint.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _KasirProductTile extends StatefulWidget {
  final TransactionProduct product;
  final int qty;
  final bool highlighted;
  final VoidCallback onTambah;
  final VoidCallback onKurang;
  final VoidCallback onTapProduct;

  const _KasirProductTile({
    required this.product,
    required this.qty,
    required this.highlighted,
    required this.onTambah,
    required this.onKurang,
    required this.onTapProduct,
  });

  @override
  State<_KasirProductTile> createState() => _KasirProductTileState();
}

class _KasirProductTileState extends State<_KasirProductTile> {
  void _handleQuickAdd() {
    HapticFeedback.selectionClick();
    widget.onTambah();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _handleQuickAdd,
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.highlighted
                  ? AppColors.info.withValues(alpha: 0.26)
                  : AppColors.indigoSurfaceTint.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.highlighted
                    ? AppColors.info.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: widget.highlighted ? 10 : 5,
                offset: Offset(0, widget.highlighted ? 4 : 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTapProduct,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _posBlueSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          widget.product.imageUrl != null &&
                              widget.product.imageUrl!.isNotEmpty
                          ? Image.network(
                              widget.product.imageUrl!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: Skeleton(width: 16, height: 16, borderRadius: 8),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 24,
                                      color: _posBlueDark,
                                    ),
                                  ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 24,
                                color: _posBlueDark,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SKU: ${widget.product.sku}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _posBlueSoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            CurrencyFormatter.format(
                              widget.product.harga,
                              symbol: 'Rp',
                            ),
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _posBlueDark,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Stok: ${widget.product.stok}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: widget.product.stok < 10
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 84,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerRight,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.qty > 0) ...[
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: widget.onKurang,
                                child: const Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _posBlueDark,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: _posBlueDark.withValues(alpha: 0.22),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _handleQuickAdd,
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.qty > 0)
                      Positioned(
                        right: -4,
                        top: -6,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 19),
                          height: 19,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.indigoPrimary),
                          ),
                          child: Text(
                            '${widget.qty}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.indigoPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KasirProductGridCard extends StatelessWidget {
  final TransactionProduct product;
  final int qty;
  final bool highlighted;
  final VoidCallback onTambah;
  final VoidCallback onTapProduct;

  const _KasirProductGridCard({
    required this.product,
    required this.qty,
    required this.highlighted,
    required this.onTambah,
    required this.onTapProduct,
  });

  @override
  Widget build(BuildContext context) {
    final hasQty = qty > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          onTambah();
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlighted
                  ? AppColors.indigoPrimary.withValues(alpha: 0.24)
                  : AppColors.indigoSurfaceTint.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: highlighted
                    ? AppColors.primary.withValues(alpha: 0.09)
                    : AppColors.shadowLight,
                blurRadius: highlighted ? 16 : 11,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, cardConstraints) {
              final imageHeight = (cardConstraints.maxWidth * 0.62).clamp(
                94.0,
                128.0,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Stack(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: onTapProduct,
                            child: SizedBox(
                              height: imageHeight,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    product.imageUrl != null &&
                                        product.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Container(
                                                color: AppColors
                                                    .surfaceContainerLow,
                                                child: const Center(
                                                  child:
                                                      Skeleton(
                                                        width: 16,
                                                        height: 16,
                                                        borderRadius: 8,
                                                      ),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Container(
                                              color:
                                                  AppColors.surfaceContainerLow,
                                              child: const Center(
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  size: 28,
                                                  color: AppColors.textTertiary,
                                                ),
                                              ),
                                            ),
                                      )
                                    : Container(
                                        color: AppColors.surfaceContainerLow,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 28,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed.withValues(
                                alpha: 0.92,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'SKU ${product.sku}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.indigoPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                        if (hasQty)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.indigoPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.indigoPrimary.withValues(
                                      alpha: 0.24,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                qty > 99 ? '99+' : '$qty',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                product.nama,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  height: 1.05,
                                  fontFamily:
                                      GoogleFonts.plusJakartaSans().fontFamily,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Stok: ${product.stok}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: product.stok < 10
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  CurrencyFormatter.format(
                                    product.harga,
                                    symbol: 'Rp',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.headingMedium.copyWith(
                                    color: _posBlueDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    height: 1.05,
                                    fontFamily: GoogleFonts.plusJakartaSans()
                                        .fontFamily,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: onTambah,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryFixed,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.shopping_cart_checkout_rounded,
                                      size: 19,
                                      color: hasQty
                                          ? AppColors.indigoPrimary
                                          : AppColors.indigoSurfaceTint,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.size = 24,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: onTap == null ? AppColors.textTertiary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _QuantityInputDialog extends StatefulWidget {
  final TransactionProduct product;
  final int initialQty;

  const _QuantityInputDialog({required this.product, required this.initialQty});

  @override
  State<_QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<_QuantityInputDialog> {
  late final TextEditingController _controller;
  late int _draftQty;

  @override
  void initState() {
    super.initState();
    _draftQty = widget.initialQty;
    _controller = TextEditingController(text: _draftQty.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQty(int value) {
    int safe = value < 0 ? 0 : value;
    if (safe > widget.product.stok) {
      safe = widget.product.stok;
    }
    setState(() {
      _draftQty = safe;
      _controller.text = safe.toString();
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.indigoPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shopping_basket_outlined,
                    size: 17,
                    color: AppColors.indigoPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Atur Quantity',
                    style: AppTypePairing.titleMd(weight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.product.nama,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypePairing.bodySm(
                color: AppColors.textPrimary,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.format(widget.product.harga, symbol: 'Rp '),
                  style: AppTypePairing.bodySm(
                    color: AppColors.indigoPrimary,
                    weight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Stok: ${widget.product.stok}',
                  style: AppTypePairing.bodySm(
                    color: widget.product.stok < 10
                        ? AppColors.error
                        : AppColors.textSecondary,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _QtyButton(
                  icon: Icons.remove,
                  size: 36,
                  iconSize: 18,
                  onTap: _draftQty > 0 ? () => _setQty(_draftQty - 1) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    autofocus: true,
                    onChanged: (value) {
                      final parsed = int.tryParse(value.trim());
                      if (parsed == null) return;
                      setState(() => _draftQty = parsed);
                    },
                    style: AppTypePairing.titleMd(weight: FontWeight.w800),
                    decoration: InputDecoration(
                      hintText: '0',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.indigoSurfaceTint.withValues(
                            alpha: 0.14,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.indigoPrimary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _QtyButton(
                  icon: Icons.add,
                  size: 36,
                  iconSize: 18,
                  onTap: () => _setQty(_draftQty + 1),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [1, 5, 10, 20].map((preset) {
                final selected = _draftQty == preset;
                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => _setQty(preset),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.indigoPrimary.withValues(alpha: 0.12)
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$preset',
                      style: AppTypePairing.bodySm(
                        color: selected
                            ? AppColors.indigoPrimary
                            : AppColors.textSecondary,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      side: BorderSide(
                        color: AppColors.indigoSurfaceTint.withValues(
                          alpha: 0.24,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: AppTypePairing.bodySm(weight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _draftQty),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _draftQty == 0 ? 'Hapus' : 'Simpan',
                      style: AppTypePairing.bodySm(
                        color: AppColors.white,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProceedButton extends StatelessWidget {
  final bool disabled;
  final int totalItem;
  final int totalHarga;
  final VoidCallback onTap;

  const _ProceedButton({
    required this.disabled,
    required this.totalItem,
    required this.totalHarga,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: disabled ? null : onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: AppColors.indigoActionGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.26),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$totalItem item | ${CurrencyFormatter.format(totalHarga, symbol: 'Rp ')}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'Lanjut',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final TransactionProduct product;
  final int qty;
  final VoidCallback onTambah;
  final VoidCallback onKurang;

  const _OrderItemTile({
    required this.product,
    required this.qty,
    required this.onTambah,
    required this.onKurang,
  });

  @override
  Widget build(BuildContext context) {
    final lineTotal = product.harga * qty;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.indigoSurfaceTint.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(product.harga, symbol: 'Rp '),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total: ${CurrencyFormatter.format(lineTotal, symbol: 'Rp ')}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _QtyButton(
                  icon: Icons.remove,
                  size: 24,
                  iconSize: 15,
                  onTap: onKurang,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$qty',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _QtyButton(
                  icon: Icons.add,
                  size: 24,
                  iconSize: 15,
                  onTap: onTambah,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.bodySmall;
    final labelStyle = baseStyle.copyWith(color: baseStyle.color);
    final valueStyle = baseStyle.copyWith(color: valueColor ?? baseStyle.color);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _OrderPaymentSummaryPanel extends StatelessWidget {
  final int subtotal;
  final int total;
  final int biayaAdmin;
  final String? metodePembayaran;
  final int? uangCustomer;
  final int? kembalian;

  const _OrderPaymentSummaryPanel({
    required this.subtotal,
    required this.total,
    required this.biayaAdmin,
    this.metodePembayaran,
    this.uangCustomer,
    this.kembalian,
  });

  @override
  Widget build(BuildContext context) {
    final hasCashData = uangCustomer != null && kembalian != null;
    final hasMetode = metodePembayaran != null && metodePembayaran!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.indigoSurfaceTint.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 7,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pembayaran',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _OrderSummaryLine(
            label: 'Subtotal',
            value: CurrencyFormatter.format(subtotal, symbol: 'Rp '),
          ),
          if (biayaAdmin > 0) ...[
            const SizedBox(height: 8),
            _OrderSummaryLine(
              label: 'Biaya Admin',
              value: CurrencyFormatter.format(biayaAdmin, symbol: 'Rp '),
              valueColor: _posBlueDark,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metode',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              hasMetode
                  ? _OrderMethodPill(label: metodePembayaran!.toUpperCase())
                  : Text(
                      '-',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ],
          ),
          if (hasCashData) ...[
            const SizedBox(height: 8),
            _OrderSummaryLine(
              label: 'Uang Customer',
              value: CurrencyFormatter.format(uangCustomer!, symbol: 'Rp '),
            ),
            const SizedBox(height: 8),
            _OrderSummaryLine(
              label: 'Kembalian',
              value: CurrencyFormatter.format(kembalian!, symbol: 'Rp '),
              valueColor: AppColors.success,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 7),
            child: Divider(height: 1, color: Color(0xFFE7EAF0)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Bayar',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                CurrencyFormatter.format(total, symbol: 'Rp '),
                style: AppTextStyles.headingSmall.copyWith(
                  color: _posBlueDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderMethodPill extends StatelessWidget {
  final String label;

  const _OrderMethodPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: _posBlueDark,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OrderSummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _OrderSummaryLine({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _OrderSectionCard extends StatelessWidget {
  final Widget child;

  const _OrderSectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.indigoSurfaceTint.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OrderSectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const _OrderSectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Text(
            trailing!,
            style: AppTextStyles.labelMedium.copyWith(
              color: _posBlueDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  final String tanggalJam;
  final int subtotal;
  final int total;
  final int biayaAdmin;
  final int jumlahItem;
  final String? metodePembayaran;
  final String namaPembeli;
  final int? uangCustomer;
  final int? kembalian;
  final List<_PurchasedItemData> purchasedItems;
  final Map<String, dynamic>? appSettings;

  const _OrderSuccessScreen({
    required this.orderId,
    required this.tanggalJam,
    required this.subtotal,
    required this.total,
    required this.biayaAdmin,
    required this.jumlahItem,
    this.metodePembayaran,
    required this.namaPembeli,
    this.uangCustomer,
    this.kembalian,
    required this.purchasedItems,
    this.appSettings,
  });

  @override
  State<_OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

enum _ReceiptVisualStyle { modern, thermal }

class _OrderSuccessScreenState extends State<_OrderSuccessScreen> {
  _ReceiptVisualStyle _receiptStyle = _ReceiptVisualStyle.thermal;

  Widget _buildReceiptCard() {
    if (_receiptStyle == _ReceiptVisualStyle.thermal) {
      return _ReceiptPaper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            // Header Section
            Center(
              child: Column(
                children: [
                  Text(
                    (widget.appSettings?['nama_toko'] ?? 'MITRA POS')
                        .toString()
                        .toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: _posBlueDark,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (widget.appSettings?['deskripsi']?['slogan'] != null)
                    Text(
                      (widget.appSettings?['deskripsi']?['slogan'] ?? '')
                          .toString()
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (widget.appSettings?['deskripsi']?['keterangan'] != null)
                    Text(
                      (widget.appSettings?['deskripsi']?['keterangan'] ?? '')
                          .toString()
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (widget.appSettings?['alamat_toko'] != null) ...[
                    Text(
                      '${widget.appSettings?['alamat_toko']?['jalan'] ?? ''}'
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${widget.appSettings?['alamat_toko']?['kota'] ?? ''}'
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${widget.appSettings?['alamat_toko']?['provinsi'] ?? ''}'
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  if (widget.appSettings?['no_hp'] != null)
                    Text(
                      '${widget.appSettings?['no_hp']}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _ReceiptDashedDivider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.orderId,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Text(
              widget.tanggalJam,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            const _ReceiptDashedDivider(),
            const SizedBox(height: 8),
            if (widget.purchasedItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'TIDAK ADA ITEM',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            else
              ...widget.purchasedItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.toUpperCase(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.qty} x ${CurrencyFormatter.format(item.lineTotal ~/ item.qty, symbol: '')}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(
                              item.lineTotal,
                              symbol: '',
                            ),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 4),
            const _ReceiptDashedDivider(),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Jumlah Item',
              value: widget.jumlahItem.toString(),
            ),
            _SummaryRow(
              label: 'Subtotal',
              value: CurrencyFormatter.format(widget.subtotal, symbol: ''),
            ),
            _SummaryRow(
              label: 'Metode',
              value: widget.metodePembayaran?.toUpperCase() ?? '-',
            ),
            if (widget.biayaAdmin > 0)
              _SummaryRow(
                label: 'Biaya Admin',
                value: CurrencyFormatter.format(widget.biayaAdmin, symbol: ''),
              ),
            if (widget.uangCustomer != null && widget.kembalian != null) ...[
              _SummaryRow(
                label: 'Tunai',
                value: CurrencyFormatter.format(
                  widget.uangCustomer!,
                  symbol: '',
                ),
              ),
              _SummaryRow(
                label: 'Kembali',
                value: CurrencyFormatter.format(widget.kembalian!, symbol: ''),
              ),
            ],
            const SizedBox(height: 8),
            const _ReceiptDashedDivider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GRAND TOTAL',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(widget.total, symbol: 'Rp '),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                (widget.appSettings?['footer_nota'] ?? 'TERIMAKASIH')
                    .toString()
                    .toUpperCase()
                    .replaceAll(' ', ''),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _ModernReceiptCard(
      orderId: widget.orderId,
      tanggalJam: widget.tanggalJam,
      subtotal: widget.subtotal,
      total: widget.total,
      biayaAdmin: widget.biayaAdmin,
      jumlahItem: widget.jumlahItem,
      metodePembayaran: widget.metodePembayaran,
      namaPembeli: widget.namaPembeli,
      uangCustomer: widget.uangCustomer,
      kembalian: widget.kembalian,
      purchasedItems: widget.purchasedItems,
      appSettings: widget.appSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEEF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDEEF1),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MitraPOS',
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: _posBlueDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    children: [
                      const SizedBox(height: 6),
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed.withValues(
                              alpha: 0.35,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: _posBlueDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Transaksi Berhasil',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ReceiptStyleChip(
                                label: 'Modern',
                                selected:
                                    _receiptStyle == _ReceiptVisualStyle.modern,
                                onTap: () {
                                  setState(() {
                                    _receiptStyle = _ReceiptVisualStyle.modern;
                                  });
                                },
                              ),
                              const SizedBox(width: 6),
                              _ReceiptStyleChip(
                                label: 'Thermal',
                                selected:
                                    _receiptStyle ==
                                    _ReceiptVisualStyle.thermal,
                                onTap: () {
                                  setState(() {
                                    _receiptStyle = _ReceiptVisualStyle.thermal;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildReceiptCard(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final address = widget.appSettings?['alamat_toko'];
                        final addressStr = address != null
                            ? '${address['jalan'] ?? ''}, ${address['kota'] ?? ''}'
                            : null;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Menyiapkan data cetak...'),
                            duration: Duration(milliseconds: 500),
                          ),
                        );

                        final success =
                            await ThermalPrinterService.printReceipt(
                              storeName:
                                  widget.appSettings?['nama_toko'] ??
                                  'MITRA POS',
                              address: addressStr,
                              slogan:
                                  widget.appSettings?['deskripsi']?['slogan'],
                              orderId: widget.orderId,
                              tanggalJam: widget.tanggalJam,
                              items: widget.purchasedItems,
                              subtotal: widget.subtotal,
                              biayaAdmin: widget.biayaAdmin,
                              total: widget.total,
                              metodePembayaran: widget.metodePembayaran ?? '-',
                              footer: widget.appSettings?['footer_nota'],
                              uangCustomer: widget.uangCustomer,
                              kembalian: widget.kembalian,
                              appSettings: widget.appSettings,
                            );

                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Struk berhasil dicetak!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Gagal mencetak struk. Pastikan printer terhubung di menu Pengaturan Printer.',
                                ),
                                backgroundColor: AppColors.error,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.print_outlined),
                      label: const Text('Cetak Struk'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _posBlueDark,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomePage(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.home_outlined, size: 18),
                          label: const Text('Ke Home'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            backgroundColor: AppColors.white,
                            side: BorderSide(
                              color: AppColors.indigoSurfaceTint.withValues(
                                alpha: 0.22,
                              ),
                            ),
                            foregroundColor: _posBlueDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text('Penjualan Baru'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            backgroundColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                            side: BorderSide(
                              color: AppColors.indigoSurfaceTint.withValues(
                                alpha: 0.22,
                              ),
                            ),
                            foregroundColor: _posBlueDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptStyleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ReceiptStyleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _posBlueDark : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ModernReceiptCard extends StatelessWidget {
  final String orderId;
  final String tanggalJam;
  final int subtotal;
  final int total;
  final int biayaAdmin;
  final int jumlahItem;
  final String? metodePembayaran;
  final String namaPembeli;
  final int? uangCustomer;
  final int? kembalian;
  final List<_PurchasedItemData> purchasedItems;
  final Map<String, dynamic>? appSettings;

  const _ModernReceiptCard({
    required this.orderId,
    required this.tanggalJam,
    required this.subtotal,
    required this.total,
    required this.biayaAdmin,
    required this.jumlahItem,
    this.metodePembayaran,
    required this.namaPembeli,
    this.uangCustomer,
    this.kembalian,
    required this.purchasedItems,
    this.appSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (appSettings?['nama_toko'] ?? 'MITRA POS')
                          .toString()
                          .toUpperCase(),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _posBlueDark,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (appSettings?['deskripsi']?['slogan'] != null)
                      Text(
                        (appSettings?['deskripsi']?['slogan'] ?? '')
                            .toString()
                            .toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    if (appSettings?['deskripsi']?['keterangan'] != null)
                      Text(
                        (appSettings?['deskripsi']?['keterangan'] ?? '')
                            .toString()
                            .toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 8,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    if (appSettings?['alamat_toko'] != null) ...[
                      Text(
                        '${appSettings?['alamat_toko']?['jalan'] ?? ''}'
                            .toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 8,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '${appSettings?['alamat_toko']?['kota'] ?? ''}, ${appSettings?['alamat_toko']?['provinsi'] ?? ''}'
                            .toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 8,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    if (appSettings?['no_hp'] != null)
                      Text(
                        'TELP: ${appSettings?['no_hp']}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 8,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _OrderMethodPill(label: metodePembayaran?.toUpperCase() ?? '-'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.border),
          ),
          Row(
            children: [
              Expanded(
                child: _ReceiptMetaTile(label: 'ID TRANSAKSI', value: orderId),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReceiptMetaTile(
                  label: 'TANGGAL & JAM',
                  value: tanggalJam,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.border),
          ),
          if (purchasedItems.isEmpty)
            _OrderDetailItemRow(
              title: namaPembeli.isNotEmpty ? namaPembeli : 'Produk MitraPOS',
              subtitle: metodePembayaran != null && metodePembayaran!.isNotEmpty
                  ? 'Metode: $metodePembayaran'
                  : '$jumlahItem item',
              amount: CurrencyFormatter.format(subtotal, symbol: 'Rp '),
            )
          else
            ...purchasedItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OrderDetailItemRow(
                  title: item.name,
                  subtitle: 'Qty ${item.qty}',
                  amount: CurrencyFormatter.format(
                    item.lineTotal,
                    symbol: 'Rp ',
                  ),
                ),
              );
            }),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _SummaryRow(label: 'Jumlah Item', value: jumlahItem.toString()),
                _SummaryRow(
                  label: 'Subtotal',
                  value: CurrencyFormatter.format(subtotal, symbol: ''),
                ),
                _SummaryRow(
                  label: 'Metode',
                  value: metodePembayaran?.toUpperCase() ?? '-',
                ),
                if (biayaAdmin > 0) ...[
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Biaya Admin',
                    value: CurrencyFormatter.format(biayaAdmin, symbol: ''),
                  ),
                ],
                if (uangCustomer != null && kembalian != null) ...[
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Tunai',
                    value: CurrencyFormatter.format(uangCustomer!, symbol: ''),
                  ),
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Kembali',
                    value: CurrencyFormatter.format(kembalian!, symbol: ''),
                    valueColor: AppColors.success,
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GRAND TOTAL',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _posBlueDark,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(total, symbol: 'Rp '),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _posBlueDark,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              (appSettings?['footer_nota'] ?? 'TERIMAKASIH')
                  .toString()
                  .toUpperCase()
                  .replaceAll(' ', ''),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchasedItemData {
  final String name;
  final int qty;
  final int lineTotal;

  const _PurchasedItemData({
    required this.name,
    required this.qty,
    required this.lineTotal,
  });
}

class _ReceiptMetaTile extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _ReceiptMetaTile({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: AppTextStyles.labelLarge.copyWith(
            color: _posBlueDark,
            fontWeight: FontWeight.w400,
            height: 1.15,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _ReceiptPaper extends StatelessWidget {
  final Widget child;

  const _ReceiptPaper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
        const Positioned(left: -7, top: 34, child: _ReceiptNotch()),
        const Positioned(right: -7, top: 34, child: _ReceiptNotch()),
        const Positioned(left: -7, bottom: 34, child: _ReceiptNotch()),
        const Positioned(right: -7, bottom: 34, child: _ReceiptNotch()),
      ],
    );
  }
}

class _ReceiptNotch extends StatelessWidget {
  const _ReceiptNotch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: Color(0xFFEDEEF1),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ReceiptDashedDivider extends StatelessWidget {
  const _ReceiptDashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 7).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
              width: 4,
              height: 1.2,
              color: AppColors.textSecondary.withValues(alpha: 0.35),
            ),
          ),
        );
      },
    );
  }
}

class _OrderDetailItemRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;

  const _OrderDetailItemRow({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w400,
                  height: 1.15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          amount,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
