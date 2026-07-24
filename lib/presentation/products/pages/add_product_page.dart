import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';
import 'package:mitrapos/domain/products/entities/product_item.dart';
import 'package:mitrapos/presentation/products/controller/add_product_controller.dart';

class AddProductPage extends ConsumerWidget {
  final ListingItem? initialItem;

  const AddProductPage({super.key, this.initialItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        addProductControllerProvider.overrideWith(
          (providerRef) => AddProductController(initialItem: initialItem),
        ),
      ],
      child: const _AddProductView(),
    );
  }
}

class _AddProductView extends ConsumerWidget {
  const _AddProductView();

  bool _isCoreInfoComplete(AddProductState state) {
    return state.title.trim().isNotEmpty &&
        state.brand.trim().isNotEmpty &&
        state.price.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductControllerProvider);

        if (state.isPublished) {
          return _PublishSuccessView(isEditMode: state.isEditMode);
        }

        final canContinue = _isCoreInfoComplete(state);
        final title = state.isEditMode ? 'Edit Product' : 'Add Product';

        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF6F7FB),
            elevation: 0,
            toolbarHeight: 48,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Color(0xFF111A7A),
              ),
            ),
            title: Text(
              title,
              style: AppTextStyles.headingSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111A7A),
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: canContinue
                  ? () => ref.read(addProductControllerProvider.notifier).publish()
                    : null,
                icon: const Icon(
                  Icons.check,
                  size: 20,
                  color: Color(0xFF111A7A),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: _ProductEditorForm(state: state),
                ),
              ),
              _BottomActions(
                state: state,
                canContinue: canContinue,
                onContinue: () => ref.read(addProductControllerProvider.notifier).publish(),
                onSaveChanges: () => ref.read(addProductControllerProvider.notifier).publish(),
              ),
            ],
          ),
        );
  }
}

class _ProductEditorForm extends ConsumerWidget {
  final AddProductState state;

