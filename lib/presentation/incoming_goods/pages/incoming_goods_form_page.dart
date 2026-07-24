import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:mitrapos/core/widgets/skeleton.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';
import 'package:mitrapos/data/incoming_goods/models/supplier_model.dart';
import 'package:mitrapos/domain/products/entities/product.dart';
import 'package:mitrapos/presentation/incoming_goods/bloc/incoming_goods_controller.dart';
import 'package:mitrapos/presentation/products/controller/product_controller.dart';
import 'package:mitrapos/core/utils/currency_formatter.dart';

class IncomingGoodsFormPage extends ConsumerStatefulWidget {
  const IncomingGoodsFormPage({super.key});

  @override
  ConsumerState<IncomingGoodsFormPage> createState() => _IncomingGoodsFormPageState();
}

class _IncomingGoodsFormPageState extends ConsumerState<IncomingGoodsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _imagePicker = ImagePicker();

  DateTime _selectedDate = DateTime.now();
  DateTime _orderDate = DateTime.now();
  
  SupplierModel? _selectedSupplier;
  String? _invoiceFileName;
  String? _invoiceFilePath;

  final List<_IncomingItemForm> _items = [];

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _items.add(_IncomingItemForm());
    
    // Fetch data awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incomingGoodsControllerProvider.notifier).loadSuppliers();
      ref.read(productControllerProvider.notifier).fetchProducts();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    for (final item in _items) {
      item.qtyController.dispose();
      item.priceController.dispose();
    }
    super.dispose();
  }



  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
    });
  }

  Future<void> _pickOrderDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _orderDate = picked;
    });
  }

  void _addItem() {
    setState(() {
      _items.add(_IncomingItemForm());
    });
  }

  void _removeItem(int index) {
    if (_items.length == 1) return;
    setState(() {
      _items[index].qtyController.dispose();
      _items[index].priceController.dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _pickInvoiceFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() {
      _invoiceFileName = result.files.first.name;
      _invoiceFilePath = result.files.first.path;
    });
  }

  Future<void> _pickFromCamera() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _invoiceFileName = picked.name;
      _invoiceFilePath = picked.path;
    });
  }

  bool _validateDynamicFields() {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier wajib dipilih')),
      );
      return false;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal 1 produk harus diinput')),
      );
      return false;
    }

    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk pada item ke-${i + 1} wajib dipilih')),
        );
        return false;
      }

      final qtyText = item.qtyController.text.replaceAll('.', '').trim();
      final qty = int.tryParse(qtyText) ?? 0;
      if (qty <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Qty pada item ke-${i + 1} wajib diisi dan lebih dari 0')),
        );
        return false;
      }

      final priceText = item.priceController.text.replaceAll('.', '').trim();
      final price = int.tryParse(priceText) ?? 0;
      if (price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Harga pada item ke-${i + 1} wajib diisi dan lebih dari 0')),
        );
        return false;
      }
    }

    return true;
  }

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || !_validateDynamicFields()) return;

    final data = {
      'supplier_id': _selectedSupplier!.id,
      'tanggal_terima': _selectedDate.toIso8601String(),
      'catatan': _noteController.text.trim(),
      'foto_struk_path': _invoiceFilePath,
      'items': _items.map((item) => {
        'produk_id': item.selectedProduct!.id,
        'jumlah': int.parse(item.qtyController.text.replaceAll('.', '')),
        'harga': double.parse(item.priceController.text.replaceAll('.', '')),
      }).toList(),
    };

    ref.read(incomingGoodsControllerProvider.notifier).submitIncomingGoods(data);
  }

  @override
  Widget build(BuildContext context) {
    final incomingState = ref.watch(incomingGoodsControllerProvider);
    final productState = ref.watch(productControllerProvider);
    
    // Listen for success or error
    ref.listen(incomingGoodsControllerProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang masuk berhasil disimpan. Menunggu persetujuan admin.')),
        );
        // Reset status immediately so it doesn't trigger again
        ref.read(incomingGoodsControllerProvider.notifier).resetStatus();

        if (!_isNavigating && Navigator.canPop(context)) {
          _isNavigating = true;
          Navigator.pop(context);
          _isNavigating = false;
        }
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.errorMessage}')),
        );
        // Reset status immediately so it doesn't trigger again
        ref.read(incomingGoodsControllerProvider.notifier).resetStatus();
      }
    });

    final dateText = DateFormat('dd MMM yyyy').format(_selectedDate);
    final orderDateText = DateFormat('dd MMM yyyy').format(_orderDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Text('Form Penerimaan Barang', style: AppTypePairing.headlineLg()),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              children: [
                const _SectionHeader(
                  title: 'Informasi Utama',
                  subtitle: 'Isi data dokumen utama sebelum menambahkan produk.',
                  icon: Icons.description_outlined,
                ),
                const SizedBox(height: 16),
                _TapField(
                  label: 'Tanggal Pemesanan',
                  value: orderDateText,
                  onTap: _pickOrderDate,
                  suffixIcon: Icons.event_note_outlined,
                ),
                const SizedBox(height: 12),
                _TapField(
                  label: 'Tanggal Masuk',
                  value: dateText,
                  onTap: _pickDate,
                  suffixIcon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 12),
                _TapField(
                  label: 'Supplier',
                  value: _selectedSupplier?.nama ?? 'Pilih supplier',
                  onTap: () async {
                    if (incomingState.suppliers.isEmpty) {
                      ref.read(incomingGoodsControllerProvider.notifier).loadSuppliers();
                    }
                    
                    final selected = await _showSearchablePicker<SupplierModel>(
                      title: 'Pilih Supplier',
                      options: incomingState.suppliers,
                      getLabel: (s) => s.nama,
                    );
                    if (selected == null) return;
                    setState(() => _selectedSupplier = selected);
                  },
                  suffixIcon: Icons.search,
                  isPlaceholder: _selectedSupplier == null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  decoration: buildFieldDecoration(
                    context,
                    labelText: 'Catatan (Opsional)',
                    hintText: 'Contoh: Penerimaan rutin dari supplier A',
                  ),
                ),
                const SizedBox(height: 16),
                _InvoiceUploadSection(
                  fileName: _invoiceFileName,
                  onUpload: _pickInvoiceFile,
                  onCamera: _pickFromCamera,
                ),
                const SizedBox(height: 32),
                const _SectionHeader(
                  title: 'Input Produk',
                  subtitle: 'Minimal 1 produk dengan qty lebih dari 0.',
                  icon: Icons.playlist_add_check_circle_outlined,
                ),
                const SizedBox(height: 16),
                _ProductInputHeader(itemCount: _items.length),
                const SizedBox(height: 12),
                ...List.generate(
                  _items.length,
                  (index) {
                    final item = _items[index];
                    return _ProductItemFormWidget(
                      index: index,
                      item: item,
                      products: productState.products,
                      onRemove: () => _removeItem(index),
                      onProductSelect: () async {
                        final selected = await _showSearchablePicker<Product>(
                          title: 'Pilih Produk',
                          options: productState.products,
                          getLabel: (p) => '[${p.sku}] ${p.name}',
                        );
                        if (selected == null) return;
                        setState(() => item.selectedProduct = selected);
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                _AddProductButton(onPressed: _addItem),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (incomingState.isSubmitting)
            const Center(child: Skeleton(height: 48, borderRadius: 24)),
        ],
      ),
      bottomNavigationBar: _BottomSubmitBar(
        onCancel: () => Navigator.pop(context),
        onSubmit: _submit,
        isSubmitting: incomingState.isSubmitting,
      ),
    );
  }

  Future<T?> _showSearchablePicker<T>({
    required String title,
    required List<T> options,
    required String Function(T) getLabel,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _SearchablePickerSheet<T>(
          title: title, 
          options: options,
          getLabel: getLabel,
        );
      },
    );
  }
}

