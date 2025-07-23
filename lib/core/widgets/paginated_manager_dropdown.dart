import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import '../../Features/branch_management/cubit/manager_cubit.dart';
import '../../Features/branch_management/cubit/manager_states.dart';
import '../../Features/branch_management/data/models/manager_models.dart';
import '../utils/constants/branch_colors.dart';

class PaginatedManagerDropdown extends StatefulWidget {
  final Manager? selectedManager;
  final ValueChanged<Manager?> onChanged;
  final String hintText;
  final TextStyle? style;

  const PaginatedManagerDropdown({
    super.key,
    this.selectedManager,
    required this.onChanged,
    required this.hintText,
    this.style,
  });

  @override
  State<PaginatedManagerDropdown> createState() =>
      _PaginatedManagerDropdownState();
}

class _PaginatedManagerDropdownState extends State<PaginatedManagerDropdown> {
  final ScrollController _scrollController = ScrollController();
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near the bottom
      context.read<ManagerCubit>().loadMoreManagers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManagerCubit, ManagerState>(
      builder: (context, state) {
        return Container(
          height: BranchSpacing.fieldHeight.h,
          decoration: BoxDecoration(
            color: BranchColors.white,
            border: Border.all(
              color: BranchColors.fieldBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(BranchSpacing.borderRadius.r),
          ),
          child: DropdownButtonFormField<Manager>(
            value: widget.selectedManager,
            isExpanded: true,
            alignment: Alignment.center,
            items: _buildDropdownItems(state),
            selectedItemBuilder: (BuildContext context) {
              return _buildSelectedItems(state);
            },
            onChanged: widget.onChanged,
            onTap: () {
              _logger
                  .i('🎯 Dropdown tapped! Current state: ${state.runtimeType}');
              // Always load managers when dropdown is opened
              if (state is ManagerInitial || state is ManagerError) {
                _logger.i('🔄 Loading managers...');
                context.read<ManagerCubit>().loadManagers();
              } else if (state is ManagerLoaded && state.managers.isEmpty) {
                _logger.i('🔄 Managers list is empty, refreshing...');
                context.read<ManagerCubit>().refreshManagers();
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
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: BranchSpacing.md.w,
                vertical: BranchSpacing.sm.h,
              ),
            ),
            dropdownColor: BranchColors.white,
            menuMaxHeight: 300.h,
          ),
        );
      },
    );
  }

  List<DropdownMenuItem<Manager>> _buildDropdownItems(ManagerState state) {
    List<DropdownMenuItem<Manager>> items = [];

    _logger.i('🔍 Building dropdown items for state: ${state.runtimeType}');

    if (state is ManagerLoaded) {
      _logger.i('📋 Managers loaded: ${state.managers.length} items');
      // Add manager items
      items.addAll(
        state.managers.map((Manager manager) {
          _logger.d('👤 Adding manager: ${manager.fullName}');
          return DropdownMenuItem<Manager>(
            value: manager,
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                manager.fullName,
                style: widget.style ??
                    TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
      );

      // If no managers found, show a message
      if (state.managers.isEmpty) {
        items.add(
          DropdownMenuItem<Manager>(
            enabled: false,
            value: null,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'No managers found',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        );
      } // Since the API doesn't support real pagination, we'll remove the load more functionality
      // Add loading indicator if loading more (keeping for compatibility)
      if (state.isLoadingMore) {
        items.add(
          DropdownMenuItem<Manager>(
            enabled: false,
            value: null,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        BranchColors.primaryBlue,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Loading more...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: BranchColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Remove "Load More" option since API doesn't support pagination
      // if (state.hasNextPage && !state.isLoadingMore) { ... }
    } else if (state is ManagerLoading) {
      _logger.i('⏳ Loading managers...');
      // Show loading indicator
      items.add(
        DropdownMenuItem<Manager>(
          enabled: false,
          value: null,
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      BranchColors.primaryBlue,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Loading managers...',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: BranchColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (state is ManagerError) {
      _logger.e('❌ Error loading managers: ${state.error}');
      // Show error and retry option
      items.add(
        DropdownMenuItem<Manager>(
          enabled: false,
          value: null,
          child: InkWell(
            onTap: () {
              print('🔄 Retrying to load managers...');
              context.read<ManagerCubit>().refreshManagers();
            },
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: BranchColors.primaryRed,
                    size: 16.sp,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Failed to load managers',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: BranchColors.primaryRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Tap to retry',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: BranchColors.primaryRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      print('🤔 Unknown state: ${state.runtimeType}');
      // Default state
      items.add(
        DropdownMenuItem<Manager>(
          enabled: false,
          value: null,
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              'Tap to load managers',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return items;
  }

  List<Widget> _buildSelectedItems(ManagerState state) {
    if (state is ManagerLoaded) {
      return state.managers.map<Widget>((Manager manager) {
        return Text(
          manager.fullName,
          style: widget.style ??
              TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
        );
      }).toList();
    }

    return [
      Text(
        widget.hintText,
        style: widget.style ??
            TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: BranchColors.textHint,
            ),
      ),
    ];
  }
}
