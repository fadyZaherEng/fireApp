import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/app_localizations.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final bool isRTL;
  final bool canNavigate;

  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.isRTL,
    this.canNavigate = true,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: localizations.translate('home'),
            index: 0,
            context: context,
          ),
          _buildNavItem(
            icon: Icons.inbox,
            label: localizations.translate('receiveOffers'),
            index: 1,
            context: context,
          ),
          _buildNavItem(
            icon: Icons.build,
            label: localizations.translate('maintenanceSchedule'),
            index: 2,
            context: context,
          ),
          _buildNavItem(
            icon: Icons.folder,
            label: localizations.translate('inProgress'),
            index: 3,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = selectedIndex == index;
    final color =
        isSelected ? const Color(0xFFB60000) : const Color(0xFF9B9B9B);
    final isDisabled = !canNavigate && index != 2;

    return GestureDetector(
      onTap: () {
        onTap(index);
      },
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: color,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
