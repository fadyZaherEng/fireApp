import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/routing/routes.dart';

class TermsAndConditionsSuccessPage extends StatelessWidget {
  const TermsAndConditionsSuccessPage({super.key});
  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xFFE9EFF6),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Icon
              _buildSuccessIcon(),

              SizedBox(height: 16.h),

              // Success Title
              _buildSuccessTitle(isRTL),

              SizedBox(height: 8.h),

              // Success Body Text
              _buildSuccessBody(isRTL),

              const Spacer(),

              // Action Button
              _buildActionButton(context, isRTL),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: 60.sp,
      ),
    );
  }

  Widget _buildSuccessTitle(bool isRTL) {
    return Text(
      'تهانينا! لقد انتهيت من كل الخطوات',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF003366),
        fontFamily: 'Almarai',
      ),
    );
  }

  Widget _buildSuccessBody(bool isRTL) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text(
        'تم اكتمال خطوات التسجيل بنجاح. يمكنك الآن رفع طلبك والبدء في استخدام التطبيق.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF333333),
          fontFamily: 'Almarai',
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isRTL) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 48.h,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC62828),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'رفع طلبك',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Almarai',
          ),
        ),
      ),
    );
  }
}
