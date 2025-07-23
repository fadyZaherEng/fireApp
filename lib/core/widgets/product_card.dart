import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/constants/branch_colors.dart';
import 'branch_widgets.dart';

/// Product card for quantity selection screen
class ProductCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<String> variantList;
  final String? selectedVariant;
  final int? quantity;
  final ValueChanged<String?>? onVariantChanged;
  final ValueChanged<int?>? onQuantityChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onDropdownOpened;

  const ProductCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.variantList,
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
                      onChanged: widget.onVariantChanged,
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
                          widget.onQuantityChanged?.call(int.tryParse(value));
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
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 32.sp,
                      ),
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
