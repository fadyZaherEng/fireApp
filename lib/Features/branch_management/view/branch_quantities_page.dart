import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:safetyZone/Features/auth_features/login_feature/widgets/primary_button.dart';
import 'package:safetyZone/Features/branch_management/models/product_data.dart';
import 'package:safetyZone/Features/branch_management/models/product_type.dart';
import 'package:safetyZone/core/services/shared_pref/pref_keys.dart';
import 'package:safetyZone/core/services/shared_pref/shared_pref.dart';
import 'package:safetyZone/core/utils/constants/colors.dart';
import 'package:safetyZone/core/widgets/branch_widgets.dart' as branch_widgets;
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/constants/branch_colors.dart';
import '../models/branch_data.dart';
import '../viewmodel/branch_quantities_viewmodel.dart';

class BranchQuantitiesPage extends StatelessWidget {
  final String? systemType;
  final BranchData? branchData;

  const BranchQuantitiesPage({
    super.key,
    this.systemType,
    this.branchData,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BranchQuantitiesViewModel(
        systemType: systemType,
        branchData: branchData,
      ),
      child: const BranchQuantitiesView(),
    );
  }
}

class BranchQuantitiesView extends StatelessWidget {
  const BranchQuantitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BranchQuantitiesViewModel>(context);
    final localizations = AppLocalizations.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: BranchColors.lightBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, localizations, isRTL),
            Expanded(
              child: viewModel.isLoading
                  ? const Center(
                      child: SpinKitDoubleBounce(color: CColors.primary))
                  : _buildProductList(context, viewModel, localizations, isRTL),
            ),
            _buildBottomButton(context, viewModel, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLocalizations localizations, bool isRTL) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 8.h,
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
          ),
          child: Text(
            localizations.translate('addYourBranches'),
            style: TextStyle(
              fontFamily: 'Almarai',
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              height: 22 / 24,
              letterSpacing: 0,
              color: BranchColors.primaryBlue,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 8.h,
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
          ),
          child: Text(
            localizations.translate('enterAvailableQuantities'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: isRTL ? 'Almarai' : 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList(
    BuildContext context,
    BranchQuantitiesViewModel viewModel,
    AppLocalizations localizations,
    bool isRTL,
  ) {
    final productTypes = viewModel.getUniqueProductTypes();

    return ListView.separated(
      controller: viewModel.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: productTypes.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final type = productTypes[index];
        final products =
            viewModel.products.where((p) => p.type.id == type.id).toList();
        final variants = viewModel.variantsCache[type.nameKey] ?? [];
        final isLoading = viewModel.loadingVariants[type.nameKey] == true;
        final hasLoaded = viewModel.variantsCache.containsKey(type.nameKey);

        final variantNames = _getVariantNames(isLoading, hasLoaded, variants);

        return Stack(
          children: [
            ProductGroupWidget(
              productType: type,
              products: products,
              variantNames: variantNames,
              isLoadingVariants: isLoading,
              hasLoadedVariants: hasLoaded,
              selectedVariantIndex: index,
              onDropdownOpened: () =>
                  viewModel.loadVariantsForType(type.nameKey),
              onAddMore: () => viewModel.addMoreProduct(type),
              localizations: localizations,
              isRTL: isRTL,
              onVariantChanged: (variant, prodIndex) {
                final targetProduct = products[prodIndex];
                final idx = viewModel.products.indexOf(targetProduct);
                if (idx != -1) {
                  viewModel.handleVariantSelection(
                      variant, idx, targetProduct, variants);
                }
              },
              onQuantityChanged: (quantity, prodIndex) {
                final targetProduct = products[prodIndex];
                final idx = viewModel.products.indexOf(targetProduct);
                if (idx != -1) {
                  viewModel.updateQuantity(idx, targetProduct, quantity ?? 0);
                }
              },
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                  child: const Center(
                      child: SpinKitDoubleBounce(color: CColors.primary)),
                ),
              ),
          ],
        );
      },
    );
  }

  List<String> _getVariantNames(
    bool isLoadingVariants,
    bool hasLoadedVariants,
    List<dynamic> variants,
  ) {
    if (isLoadingVariants) {
      return ['Loading...'];
    } else if (hasLoadedVariants && variants.isEmpty) {
      return ['No variants available'];
    } else if (hasLoadedVariants && variants.isNotEmpty) {
      final names = variants
          .map((item) =>
              //check lang
              (SharedPref().getString(PrefKeys.languageCode) ?? 'en') == 'en'
                  ? item.itemName.en.toString()
                  : item.itemName.ar.toString())
          .toSet()
          .toList()
          //remove item if it is null or empty
          .where((item) => item.isNotEmpty)
          .toList()
          .cast<String>();
      if (names.isEmpty) {
        return ['No variants available'];
      }
      return names;
    }
    return [];
  }

  Widget _buildBottomButton(
    BuildContext context,
    BranchQuantitiesViewModel viewModel,
    AppLocalizations localizations,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: PrimaryButton(
            text: localizations.translate('confirm'),
            onPressed: () => viewModel.submitQuantities(context),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}

class ProductGroupWidget extends StatelessWidget {
  final ProductType productType;
  final List<ProductData> products;
  final List<String> variantNames;
  final bool isLoadingVariants;
  final bool hasLoadedVariants;
  final int selectedVariantIndex;
  final void Function(String?, int)? onVariantChanged;
  final void Function(int?, int)? onQuantityChanged;
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
    required this.selectedVariantIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...products.asMap().entries.map((entry) {
          final idx = entry.key;
          final productData = entry.value;

          String? validatedSelectedVariant = _getValidatedSelectedVariant(
            productData.selectedVariant,
            variantNames,
            isLoadingVariants,
            hasLoadedVariants,
          );

          return ProductCard(
            title: localizations.translate(productType.nameKey),
            imagePath:
                entry.value.selectedVariantItem?.image ?? productType.imagePath,
            variantList: variantNames,
            selectedVariant: validatedSelectedVariant,
            quantity: productData.quantity,
            onDropdownOpened: onDropdownOpened,
            onVariantChanged: onVariantChanged,
            onQuantityChanged: onQuantityChanged,
            selectedVariantIndex: idx,
          );
        }),
        SizedBox(height: 8.h),
        branch_widgets.OutlinePlusButton(
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

/// Product card for quantity selection screen
class ProductCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<String> variantList;
  final String? selectedVariant;
  final int? quantity;
  final void Function(String?, int)? onVariantChanged;
  final void Function(int?, int)? onQuantityChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onDropdownOpened;
  int? selectedVariantIndex;

  ProductCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.variantList,
    required this.selectedVariantIndex,
    this.selectedVariant,
    this.quantity,
    this.onVariantChanged,
    this.onQuantityChanged,
    this.onAdd,
    this.onDropdownOpened,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
   print("imageeeeeeeee${widget.imagePath}");
    return Container(
      height: BranchSpacing.cardHeight.h + 15.h,
      margin: EdgeInsets.symmetric(vertical: BranchSpacing.md.h),
      decoration: BoxDecoration(
        color: BranchColors.white,
        border: Border.all(
          color: BranchColors.fieldBorder,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(BranchSpacing.borderRadius.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(BranchSpacing.md.w),
        child: Row(
          children: [
            // Left column - Title and dropdowns
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Prevent overflow
                children: [
                  // Product title
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: BranchColors.primaryRed,
                      fontFamily: isRTL ? 'Almarai' : 'Poppins',
                    ),
                    maxLines: 1, // Truncate text
                    overflow: TextOverflow.ellipsis, // Truncate text
                  ),

                  SizedBox(height: BranchSpacing.sm.h), // Variant dropdown
                  SizedBox(
                    height: 35.h,
                    child: CustomDropdownField(
                      value: widget.selectedVariant,
                      items: widget.variantList,
                      hintText: _getLocalizedText('selectVariant'),
                      onChanged: (value) {
                        if (value != null) {
                          widget.onVariantChanged
                              ?.call(value, widget.selectedVariantIndex ?? 0);
                        }
                      },
                      onTap: widget.onDropdownOpened,
                    ),
                  ),

                  SizedBox(height: BranchSpacing.sm.h),

                  // Quantity dropdown
                  SizedBox(
                    height: 32.h,
                    child: CustomDropdownField(
                      value: widget.quantity?.toString(),
                      items:
                          List.generate(50, (index) => (index + 1).toString()),
                      hintText: _getLocalizedText('selectQuantity'),
                      onChanged: (value) {
                        if (value != null) {
                          widget.onQuantityChanged?.call(int.tryParse(value),
                              widget.selectedVariantIndex ?? 0);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: BranchSpacing.md.w),

            // Right column - Product image
            Container(
              width: BranchSpacing.imageSize.w,
              height: BranchSpacing.imageSize.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: BranchColors.fieldBorder,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Image.network(
                  widget.imagePath,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                    widget.imagePath,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: BranchSpacing.imageSize.w,
                          height: BranchSpacing.imageSize.h,
                          color: Colors.grey,
                          child: Center(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedText(String key) {
    // This would normally use AppLocalizations, but for brevity we'll use static text
    switch (key) {
      case 'selectVariant':
        return 'اختر النوع';
      case 'selectQuantity':
        return 'اختر الكمية';
      default:
        return key;
    }
  }
}

/// Custom dropdown field following design specifications
class CustomDropdownField extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final ValueChanged<String?>? onChanged;
  final IconData? leadingIcon;
  final BoxDecoration? decoration;
  final TextStyle? style;
  final VoidCallback? onTap;

  const CustomDropdownField({
    super.key,
    this.value,
    required this.items,
    required this.hintText,
    this.onChanged,
    this.leadingIcon,
    this.decoration,
    this.style,
    this.onTap,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  @override
  Widget build(BuildContext context) {
    // Ensure the selected value is valid - if not, use null
    final validValue =
        (widget.value != null && widget.items.contains(widget.value))
            ? widget.value
            : null;

    // If items list is empty, show a clickable dropdown that triggers onTap
    if (widget.items.isEmpty) {
      return Container(
        height: BranchSpacing.fieldHeight.h,
        decoration: widget.decoration ??
            BoxDecoration(
              color: BranchColors.white,
              border: Border.all(
                color: BranchColors.fieldBorder,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(BranchSpacing.borderRadius.r),
            ),
        child: GestureDetector(
          onTap: () {
            widget.onTap?.call();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: BranchSpacing.md.w,
              vertical: BranchSpacing.sm.h,
            ),
            child: Row(
              children: [
                if (widget.leadingIcon != null) ...[
                  Icon(
                    widget.leadingIcon,
                    size: 24.sp,
                    color: BranchColors.primaryBlue,
                  ),
                  SizedBox(width: BranchSpacing.sm.w),
                ],
                Expanded(
                  child: Text(
                    widget.hintText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: BranchColors.textHint,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: BranchColors.textHint,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: BranchSpacing.fieldHeight.h,
      decoration: widget.decoration ??
          BoxDecoration(
            color: BranchColors.white,
            border: Border.all(
              color: BranchColors.fieldBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(BranchSpacing.borderRadius.r),
          ),
      child: GestureDetector(
        onTap: () {
          widget.onTap?.call();
        },
        child: DropdownButtonFormField<String>(
          value: validValue,
          isExpanded: true,
          alignment: Alignment.center,
          items: widget.items.map((String item) {
            // Disable selection for special state items
            final isSpecialItem =
                item == 'Loading...' || item == 'No variants available';

            return DropdownMenuItem<String>(
              value: item,
              enabled: !isSpecialItem,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  item,
                  style: widget.style?.copyWith(
                        color: isSpecialItem
                            ? Colors.grey
                            : (widget.style?.color ?? Colors.black),
                      ) ??
                      TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: isSpecialItem ? Colors.grey : Colors.black,
                      ),
                ),
              ),
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) {
            return widget.items.map<Widget>((String item) {
              return Text(
                textAlign: TextAlign.start,
                item,
                style: widget.style ??
                    TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
              );
            }).toList();
          },
          onChanged: (value) {
            // Prevent selection of special state items
            if (value != 'Loading...' && value != 'No variants available') {
              widget.onChanged?.call(value);
            }
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: (widget.style?.fontSize ?? 14.sp),
              fontWeight: FontWeight.w400,
              color: BranchColors.textHint,
              fontFamily: widget.style?.fontFamily,
            ),
            prefixIcon: widget.leadingIcon != null
                ? Icon(
                    widget.leadingIcon,
                    size: 24.sp,
                    color: BranchColors.primaryBlue,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: BranchSpacing.md.w,
              vertical: BranchSpacing.sm.h,
            ),
            isDense: true,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: BranchColors.textHint,
          ),
        ),
      ),
    );
  }
}
