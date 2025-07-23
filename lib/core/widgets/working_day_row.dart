import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/constants/branch_colors.dart';

/// Working day row component for working hours selection
class WorkingDayRow extends StatefulWidget {
  final String dayName;
  final bool isActive;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<TimeOfDay>? onStartTimeChanged;
  final ValueChanged<TimeOfDay>? onEndTimeChanged;

  const WorkingDayRow({
    Key? key,
    required this.dayName,
    required this.isActive,
    this.startTime,
    this.endTime,
    required this.onActiveChanged,
    this.onStartTimeChanged,
    this.onEndTimeChanged,
  }) : super(key: key);

  @override
  State<WorkingDayRow> createState() => _WorkingDayRowState();
}

class _WorkingDayRowState extends State<WorkingDayRow> {
  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      height: BranchSpacing.workingDayRowHeight.h,
      margin: EdgeInsets.symmetric(vertical: BranchSpacing.sm.h),
      decoration: BoxDecoration(
        color: BranchColors.white,
        border: Border.all(
          color: BranchColors.cardBorder,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(BranchSpacing.borderRadius.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: BranchSpacing.md.w),
        child: Row(
          children: [
            // Start time picker
            GestureDetector(
              onTap: widget.isActive ? _showStartTimePicker : null,
              child: Container(
                width: 96.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color:
                      widget.isActive ? BranchColors.white : Colors.grey[100],
                  border: Border.all(
                    color: BranchColors.fieldBorder,
                    width: 1,
                  ),
                  borderRadius:
                      BorderRadius.circular(BranchSpacing.borderRadius.r),
                ),
                child: Center(
                  child: Text(
                    widget.startTime?.format(context) ?? '--:--',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: widget.isActive ? Colors.black : Colors.grey,
                      fontFamily: isRTL ? 'Almarai' : 'Poppins',
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: BranchSpacing.sm.w),

            // End time picker
            GestureDetector(
              onTap: widget.isActive ? _showEndTimePicker : null,
              child: Container(
                width: 96.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color:
                      widget.isActive ? BranchColors.white : Colors.grey[100],
                  border: Border.all(
                    color: BranchColors.fieldBorder,
                    width: 1,
                  ),
                  borderRadius:
                      BorderRadius.circular(BranchSpacing.borderRadius.r),
                ),
                child: Center(
                  child: Text(
                    widget.endTime?.format(context) ?? '--:--',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: widget.isActive ? Colors.black : Colors.grey,
                      fontFamily: isRTL ? 'Almarai' : 'Poppins',
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Day label
            Text(
              widget.dayName,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: BranchColors.primaryBlue,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
              ),
            ),

            SizedBox(width: BranchSpacing.md.w),

            // Active checkbox
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: Checkbox(
                value: widget.isActive,
                onChanged: (value) => widget.onActiveChanged(value ?? false),
                activeColor: BranchColors.primaryRed,
                checkColor: BranchColors.white,
                side: BorderSide(
                  color: BranchColors.fieldBorder,
                  width: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300.h,
          color: BranchColors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    2024,
                    1,
                    1,
                    widget.startTime?.hour ?? 9,
                    widget.startTime?.minute ?? 0,
                  ),
                  onDateTimeChanged: (DateTime dateTime) {
                    final timeOfDay = TimeOfDay(
                      hour: dateTime.hour,
                      minute: dateTime.minute,
                    );
                    widget.onStartTimeChanged?.call(timeOfDay);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEndTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300.h,
          color: BranchColors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    2024,
                    1,
                    1,
                    widget.endTime?.hour ?? 17,
                    widget.endTime?.minute ?? 0,
                  ),
                  onDateTimeChanged: (DateTime dateTime) {
                    final timeOfDay = TimeOfDay(
                      hour: dateTime.hour,
                      minute: dateTime.minute,
                    );
                    widget.onEndTimeChanged?.call(timeOfDay);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