class _IncomingItemForm {
  Product? selectedProduct;
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
}

// Internal Widgets
class _ProductItemFormWidget extends StatelessWidget {
  final int index;
  final _IncomingItemForm item;
  final List<Product> products;
  final VoidCallback onRemove;
  final VoidCallback onProductSelect;

  const _ProductItemFormWidget({
    required this.index,
    required this.item,
    required this.products,
    required this.onRemove,
    required this.onProductSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ItemBadge(index: index),
                const SizedBox(width: 8),
                Text(
                  'Item Produk',
                  style: AppTypePairing.bodySm(
                    color: context.textPrimary,
                    weight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.delete_outline, size: 17, color: context.error),
                  style: IconButton.styleFrom(backgroundColor: context.errorLight),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TapField(
              label: 'Produk',
              value: item.selectedProduct != null 
                  ? '[${item.selectedProduct!.sku}] ${item.selectedProduct!.name}' 
                  : 'Pilih produk',
              onTap: onProductSelect,
              suffixIcon: Icons.search,
              isPlaceholder: item.selectedProduct == null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: item.qtyController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              decoration: buildFieldDecoration(
                context,
                labelText: 'Qty',
                hintText: '0',
              ),
              validator: (value) {
                final text = (value ?? '').replaceAll('.', '').trim();
                final qty = int.tryParse(text) ?? 0;
                if (qty <= 0) return 'Wajib';
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: item.priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              decoration: buildFieldDecoration(
                context,
                labelText: 'Harga',
                hintText: '0',
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Rp', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              validator: (value) {
                final text = (value ?? '').replaceAll('.', '').trim();
                final price = int.tryParse(text) ?? 0;
                if (price <= 0) return 'Wajib';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemBadge extends StatelessWidget {
  final int index;
  const _ItemBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.indigoPrimary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${index + 1}',
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}



class _TapField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData suffixIcon;
  final bool isPlaceholder;

  const _TapField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.suffixIcon,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: InputDecorator(
        decoration: buildFieldDecoration(
          context,
          labelText: label,
          suffixIcon: Icon(suffixIcon, size: 18),
        ),
        child: Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isPlaceholder ? context.textTertiary : context.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SearchablePickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> options;
  final String Function(T) getLabel;

  const _SearchablePickerSheet({
    required this.title,
    required this.options,
    required this.getLabel,
  });

  @override
  State<_SearchablePickerSheet<T>> createState() => _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<_SearchablePickerSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where((e) => widget.getLabel(e).toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(widget.title, style: AppTypePairing.headlineLg()),
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: buildFieldDecoration(
              context,
              labelText: 'Cari data',
              hintText: 'Cari...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return ListTile(
                  title: Text(widget.getLabel(item)),
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.indigoPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: context.indigoPrimary, size: 20),
              ),
              const SizedBox(width: 12),
            ],
            Text(title, style: AppTypePairing.titleMd(weight: FontWeight.w900)),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: icon != null ? 40 : 0),
            child: Text(
              subtitle!,
              style: AppTypePairing.bodySm(color: context.textTertiary, weight: FontWeight.w500),
            ),
          ),
        ],
      ],
    );
  }
}

