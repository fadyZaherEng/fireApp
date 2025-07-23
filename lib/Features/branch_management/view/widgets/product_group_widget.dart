import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/branch_widgets.dart';
import '../../../../core/widgets/product_card.dart';
import '../../models/product_data.dart';
import '../../models/product_type.dart';

class ProductGroupWidget extends StatelessWidget {
  final ProductType productType;
  final List<ProductData> products;
  final List<String> variantNames;
  final bool isLoadingVariants;
  final bool hasLoadedVariants;
  final Function(String?) onVariantChanged;
  final Function(int) onQuantityChanged;
  final VoidCallback onDropdownOpened;
  final VoidCallback onAddMore;
  final AppLocalizations localizations;
  final bool isRTL;

  const ProductGroupWidget({
    super.key,
    required this.productType,
    required this.products,
    required this.variantNames,
    required this.isLoadingVariants,
    required this.hasLoadedVariants,
    required this.onVariantChanged,
    required this.onQuantityChanged,
    required this.onDropdownOpened,
    required this.onAddMore,
    required this.localizations,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...products.map((productData) {
          String? validatedSelectedVariant = _getValidatedSelectedVariant(
            productData.selectedVariant,
            variantNames,
            isLoadingVariants,
            hasLoadedVariants,
          );

          return ProductCard(
            title: localizations.translate(productType.nameKey),
            imagePath: productType.imagePath,
            variantList: variantNames,
            selectedVariant: validatedSelectedVariant,
            quantity: productData.quantity,
            onDropdownOpened: onDropdownOpened,
            onVariantChanged: onVariantChanged,
            onQuantityChanged: (value) => onQuantityChanged(value ?? 0),
          );
        }).toList(),
        SizedBox(height: 8.h),
        OutlinePlusButton(
          text: localizations.translate('addMoreProduct'),
          onPressed: onAddMore,
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  String? _getValidatedSelectedVariant(
    String? currentSelection,
    List<String> variantNames,
    bool isLoadingVariants,
    bool hasLoadedVariants,
  ) {
    if (isLoadingVariants && !hasLoadedVariants) {
      return null;
    }

    if (currentSelection == 'Loading...' ||
        currentSelection == 'No variants available') {
      return null;
    }

    if (currentSelection != null && variantNames.contains(currentSelection)) {
      return currentSelection;
    }

    return null;
  }
}
