import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServiceScreen extends StatelessWidget {
  final String iconPath;
  final String title;
  final String description;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onButtonPressed;

  const ServiceScreen({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonColor,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            // Top icon
            SizedBox(height: 40.h),
            Image.asset(
              iconPath,
              width: 100.w,
              height: 100.h,
              fit: BoxFit.contain,
            ),

            // Title
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E1E1E),
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),

            // Description
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF444444),
                  height: 1.5,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Action button
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
