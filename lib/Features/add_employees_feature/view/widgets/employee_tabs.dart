import 'package:flutter/material.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';

class EmployeeTabs extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Function(int) onTabTap;

  const EmployeeTabs({
    Key? key,
    required this.count,
    required this.currentIndex,
    required this.onTabTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: count,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onTabTap(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? AppColors.primaryBlue
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${localizations.translate('employee')} ${index + 1}',
                  style: TextStyle(
                    color: currentIndex == index ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
