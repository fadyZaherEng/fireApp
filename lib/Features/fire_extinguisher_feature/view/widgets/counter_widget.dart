import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_constants.dart';

class CounterWidget extends StatelessWidget {
  final int count;
  final VoidCallback onIncrease;
  final VoidCallback? onDecrease;

  const CounterWidget({
    super.key,
    required this.count,
    required this.onIncrease,
    this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onDecrease,
          child: Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: onDecrease != null
                  ? AppColors.primaryRed
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              Icons.remove,
              color: onDecrease != null ? Colors.white : Colors.grey.shade500,
              size: 16.sp,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Text(
          count.toString(),
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 16.sp,
            color: AppColors.blackTextColor,
          ),
        ),
        SizedBox(width: 16.w),
        GestureDetector(
          onTap: onIncrease,
          child: Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
        ),
      ],
    );
  }
}
