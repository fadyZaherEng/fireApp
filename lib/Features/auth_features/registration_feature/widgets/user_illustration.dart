import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserIllustration extends StatelessWidget {
  const UserIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90.w,
      height: 90.h,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/user_illustration.png',
            width: 90.w,
            height: 90.h,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
