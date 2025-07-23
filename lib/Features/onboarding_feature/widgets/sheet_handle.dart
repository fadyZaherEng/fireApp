import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SheetHandle extends StatelessWidget {
  const SheetHandle({
    super.key,
    this.width = 40.0,
    this.height = 4.0,
    this.color,
    this.borderRadius = 2.0,
  });

  final double width;
  final double height;
  final Color? color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: color ?? Colors.grey.shade300,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}
