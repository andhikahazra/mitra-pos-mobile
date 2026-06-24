part of 'add_product_controller.dart';

class AddProductState extends Equatable {
  final int currentStep;
  final bool isPublished;
  final bool isEditMode;
  final String status;
  final String condition;
  final String title;
  final String brand;
  final String price;
  final String size;
  final String description;
  final String panjangCm;
  final String lebarCm;
  final String tinggiCm;
  final String weightKg;
  final bool isLengthEnabled;
  final bool isWidthEnabled;
  final bool isHeightEnabled;
  final bool isWeightEnabled;

  const AddProductState({
    this.currentStep = 1,
    this.isPublished = false,
    this.isEditMode = false,
    this.status = 'Inactive',
    this.condition = 'Like New',
    this.title = 'Classic Flap Bag Medium',
    this.brand = 'CHANEL',
    this.price = '899',
    this.size = 'Medium',
    this.description = '',
    this.panjangCm = '40',
    this.lebarCm = '30',
    this.tinggiCm = '25',
    this.weightKg = '2.50',
    this.isLengthEnabled = true,
    this.isWidthEnabled = true,
    this.isHeightEnabled = true,
    this.isWeightEnabled = true,
  });

  AddProductState copyWith({
    int? currentStep,
    bool? isPublished,
    bool? isEditMode,
    String? status,
    String? condition,
    String? title,
    String? brand,
    String? price,
    String? size,
    String? description,
    String? panjangCm,
    String? lebarCm,
    String? tinggiCm,
    String? weightKg,
    bool? isLengthEnabled,
    bool? isWidthEnabled,
    bool? isHeightEnabled,
    bool? isWeightEnabled,
  }) {
    return AddProductState(
      currentStep: currentStep ?? this.currentStep,
      isPublished: isPublished ?? this.isPublished,
      isEditMode: isEditMode ?? this.isEditMode,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      size: size ?? this.size,
      description: description ?? this.description,
      panjangCm: panjangCm ?? this.panjangCm,
      lebarCm: lebarCm ?? this.lebarCm,
      tinggiCm: tinggiCm ?? this.tinggiCm,
      weightKg: weightKg ?? this.weightKg,
      isLengthEnabled: isLengthEnabled ?? this.isLengthEnabled,
      isWidthEnabled: isWidthEnabled ?? this.isWidthEnabled,
      isHeightEnabled: isHeightEnabled ?? this.isHeightEnabled,
      isWeightEnabled: isWeightEnabled ?? this.isWeightEnabled,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        isPublished,
      isEditMode,
        status,
        condition,
        title,
        brand,
        price,
        size,
        description,
        panjangCm,
        lebarCm,
        tinggiCm,
        weightKg,
        isLengthEnabled,
        isWidthEnabled,
        isHeightEnabled,
        isWeightEnabled,
      ];
}
