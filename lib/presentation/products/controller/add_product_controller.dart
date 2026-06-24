import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitrapos/domain/products/entities/product_item.dart';

part 'add_product_state.dart';

final addProductControllerProvider =
    StateNotifierProvider.autoDispose<AddProductController, AddProductState>(
  (ref) => throw UnimplementedError('Override addProductControllerProvider in a ProviderScope'),
);

class AddProductController extends StateNotifier<AddProductState> {
  AddProductController({ListingItem? initialItem})
      : super(
          initialItem == null
              ? const AddProductState()
              : AddProductState(
                  isEditMode: true,
                  status: initialItem.status,
                  condition: initialItem.condition,
                  title: initialItem.title,
                  brand: initialItem.brand,
                  price: initialItem.price.toString(),
                  size: 'Medium',
                  description: initialItem.subtitle,
                  panjangCm: initialItem.panjangCm.toStringAsFixed(
                    initialItem.panjangCm == initialItem.panjangCm.roundToDouble()
                        ? 0
                        : 1,
                  ),
                  lebarCm: initialItem.lebarCm.toStringAsFixed(
                    initialItem.lebarCm == initialItem.lebarCm.roundToDouble()
                        ? 0
                        : 1,
                  ),
                  tinggiCm: initialItem.tinggiCm.toStringAsFixed(
                    initialItem.tinggiCm == initialItem.tinggiCm.roundToDouble()
                        ? 0
                        : 1,
                  ),
                ),
        );

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void publish() {
    state = state.copyWith(isPublished: true);
  }

  void setStatus(String value) => state = state.copyWith(status: value);
  void setCondition(String value) => state = state.copyWith(condition: value);
  void setTitle(String value) => state = state.copyWith(title: value);
  void setBrand(String value) => state = state.copyWith(brand: value);
  void setPrice(String value) => state = state.copyWith(price: value);
  void setSize(String value) => state = state.copyWith(size: value);
  void setDescription(String value) => state = state.copyWith(description: value);
  void setPanjangCm(String value) => state = state.copyWith(panjangCm: value);
  void setLebarCm(String value) => state = state.copyWith(lebarCm: value);
  void setTinggiCm(String value) => state = state.copyWith(tinggiCm: value);
  void setWeightKg(String value) => state = state.copyWith(weightKg: value);

  void toggleLengthEnabled() {
    state = state.copyWith(isLengthEnabled: !state.isLengthEnabled);
  }

  void toggleWidthEnabled() {
    state = state.copyWith(isWidthEnabled: !state.isWidthEnabled);
  }

  void toggleHeightEnabled() {
    state = state.copyWith(isHeightEnabled: !state.isHeightEnabled);
  }

  void toggleWeightEnabled() {
    state = state.copyWith(isWeightEnabled: !state.isWeightEnabled);
  }
}

