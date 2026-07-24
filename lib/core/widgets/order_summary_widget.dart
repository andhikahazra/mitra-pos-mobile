import 'package:flutter/material.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/utils/currency_formatter.dart';

class OrderSummaryItem {
  final String name;
  final String? variant;
  final int quantity;
  final int unitPrice;
  final int lineTotal;
  final String? imageUrl;
  final VoidCallback? onDelete;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const OrderSummaryItem({
    required this.name,
    this.variant,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.imageUrl,
    this.onDelete,
    this.onIncrement,
    this.onDecrement,
  });
}

class OrderSummaryWidget extends StatelessWidget {
  final String title;
  final List<OrderSummaryItem> items;
  final int subTotal;
  final int tax;
  final int discount;
  final int total;
  final String? paymentMethod;
  final int? adminFee;
  final int itemCount;

  const OrderSummaryWidget({
    super.key,
    this.title = 'Detail Transaction',
    required this.items,
    required this.subTotal,
    required this.tax,
    required this.discount,
    required this.total,
    this.paymentMethod,
    this.adminFee,
    this.itemCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.indigoSurfaceTint.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypePairing.titleMd(
              color: context.textPrimary,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 32,
                              color: context.textTertiary.withValues(alpha: 0.4),
                            ),
                        const SizedBox(height: 8),
Text(
                            'Belum ada item',
                            style: AppTypePairing.bodyMd(
                              color: context.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (ctx, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _OrderSummaryItemTile(item: item);
                    },
                  ),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SummarySection(
              subTotal: subTotal,
              tax: tax,
              discount: discount,
              total: total,
              itemCount: itemCount,
              paymentMethod: paymentMethod,
              adminFee: adminFee,
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderSummaryItemTile extends StatelessWidget {
  final OrderSummaryItem item;

  const _OrderSummaryItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.indigoSurfaceTint.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 44,
              height: 44,
              color: context.surfaceContainerLow,
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: context.indigoSurfaceTint,
                      ),
                    )
                  : Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: context.indigoSurfaceTint,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypePairing.bodyMd(
                    color: context.textPrimary,
                    weight: FontWeight.w700,
                  ),
                ),
                if (item.variant != null && item.variant!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.variant!,
style: AppTypePairing.bodySm(
                        color: context.textSecondary,
                      ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: item.onDecrement,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 14,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '${item.quantity}',
                      style: AppTypePairing.bodyMd(
                        color: context.textPrimary,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: item.onIncrement,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: context.indigoPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 14,
                        color: context.indigoPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(item.lineTotal, symbol: 'Rp'),
                style: AppTypePairing.bodyMd(
                  color: context.textPrimary,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final int subTotal;
  final int tax;
  final int discount;
  final int total;
  final int? adminFee;
  final int itemCount;
  final String? paymentMethod;

  const _SummarySection({
    required this.subTotal,
    required this.tax,
    required this.discount,
    required this.total,
    this.adminFee,
    required this.itemCount,
    this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.indigoSurfaceTint.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          if (itemCount > 0) ...[
            _SummaryRow(
              label: 'Jumlah Item',
              value: '$itemCount item',
            ),
            const SizedBox(height: 8),
          ],
          _SummaryRow(
            label: 'Sub-Total',
            value: CurrencyFormatter.format(subTotal, symbol: 'Rp'),
          ),
          if (adminFee != null && adminFee! > 0) ...[
            const SizedBox(height: 6),
            _SummaryRow(
              label: 'Biaya Admin',
              value: CurrencyFormatter.format(adminFee!, symbol: 'Rp'),
            ),
          ],
          if (paymentMethod != null && paymentMethod!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _SummaryRow(
              label: 'Metode',
              value: paymentMethod!,
            ),
          ],
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Pajak',
            value: CurrencyFormatter.format(tax, symbol: 'Rp'),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Diskon',
            value: '-${CurrencyFormatter.format(discount, symbol: 'Rp')}',
            valueColor: context.error,
          ),
          const SizedBox(height: 8),
            Container(
              height: 1,
              color: context.divider,
            ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Total Pembayaran',
            value: CurrencyFormatter.format(total, symbol: 'Rp'),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
      final labelStyle = isBold
          ? AppTypePairing.bodyMd(
              color: context.textPrimary,
              weight: FontWeight.w700,
            )
          : AppTypePairing.bodyMd(
              color: context.textSecondary,
            );

    final valueStyle = isBold
        ? AppTypePairing.bodyMd(
            color: valueColor ?? context.textPrimary,
            weight: FontWeight.w700,
          )
        : AppTypePairing.bodyMd(
            color: valueColor ?? context.textPrimary,
            weight: FontWeight.w600,
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