  const _ProductEditorForm({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cubit = ref.read(addProductControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF111A7A).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: double.infinity,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?w=1000',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFD8DBE2),
                      child: const Icon(Icons.image_outlined, size: 32),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF111A7A).withValues(alpha: 0.32),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 12,
                    bottom: 10,
                    child: Row(
                      children: [
                        Icon(Icons.photo_outlined, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Product Cover',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _EditorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(index: 1, title: 'Basic Info'),
              const SizedBox(height: 6),
              _InputField(
                label: 'Brand',
                initialValue: state.brand,
                onChanged: cubit.setBrand,
                fillColor: const Color(0xFFF4F5F9),
              ),
              const SizedBox(height: 6),
              _InputField(
                label: 'Product Name',
                initialValue: state.title,
                onChanged: cubit.setTitle,
                fillColor: const Color(0xFFF4F5F9),
              ),
              const SizedBox(height: 6),
              _InputField(
                label: 'Price (IDR)',
                initialValue: state.price,
                keyboardType: TextInputType.number,
                onChanged: cubit.setPrice,
                prefixText: 'Rp',
                fillColor: const Color(0xFFF4F5F9),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _EditorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(index: 2, title: 'Dimensions & Weight'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _DimensionToggleChip(
                      label: 'Length (P)',
                      selected: state.isLengthEnabled,
                      onTap: cubit.toggleLengthEnabled,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _DimensionToggleChip(
                      label: 'Width (L)',
                      selected: state.isWidthEnabled,
                      onTap: cubit.toggleWidthEnabled,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _DimensionToggleChip(
                      label: 'Height (T)',
                      selected: state.isHeightEnabled,
                      onTap: cubit.toggleHeightEnabled,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _DimensionToggleChip(
                      label: 'Weight',
                      selected: state.isWeightEnabled,
                      onTap: cubit.toggleWeightEnabled,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5FB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDCE0EE)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _DimensionValueField(
                        label: 'P (CM)',
                        value: state.panjangCm,
                        onChanged: cubit.setPanjangCm,
                        enabled: state.isLengthEnabled,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _DimensionValueField(
                        label: 'L (CM)',
                        value: state.lebarCm,
                        onChanged: cubit.setLebarCm,
                        enabled: state.isWidthEnabled,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _DimensionValueField(
                        label: 'T (CM)',
                        value: state.tinggiCm,
                        onChanged: cubit.setTinggiCm,
                        enabled: state.isHeightEnabled,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDCE0EE)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL WEIGHT',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF111A7A),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Manual weight entry',
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 96,
                      child: TextFormField(
                        initialValue: state.weightKg,
                        enabled: state.isWeightEnabled,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: state.isWeightEnabled ? cubit.setWeightKg : null,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: state.isWeightEnabled ? const Color(0xFF111A7A) : const Color(0xFF8A8FA2),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: state.isWeightEnabled ? const Color(0xFFF7F8FC) : const Color(0xFFE8EBF2),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: context.indigoPrimary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'kg',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final int index;
  final String title;

  const _SectionHeader({required this.index, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'SECTION ${index.toString().padLeft(2, '0')}',
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            fontSize: 8.5,
            color: const Color(0xFF30343F),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.headingMedium.copyWith(
            color: const Color(0xFF101A74),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _EditorCard extends StatelessWidget {
  final Widget child;

  const _EditorCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7F1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111A7A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DimensionToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DimensionToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2F5FF) : const Color(0xFFF7F8FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF8E99CF) : const Color(0xFFD5DBEA),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111A7A).withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF111A7A)
                    : const Color(0xFFE1E3E8),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(
                selected ? Icons.check : Icons.close,
                size: 10,
                color: selected ? Colors.white : const Color(0xFF7B8296),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: const Color(0xFF272B38),
                  fontWeight: FontWeight.w600,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DimensionValueField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const _DimensionValueField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: enabled ? const Color(0xFF3A3F4E) : const Color(0xFF8A8FA2),
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 3),
        TextFormField(
          initialValue: value,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: enabled ? onChanged : null,
          style: AppTextStyles.headingMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: enabled ? context.textPrimary : const Color(0xFF8A8FA2),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? const Color(0xFFF4F5F7)
                : const Color(0xFFE4E6EC),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 7,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.indigoPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  final AddProductState state;
  final bool canContinue;
  final VoidCallback onContinue;
  final VoidCallback onSaveChanges;

  const _BottomActions({
    required this.state,
    required this.canContinue,
    required this.onContinue,
    required this.onSaveChanges,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: SizedBox(
        width: double.infinity,
        height: 42,
        child: ElevatedButton(
          onPressed: canContinue
              ? (state.isEditMode ? onSaveChanges : onContinue)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF111A7A),
            disabledBackgroundColor: const Color(0xFF8E93BE),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            elevation: 3,
            shadowColor: const Color(0x33111A7A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              state.isEditMode ? 'SAVE CHANGES' : 'ADD PRODUCT',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PublishSuccessView extends StatelessWidget {
  final bool isEditMode;

  const _PublishSuccessView({required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFFEDEDED),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: context.indigoPrimary,
                  child: Icon(Icons.check, color: Colors.white, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isEditMode ? 'Produk Diperbarui' : 'Produk Dipublikasikan',
              style: AppTextStyles.headingLarge,
            ),
            const SizedBox(height: 6),
            Text(
              isEditMode
                  ? 'Perubahan produk berhasil disimpan.'
                  : 'Produk berhasil dipublikasikan.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isEditMode ? 'Kembali ke Produk' : 'Kembali ke Beranda',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final Color fillColor;
  final String? prefixText;

  const _InputField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
    this.fillColor = Colors.white,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 3),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTextStyles.headingMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            prefixText: prefixText == null ? null : '$prefixText  ',
            prefixStyle: AppTextStyles.headingSmall.copyWith(
              color: const Color(0xFF3A3F4E),
              fontWeight: FontWeight.w700,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: Color(0xFFD7DDED)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: Color(0xFFD7DDED)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(color: context.indigoPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

