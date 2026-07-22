import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';
import 'package:mitrapos/core/widgets/indigo_filter_chip.dart';
import 'package:mitrapos/core/widgets/mitrapos_bottom_nav_bar.dart';
import 'package:mitrapos/core/widgets/mitrapos_sidebar.dart';
import 'package:mitrapos/core/widgets/skeleton.dart';
import 'package:mitrapos/domain/products/entities/product.dart';
import 'package:mitrapos/presentation/home/pages/home_page.dart';
import 'package:mitrapos/presentation/products/controller/product_controller.dart';
import 'package:mitrapos/presentation/history/pages/history_page.dart';
import 'package:mitrapos/presentation/incoming_goods/pages/incoming_goods_page.dart';
import 'package:mitrapos/presentation/transactions/pages/transactions_page.dart';
import 'package:mitrapos/presentation/products/pages/product_detail_page.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productControllerProvider.notifier).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productControllerProvider);
    final isTablet = MediaQuery.of(context).size.width >= 800;

    void handleNav(int index) {
      if (index == 0) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else if (index == 2) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TransactionsPage()));
      } else if (index == 3) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
      } else if (index == 4) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const IncomingGoodsPage()));
      }
    }

    Widget body() {
      if (state.isLoading && state.products.isEmpty) {
        return const ProductsSkeleton();
      }
      if (state.errorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 46, color: AppColors.error),
                const SizedBox(height: 12),
                Text(state.errorMessage!, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.read(productControllerProvider.notifier).fetchProducts(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => ref.read(productControllerProvider.notifier).updateSearch(value),
                    decoration: InputDecoration(
                      hintText: 'Cari nama produk atau SKU',
                      hintStyle: AppTypePairing.bodySm(),
                      prefixIcon: const Icon(Icons.search_rounded, size: 19),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.indigoSurfaceTint.withValues(alpha: 0.14)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.indigoPrimary.withValues(alpha: 0.45)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _FilterButton(state: state),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(productControllerProvider.notifier).fetchProducts(),
              child: state.products.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(height: 400, child: _EmptyProductsState()),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.products.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      padding: const EdgeInsets.fromLTRB(16, 1, 16, 12),
                      itemBuilder: (context, index) {
                        final item = state.products[index];
                        return InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(product: item))),
                          child: _ListingTile(item: item),
                        );
                      },
                    ),
            ),
          ),
        ],
      );
    }

    if (isTablet) {
      return Scaffold(
        backgroundColor: AppColors.surfaceContainerLowest,
        body: SafeArea(
          child: Row(
            children: [
              MitraPOSSidebar(currentIndex: 1, onTap: handleNav),
              Expanded(child: body()),
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
          'Produk',
          style: AppTypePairing.titleMd(
            color: const Color(0xFF000B60),
            weight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: Navigator.canPop(context)
          ? null
          : MitraPOSBottomNavBar(
              currentIndex: 1,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionsPage(),
                    ),
                  );
                } else if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  );
                } else if (index == 4) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncomingGoodsPage(),
                    ),
                  );
                }
              },
            ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.products.isEmpty) {
            return const ProductsSkeleton();
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
                      size: 46,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.read(productControllerProvider.notifier).fetchProducts(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) => ref.read(productControllerProvider.notifier).updateSearch(value),
                        decoration: InputDecoration(
                          hintText: 'Cari nama produk atau SKU',
                          hintStyle: AppTypePairing.bodySm(),
                          prefixIcon: const Icon(Icons.search_rounded, size: 19),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLowest,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.indigoSurfaceTint.withValues(alpha: 0.14),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.indigoPrimary.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _FilterButton(state: state),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(productControllerProvider.notifier).fetchProducts(),
                  child: state.products.isEmpty
                      ? const SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 400,
                            child: _EmptyProductsState(),
                          ),
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.products.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          padding: const EdgeInsets.fromLTRB(16, 1, 16, 12),
                          itemBuilder: (context, index) {
                            final item = state.products[index];
                            return InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(product: item),
                                ),
                              ),
                              child: _ListingTile(item: item),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterButton extends ConsumerWidget {
  final ProductState state;
  const _FilterButton({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (sheetContext) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Filter Kategori', style: AppTypePairing.titleMd()),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          IndigoFilterChip(
                            label: 'Semua',
                            selected: state.categoryFilter == null,
                            onTap: () {
                              ref.read(productControllerProvider.notifier).updateCategory(null);
                              Navigator.pop(sheetContext);
                            },
                          ),
                          ...state.categories.map((category) => IndigoFilterChip(
                            label: category.name,
                            selected: state.categoryFilter == category.id,
                            onTap: () {
                              ref.read(productControllerProvider.notifier).updateCategory(category.id);
                              Navigator.pop(sheetContext);
                            },
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: state.categoryFilter != null ? AppColors.primaryFixed : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.indigoSurfaceTint.withValues(alpha: 0.14),
            ),
          ),
          child: Icon(
            Icons.filter_list_rounded,
            color: state.categoryFilter != null ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ListingTile extends StatelessWidget {
  final Product item;

  const _ListingTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = item.stock <= 10;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.indigoSurfaceTint.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SizedBox(
                width: 66,
                height: 70,
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypePairing.valueMd(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU ${item.sku.toUpperCase()} • ${item.categoryName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypePairing.bodySm(
                      color: AppColors.textSecondary,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      _DimensionChip(
                        label: 'P',
                        value: _formatDimen(item.panjangCm),
                      ),
                      _DimensionChip(
                        label: 'L',
                        value: _formatDimen(item.lebarCm),
                      ),
                      _DimensionChip(
                        label: 'T',
                        value: _formatDimen(item.tinggiCm),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rp ${_formatRupiahCompact(item.price.toInt())}',
                          style: AppTypePairing.valueMd(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      _DimensionChip(
                        label: 'Vol',
                        value: _formatVolumeKg(item.volumeCm3),
                        unit: 'kg',
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isLowStock ? AppColors.error : AppColors.indigoPrimary)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Stok ${item.stock}',
                          style: AppTypePairing.labelSmCaps(
                            color: isLowStock ? AppColors.error : AppColors.indigoPrimary,
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
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 18,
      ),
    );
  }

  String _formatDimen(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  String _formatVolumeKg(double volumeCm3) {
    final volumeKg = volumeCm3 / 6000;
    if (volumeKg == volumeKg.roundToDouble()) {
      return volumeKg.toStringAsFixed(0);
    }
    return volumeKg.toStringAsFixed(1);
  }

  String _formatRupiahCompact(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}

class _DimensionChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _DimensionChip({
    required this.label,
    required this.value,
    this.unit = 'cm',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.indigoSurfaceTint.withValues(alpha: 0.14),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTypePairing.labelSmCaps(
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: '$value $unit',
              style: AppTypePairing.labelSmCaps(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 42,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 10),
            Text(
              'Belum ada produk ditemukan',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Coba kata kunci lain atau hubungkan ke internet.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


