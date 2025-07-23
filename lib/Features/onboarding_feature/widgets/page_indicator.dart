import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final Color activeColor;
  final Color inactiveColor;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.activeColor,
    this.inactiveColor = const Color(0xFFD9D9D9),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78.w,
      height: 15.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Prevent overflow
        children: List.generate(
          pageCount,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            width: index == currentPage
                ? 18.w
                : 15.w, // Make active slightly wider
            height: 15.h,
            decoration: BoxDecoration(
              // Avoid mixing shape and borderRadius
              shape: BoxShape.circle,
              color: index == currentPage ? activeColor : inactiveColor,
            ),
          ),
        ),
      ),
    );
  }
}
