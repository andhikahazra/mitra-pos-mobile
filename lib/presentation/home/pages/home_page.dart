import 'dart:async';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:mitrapos/core/constants/app_constants.dart';

import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';
import 'package:mitrapos/core/utils/currency_formatter.dart';
import 'package:mitrapos/core/widgets/metric_tile.dart';
import 'package:mitrapos/core/widgets/mitrapos_bottom_nav_bar.dart';
import 'package:mitrapos/core/widgets/mitrapos_sidebar.dart';
import 'package:mitrapos/core/widgets/skeleton.dart';
import 'package:mitrapos/presentation/auth/controller/auth_controller.dart';
import 'package:mitrapos/presentation/home/controller/home_controller.dart';
import 'package:mitrapos/presentation/home/widgets/performance_chart.dart';
import 'package:mitrapos/presentation/home/widgets/period_filter_chip.dart';
import 'package:mitrapos/presentation/home/widgets/store_info_card.dart';
import 'package:mitrapos/presentation/home/widgets/user_profile_header.dart';
import 'package:mitrapos/presentation/incoming_goods/pages/incoming_goods_page.dart';
import 'package:mitrapos/presentation/products/pages/products_page.dart';
import 'package:mitrapos/presentation/history/pages/history_page.dart';
import 'package:mitrapos/presentation/profile/pages/profile_page.dart';
import 'package:mitrapos/presentation/transactions/pages/transactions_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;


  String _selectedPeriod = 'today';
  bool _isPrinterConnected = false;
  Timer? _printerStatusTimer;

  final List<String> _periods = ['Hari ini', 'Kemarin', '7 hari', '30 hari'];
  final List<String> _periodValues = ['today', 'yesterday', 'week', 'month'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshPrinterConnectionStatus());
    _printerStatusTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => unawaited(_refreshPrinterConnectionStatus()),
    );

    // Defer initial load until first frame to avoid provider mutation during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(homeControllerProvider.notifier)
          .add(LoadDashboard(_selectedPeriod));
      ref.read(authControllerProvider.notifier).add(const GetProfileRequested());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshPrinterConnectionStatus());
    }
  }

  Future<void> _refreshPrinterConnectionStatus() async {
    try {
      final connected = (await _bluetooth.isConnected) ?? false;
      if (!mounted || connected == _isPrinterConnected) return;
      setState(() {
        _isPrinterConnected = connected;
      });
    } on MissingPluginException {
      if (!mounted || !_isPrinterConnected) return;
      setState(() {
        _isPrinterConnected = false;
      });
    } on PlatformException {
      if (!mounted || !_isPrinterConnected) return;
      setState(() {
        _isPrinterConnected = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _printerStatusTimer?.cancel();
    super.dispose();
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    ref.read(homeControllerProvider.notifier).add(ChangePeriod(period));
  }

    @override
    Widget build(BuildContext context) {
      final homeState = ref.watch(homeControllerProvider);
      final isTablet = MediaQuery.of(context).size.width >= 800;

      void handleNav(int index) {
        if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsPage()));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TransactionsPage()));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
        } else if (index == 4) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const IncomingGoodsPage()));
        }
      }

      Widget homeBody() {
      return Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authControllerProvider);
              final user = authState.user;
              return UserProfileHeader(
                name: user?.name ?? 'Memuat...',
                email: user?.email ?? '...',
                isPrinterConnected: _isPrinterConnected,
                onProfileTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                },
              );
            },
          ),
          const SizedBox(height: AppConstants.paddingSM),
          const SizedBox(height: AppConstants.paddingMD),
          Expanded(child: _buildHomeTab(homeState)),
        ],
      );
    }

    if (isTablet) {
      return Scaffold(
        backgroundColor: context.surfaceContainerLowest,
        body: SafeArea(
          child: Row(
            children: [
              MitraPOSSidebar(currentIndex: 0, onTap: handleNav),
              Expanded(child: homeBody()),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.surfaceContainerLowest,
      bottomNavigationBar: Navigator.canPop(context)
          ? null
          : MitraPOSBottomNavBar(
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductsPage()));
                } else if (index == 2) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TransactionsPage()));
                } else if (index == 3) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
                } else if (index == 4) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const IncomingGoodsPage()));
                }
              },
            ),
      body: homeBody(),
    );
  }



  Widget _buildHomeTab(HomeState state) {
    if (state is HomeLoading || state is HomeInitial) {
      return const HomeSkeleton();
    }

    if (state is HomeError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.error),
            const SizedBox(height: AppConstants.paddingMD),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLG),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(homeControllerProvider.notifier)
                    .add(const RefreshDashboard());
              },
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    if (state is HomeLoaded) {
      return RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(homeControllerProvider.notifier)
              .add(const RefreshDashboard());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMD,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoreInfoCard(
                storeName: state.storeInfo.name,
                username: state.storeInfo.username,
                category: state.storeInfo.category,
                rating: 4.9, // Tetap hardcoded atau bisa ditambahkan ke API nanti
                totalProducts: state.storeInfo.totalProducts,
                activeProducts: state.storeInfo.activeProducts,
                followers: 426, // Tetap hardcoded
              ),
              const SizedBox(height: AppConstants.paddingMD),

              Text(
                'Ringkasan Penjualan Hari Ini',
                style: AppTypePairing.headlineLg(),
              ),
              const SizedBox(height: 12),

              // Period Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _periods.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        right: index < _periods.length - 1
                            ? AppConstants.paddingSM
                            : 0,
                      ),
                      child: PeriodFilterChip(
                        label: _periods[index],
                        isSelected: _selectedPeriod == _periodValues[index],
                        onTap: () => _onPeriodChanged(_periodValues[index]),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingMD),

              Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.surfaceContainerLowest,
                      context.surfaceContainerLow,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.indigoPrimary.withValues(alpha: 0.22),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            icon: Icons.visibility_outlined,
                            label: 'Transaksi',
                            value: state.stats.views.toString(),
                            iconColor: context.indigoPrimaryFixed,
                            trendLabel: state.stats.viewsGrowth >= 0
                                ? '+${state.stats.viewsGrowth}%'
                                : '${state.stats.viewsGrowth}%',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MetricTile(
                            icon: Icons.emoji_people_outlined,
                            label: 'Aktivitas',
                            value: state.stats.visits.toString(),
                            iconColor: context.textPrimary,
                            trendLabel: state.stats.visitsGrowth >= 0
                                ? '+${state.stats.visitsGrowth}%'
                                : '${state.stats.visitsGrowth}%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Item Terjual',
                            value: state.stats.orders.toString(),
                            iconColor: context.warning,
                            trendLabel: state.stats.ordersGrowth >= 0
                                ? '+${state.stats.ordersGrowth}%'
                                : '${state.stats.ordersGrowth}%',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MetricTile(
                            icon: Icons.attach_money,
                            label: 'Omzet',
                            value: CurrencyFormatter.format(
                              state.stats.revenue,
                            ),
                            iconColor: context.textPrimary,
                            trendLabel: state.stats.revenueGrowth >= 0
                                ? '+${state.stats.revenueGrowth}%'
                                : '${state.stats.revenueGrowth}%',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingMD),

              // Performance Chart
              PerformanceChart(data: state.performanceData),

              const SizedBox(height: 26),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }


}
