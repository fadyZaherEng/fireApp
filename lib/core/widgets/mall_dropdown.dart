import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Features/branch_management/cubit/mall_cubit.dart';
import '../../Features/branch_management/cubit/mall_states.dart';
import '../../Features/branch_management/data/models/mall_model.dart';
import '../utils/constants/branch_colors.dart';

class MallDropdown extends StatefulWidget {
  final Mall? selectedMall;
  final ValueChanged<Mall?> onChanged;
  final String hintText;
  final TextStyle? style;

  const MallDropdown({
    super.key,
    this.selectedMall,
    required this.onChanged,
    required this.hintText,
    this.style,
  });

  @override
  State<MallDropdown> createState() => _MallDropdownState();
}

class _MallDropdownState extends State<MallDropdown> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MallCubit, MallState>(
      builder: (context, state) {
        return Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: BranchColors.white,
            border: Border.all(
              color: BranchColors.fieldBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Mall?>(
              value: _getValidSelectedMall(state),
              hint: Padding(
                padding: EdgeInsets.only(left: 12.w, right: 12.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      color: BranchColors.primaryBlue,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _getDisplayText(state),
                        style: widget.style ??
                            TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              icon: Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: state is MallLoading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            BranchColors.primaryBlue,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.keyboard_arrow_down,
                        color: BranchColors.primaryBlue,
                        size: 20.sp,
                      ),
              ),
              items: _buildDropdownItems(state),
              onChanged: state is MallLoading ? null : widget.onChanged,
              isExpanded: true,
              dropdownColor: BranchColors.white,
              menuMaxHeight: 250.h,
              itemHeight: null, // Allow dynamic height
            ),
          ),
        );
      },
    );
  }

  String _getDisplayText(MallState state) {
    final validSelectedMall = _getValidSelectedMall(state);
    if (validSelectedMall != null) {
      return validSelectedMall.name;
    }

    if (state is MallLoading) {
      return 'Loading malls...';
    }

    if (state is MallError) {
      return 'Error loading malls';
    }

    return widget.hintText;
  }

  List<DropdownMenuItem<Mall?>>? _buildDropdownItems(MallState state) {
    if (state is MallSuccess) {
      final items = <DropdownMenuItem<Mall?>>[];

      // Remove duplicates based on mall ID to ensure unique values
      final uniqueMalls = <String, Mall>{};
      for (final mall in state.malls) {
        uniqueMalls[mall.id] = mall;
      }

      // Add mall items from unique malls
      for (final mall in uniqueMalls.values) {
        items.add(
          DropdownMenuItem<Mall?>(
            value: mall,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mall.name,
                          style: widget.style ??
                              TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                fontFamily: 'Poppins',
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return items;
    }

    if (state is MallError) {
      return [
        DropdownMenuItem<Mall?>(
          value: null,
          enabled: false,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: BranchColors.primaryRed,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Failed to load malls',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: BranchColors.primaryRed,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return null;
  }

  Mall? _getValidSelectedMall(MallState state) {
    if (widget.selectedMall == null) return null;

    if (state is MallSuccess) {
      // Check if the selected mall exists in the current malls list
      final selectedMallExists =
          state.malls.any((mall) => mall.id == widget.selectedMall!.id);

      if (selectedMallExists) {
        // Return the mall from the current list to ensure object equality
        return state.malls
            .firstWhere((mall) => mall.id == widget.selectedMall!.id);
      }
    }

    // If mall doesn't exist in current list, return null to clear selection
    return null;
  }
}
