import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';

class _Shimmer extends StatefulWidget {
  final Widget child;

  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFFE8ECF2),
                Color(0xFFF4F7FB),
                Color(0xFFE8ECF2),
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class Skeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const Skeleton({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Skeleton(width: size, height: size, borderRadius: size / 2);
  }
}

// ── Home Page Skeleton ──────────────────────────────────────────────
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Greeting + Notification
          Row(
            children: [
              SkeletonCircle(size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 140, height: 14),
                    const SizedBox(height: 6),
                    Skeleton(width: 200, height: 11),
                  ],
                ),
              ),
              SkeletonCircle(size: 32),
            ],
          ),
          const SizedBox(height: 24),
          // Page title
          Skeleton(width: 200, height: 18),
          const SizedBox(height: 12),
          // 4 Metric cards in a row
          Row(
            children: List.generate(4, (i) => Padding(
              padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
              child: Expanded(
                child: Skeleton(height: 30, borderRadius: 16),
              ),
            )),
          ),
          const SizedBox(height: 16),
          // Stats container (2x2 grid)
          Skeleton(height: 160, borderRadius: 12),
          const SizedBox(height: 16),
          // First row of metric tiles
          Row(
            children: [
              Expanded(child: Skeleton(height: 80, borderRadius: 10)),
              const SizedBox(width: 8),
              Expanded(child: Skeleton(height: 80, borderRadius: 10)),
            ],
          ),
          const SizedBox(height: 8),
          // Second row of metric tiles
          Row(
            children: [
              Expanded(child: Skeleton(height: 80, borderRadius: 10)),
              const SizedBox(width: 8),
              Expanded(child: Skeleton(height: 80, borderRadius: 10)),
            ],
          ),
          const SizedBox(height: 24),
          // Performance chart
          Skeleton(height: 220, borderRadius: 12),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

// ── Products Page Skeleton ──────────────────────────────────────────
class ProductsSkeleton extends StatelessWidget {
  const ProductsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Skeleton(height: 40, borderRadius: 12),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Skeleton(height: 34, borderRadius: 12),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            itemCount: 6,
            itemBuilder: (_, i) => const _ProductCardSkeleton(),
          ),
        ),
      ],
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.surfaceContainerLowest,
         borderRadius: BorderRadius.circular(11),
         border: Border.all(color: context.indigoSurfaceTint.withValues(alpha: 0.1)),
         boxShadow: [
           BoxShadow(
             color: context.indigoPrimary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: SkeletonCircle(size: 66),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 9, bottom: 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  Skeleton(width: 160, height: 12),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(3, (i) => Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      child: Skeleton(width: 50, height: 20, borderRadius: 999),
                    )),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: Skeleton(width: 80, height: 16)),
                      const SizedBox(width: 6),
                      Skeleton(width: 60, height: 20, borderRadius: 999),
                      const SizedBox(width: 6),
                      Skeleton(width: 50, height: 20, borderRadius: 999),
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
}

// ── Transactions Page Skeleton ──────────────────────────────────────
class TransactionsSkeleton extends StatelessWidget {
  const TransactionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 800;

    if (isTablet) {
      return _TabletTransactionSkeleton();
    }
    return _MobileTransactionSkeleton();
  }
}

class _MobileTransactionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with title, reset, view toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              Skeleton(width: 100, height: 20),
              const Spacer(),
              Skeleton(width: 34, height: 34, borderRadius: 12),
              const SizedBox(width: 8),
              Skeleton(width: 34, height: 34, borderRadius: 12),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Skeleton(height: 40, borderRadius: 12),
        ),
        const SizedBox(height: 10),
        // Category filter chips (horizontal list)
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: List.generate(6, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Skeleton(width: 80, height: 34, borderRadius: 16),
            )),
          ),
        ),
        const SizedBox(height: 10),
        // Product grid
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            itemCount: 6,
            itemBuilder: (_, i) => Container(
              decoration: BoxDecoration(
color: context.surfaceContainerLowest,
                 borderRadius: BorderRadius.circular(10),
               ),
               padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Skeleton(height: 48, borderRadius: 8),
                  SizedBox(height: 8),
                  Skeleton(height: 12),
                  SizedBox(height: 4),
                  Skeleton(width: 60, height: 10),
                  SizedBox(height: 4),
                  Skeleton(width: 40, height: 14),
                ],
              ),
            ),
          ),
        ),
        // Proceed button area (bottom)
        const SizedBox(height: 80),
      ],
    );
  }
}