class _InvoiceUploadSection extends StatelessWidget {
  final String? fileName;
  final VoidCallback onUpload;
  final VoidCallback onCamera;

  const _InvoiceUploadSection({
    required this.fileName,
    required this.onUpload,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('Pilih File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: context.indigoPrimary.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: const Text('Ambil Foto'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: context.indigoPrimary.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
        if (fileName != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.successLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: context.success, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName!,
                    style: AppTypePairing.bodySm(color: context.success, weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ProductInputHeader extends StatelessWidget {
  final int itemCount;
  const _ProductInputHeader({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Daftar Produk', style: AppTypePairing.titleMd()),
        Text('$itemCount Item', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _AddProductButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddProductButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('Tambah Produk'),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
    );
  }
}

class _BottomSubmitBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const _BottomSubmitBar({
    required this.onCancel,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: context.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: isSubmitting ? null : onCancel,
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Batal',
                style: AppTypePairing.bodyMd(color: context.textSecondary, weight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: context.indigoPrimary,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: isSubmitting 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: Skeleton(width: 20, height: 20, borderRadius: 10)
                    ) 
                  : Text(
                      'Simpan Data',
                      style: AppTypePairing.bodyMd(color: Colors.white, weight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration buildFieldDecoration(BuildContext context, {
  required String labelText,
  String? hintText,
  Widget? suffixIcon,
  Widget? prefixIcon,
  bool filled = true,
  Color? fillColor,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: AppTypePairing.bodySm(color: context.textSecondary, weight: FontWeight.w600),
    hintText: hintText,
    hintStyle: AppTypePairing.bodySm(color: context.textTertiary),
    suffixIcon: suffixIcon,
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: fillColor ?? Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.border.withValues(alpha: 0.5), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.border.withValues(alpha: 0.5), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.indigoPrimary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.error, width: 1),
    ),
  );
}