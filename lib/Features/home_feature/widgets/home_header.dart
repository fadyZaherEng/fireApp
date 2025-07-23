import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../cubit/home_ui_cubit.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String imageNetwork;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.imageNetwork,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // Hamburger Menu
          GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              padding: EdgeInsets.all(8.r),
              child: Icon(
                Icons.menu,
                color: AppColors.primaryBlue,
                size: 24.r,
              ),
            ),
          ),

          // Notification Bell
          GestureDetector(
            onTap: () {
              context.read<HomeUiCubit>().onNotificationTapped();
            },
            child: Container(
              padding: EdgeInsets.all(8.r),
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.primaryBlue,
                size: 24.r,
              ),
            ),
          ),

          const Spacer(),

          // Welcome Message
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context)
                    .translate('welcome_message')
                    .replaceAll('{userName}', userName),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.primaryTextColor,
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.rtl,
              ),
              Text(
                'Safety Zone',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.primaryBlue,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(width: 12.w),

          // Profile Image
          GestureDetector(
            onTap: () {
              context.read<HomeUiCubit>().onProfileTapped();
            },
            child: Container(
              width: 45.r,
              height: 45.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Image.network(
                imageNetwork,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primaryBlue,
                      size: 24.r,
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