class _TabletTransactionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left panel - Products
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: [
                    Skeleton(width: 100, height: 20),
                    const Spacer(),
                    Skeleton(width: 34, height: 34, borderRadius: 12),
                    const SizedBox(width: 8),
                    Skeleton(width: 34, height: 34, borderRadius: 12),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Skeleton(height: 40, borderRadius: 12),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: List.generate(6, (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Skeleton(width: 80, height: 34, borderRadius: 16),
                  )),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, i) => Container(
                    decoration: BoxDecoration(
color: context.surfaceContainerLowest,
                       borderRadius: BorderRadius.circular(10),
                     ),
                     padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Skeleton(height: 48, borderRadius: 8),
                        SizedBox(height: 8),
                        Skeleton(height: 12),
                        SizedBox(height: 4),
                        Skeleton(width: 60, height: 10),
                        SizedBox(height: 4),
                        Skeleton(width: 40, height: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Right panel - Cart/Order Summary
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
    color: context.surfaceContainerLowest,
       borderRadius: BorderRadius.circular(12),
     ),
     child: Column(
              children: [
                Skeleton(width: double.infinity, height: 20),
                const SizedBox(height: 16),
                ...List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SkeletonCircle(size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Skeleton(height: 12),
                            SizedBox(height: 4),
                            Skeleton(width: 60, height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Skeleton(width: 50, height: 12),
                    ],
                  ),
                )),
                const Spacer(),
                Skeleton(height: 90, borderRadius: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── History Page Skeleton ───────────────────────────────────────────
class HistorySkeleton extends StatelessWidget {
  const HistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
          child: Skeleton(height: 40, borderRadius: 12),
        ),
        // Filter chips (horizontal)
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Skeleton(width: i == 3 ? 120 : 70, height: 32, borderRadius: 16),
            )),
          ),
        ),
        const SizedBox(height: 12),
        // ListView list of history cards
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            itemBuilder: (_, i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F3F8), width: 1),
                ),
              ),
              child: Row(
                children: [
                  SkeletonCircle(size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Skeleton(width: 140, height: 14),
                        SizedBox(height: 6),
                        Skeleton(width: 100, height: 11),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Skeleton(width: 70, height: 14),
                      SizedBox(height: 6),
                      Skeleton(width: 50, height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Incoming Goods Page Skeleton ─────────────────────────────────────
class IncomingGoodsSkeleton extends StatelessWidget {
  const IncomingGoodsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        // Stat pills
        Row(
          children: [
            Skeleton(width: 80, height: 32, borderRadius: 8),
            const SizedBox(width: 6),
            Skeleton(width: 80, height: 32, borderRadius: 8),
            const SizedBox(width: 6),
            Skeleton(width: 80, height: 32, borderRadius: 8),
          ],
        ),
        const SizedBox(height: 16),
        // Search field
        Skeleton(height: 38, borderRadius: 10),
        const SizedBox(height: 10),
        // Filter chips
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (context, _) => const SizedBox(width: 6),
            itemBuilder: (_, i) => Skeleton(width: 64, height: 32, borderRadius: 999),
          ),
        ),
        const SizedBox(height: 14),
        // Item cards
        ...List.generate(4, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderLight),
            ),
            child: Row(
              children: [
                Skeleton(width: 40, height: 40, borderRadius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Expanded(child: Skeleton(width: 120, height: 14)),
                          SizedBox(width: 8),
                          Skeleton(width: 56, height: 20, borderRadius: 999),
                        ],
                      ),
                      SizedBox(height: 6),
                      Skeleton(width: 100, height: 12),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Skeleton(width: 70, height: 10),
                          SizedBox(width: 10),
                          Skeleton(width: 50, height: 10),
                          SizedBox(width: 10),
                          Skeleton(width: 80, height: 10),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Skeleton(width: 18, height: 18, borderRadius: 9),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

// ── Login Page Skeleton ─────────────────────────────────────────────
class LoginSkeleton extends StatelessWidget {
  const LoginSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo/brand
              Skeleton(width: 80, height: 18),
              const SizedBox(height: 20),
              // Title
              Skeleton(width: 140, height: 24),
              const SizedBox(height: 22),
              // Email label
              Skeleton(width: 60, height: 14),
              const SizedBox(height: 8),
              // Email field
              Skeleton(height: 48, borderRadius: 12),
              const SizedBox(height: 16),
              // Password label
              Skeleton(width: 80, height: 14),
              const SizedBox(height: 8),
              // Password field
              Skeleton(height: 48, borderRadius: 12),
              const SizedBox(height: 20),
              // Login button
              Skeleton(width: double.infinity, height: 50, borderRadius: 12),
            ],
          ),
        ),
      ),
    );
  }
}