import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../data/models/certificate_models.dart';

class BranchSelector extends StatelessWidget {
  final List<Branch> branches;
  final String? selectedBranch;
  final Function(String?) onBranchChanged;
  final AppLocalizations localizations;

  const BranchSelector({
    super.key,
    required this.branches,
    required this.selectedBranch,
    required this.onBranchChanged,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedBranch?.isEmpty == true ? null : selectedBranch,
        decoration: InputDecoration(
          hintText: localizations.translate('selectBranchHint'),
          hintStyle: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          // suffixIcon: Icon(
          //   Icons.keyboard_arrow_down,
          //   color: Colors.grey.shade600,
          // ),
        ),
        isExpanded: true,
        items: branches.map((branch) {
          return DropdownMenuItem(
            value: branch.id,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                branch.branchName,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 14.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
        onChanged: onBranchChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return localizations.translate('branchRequired');
          }
          return null;
        },
      ),
    );
  }
}
