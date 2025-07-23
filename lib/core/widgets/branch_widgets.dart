import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/constants/branch_colors.dart';

/// Labeled field wrapper with consistent styling
class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final IconData? icon;
  final int flex;

  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.icon,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20.sp,
                color: BranchColors.primaryRed,
              ),
              SizedBox(width: BranchSpacing.sm.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: BranchColors.primaryBlue,
              ),
            ),
          ],
        ),
        SizedBox(height: BranchSpacing.sm.h),
        child,
      ],
    );
  }
}

/// Primary red button following design specifications
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final double? width;
  final double? height;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: width ?? double.infinity,
      height: height ?? BranchSpacing.buttonHeight.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BranchSpacing.borderRadius.r),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: BranchColors.shadow.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? BranchColors.primaryRed : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BranchSpacing.borderRadius.r),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: BranchColors.white,
            fontFamily: isRTL ? 'Almarai' : 'Poppins',
          ),
        ),
      ),
    );
  }
}

/// Outline plus button for adding items
class OutlinePlusButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const OutlinePlusButton({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      height: BranchSpacing.addButtonHeight.h,
      constraints: BoxConstraints(
        minWidth: BranchSpacing.addButtonMinWidth.w,
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: BranchColors.primaryRed,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(BranchSpacing.addButtonBorderRadius.r),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 14.sp,
              color: BranchColors.primaryRed,
            ),
            SizedBox(width: BranchSpacing.xs.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: BranchColors.primaryRed,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom app bar following design specifications
class BranchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const BranchAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      height: BranchSpacing.appBarHeight.h,
      decoration: const BoxDecoration(
        color: BranchColors.veryLightBlue,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: BranchSpacing.sm.w),
          child: Row(
            children: [
              if (showBackButton) ...[
                IconButton(
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  icon: Icon(
                    isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                    size: 24.sp,
                    color: BranchColors.primaryBlue,
                  ),
                ),
              ] else ...[
                SizedBox(width: BranchSpacing.sm.w),
              ],
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: BranchColors.primaryBlue,
                    letterSpacing: 0.1,
                    fontFamily: isRTL ? 'Almarai' : 'Poppins',
                  ),
                ),
              ),
              SizedBox(width: BranchSpacing.sm.w),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(BranchSpacing.appBarHeight.h);
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
    Key? key,
    this.value,
    required this.items,
    required this.hintText,
    this.onChanged,
    this.leadingIcon,
    this.decoration,
    this.style,
    this.onTap,
  }) : super(key: key);

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

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? leadingIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final String? initialValue;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.leadingIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.initialValue,
  }) : assert(controller == null || initialValue == null,
            'Cannot provide both a controller and an initialValue');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: BranchSpacing.fieldHeight.h,
      decoration: BoxDecoration(
        color: enabled ? BranchColors.white : Colors.grey.shade100,
        border: Border.all(
          color: BranchColors.fieldBorder,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(BranchSpacing.borderRadius.r),
      ),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        validator: validator,
        onChanged: onChanged,
        enabled: enabled,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: enabled ? Colors.black : Colors.grey,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: BranchColors.textHint,
          ),
          prefixIcon: leadingIcon != null
              ? Icon(
                  leadingIcon,
                  size: 24.sp,
                  color: enabled ? BranchColors.primaryBlue : Colors.grey,
                )
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: BranchSpacing.md.w,
            vertical: BranchSpacing.sm.h,
          ),
          filled: !enabled,
          fillColor: !enabled ? Colors.grey.shade100 : null,
        ),
      ),
    );
  }
}
