import '../data/models/product_item_model.dart';
import 'product_type.dart';

class ProductData {
  final String id;
  final ProductType type;
  final String? selectedVariant;
  final ProductItem? selectedVariantItem;
  final int? quantity;

  ProductData({
    required this.id,
    required this.type,
    this.selectedVariant,
    this.selectedVariantItem,
    this.quantity,
  });

  ProductData copyWith({
    String? selectedVariant,
    ProductItem? selectedVariantItem,
    int? quantity,
  }) {
    return ProductData(
      id: id,
      type: type,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedVariantItem: selectedVariantItem ?? this.selectedVariantItem,
      quantity: quantity ?? this.quantity,
    );
  }
}
