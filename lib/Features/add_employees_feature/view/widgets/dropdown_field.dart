import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';

class MultiSelectDropdownField extends StatefulWidget {
  final String label;
  final List<String> selectedValues;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;

  const MultiSelectDropdownField({
    super.key,
    required this.label,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
  });

  @override
  State<MultiSelectDropdownField> createState() =>
      _MultiSelectDropdownFieldState();
}

class _MultiSelectDropdownFieldState extends State<MultiSelectDropdownField> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedValues);
  }

  void _showMultiSelectDialog() async {
    final localizations = AppLocalizations.of(context);
    List<String> tempSelected = List.from(_selectedItems);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // مهم علشان يحدث الـ UI جوة الـ Dialog
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(widget.label),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.items.map((item) {
                    return CheckboxListTile(
                      value: tempSelected.contains(item),
                      title: Text(localizations.translate(item)),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? selected) {
                        setStateDialog(() {
                          // تحديث الـ UI للـ Dialog نفسه
                          if (selected == true) {
                            tempSelected.add(item);
                          } else {
                            tempSelected.remove(item);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(localizations.translate('cancel')),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text(localizations.translate('ok')),
                  onPressed: () {
                    setState(() {
                      _selectedItems = tempSelected;
                      widget.onChanged(_selectedItems);
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.fieldLabel.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 22 / 16,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        GestureDetector(
          onTap: _showMultiSelectDialog,
          child: Container(
            width: 312,
            height: _selectedItems.length > 3 ? 60.h : 45.h,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.inputBorderColor,
                width: 1,
              ),
            ),
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              _selectedItems.isEmpty
                  ? localizations.translate('select_options')
                  : _selectedItems.map(localizations.translate).join(', '),
              style: AppTextStyles.inputText.copyWith(
                fontFamily: 'Almarai',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.5,
                letterSpacing: -0.24,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../../../constants/app_constants.dart';
// import '../../../../core/localization/app_localizations.dart';
//
// class DropdownField extends StatelessWidget {
//   final String label;
//   final String value;
//   final List<String> items;
//   final ValueChanged<String?> onChanged;
//
//   const DropdownField({
//     Key? key,
//     required this.label,
//     required this.value,
//     required this.items,
//     required this.onChanged,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Row(
//           children: [
//             Text(
//               label,
//               style: AppTextStyles.fieldLabel.copyWith(
//                 fontFamily: 'Almarai',
//                 fontWeight: FontWeight.w400,
//                 fontSize: 16,
//                 height: 22 / 16,
//                 letterSpacing: 0,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: AppSizes.paddingSmall),
//         Container(
//           width: 312,
//           height: 45.h,
//           decoration: BoxDecoration(
//             color: AppColors.cardBackground,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(
//               color: AppColors.inputBorderColor,
//               width: 1,
//             ),
//           ),
//           child: DropdownButtonFormField<String>(
//             value: value,
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.only(
//                 left: 15,
//               ),
//             ),
//             style: AppTextStyles.inputText.copyWith(
//               fontFamily: 'Almarai',
//               fontWeight: FontWeight.w400,
//               fontSize: 14,
//               height: 1.0,
//               letterSpacing: 0,
//             ),
//             icon: const Icon(
//               Icons.keyboard_arrow_down,
//               color: AppColors.primaryBlue,
//               size: AppSizes.iconSizeMedium,
//             ),
//             alignment: Alignment.center,
//             items: items.map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 alignment: Alignment.centerRight,
//                 child: Text(localizations.translate(value)),
//               );
//             }).toList(),
//             onChanged: onChanged,
//             isDense: true,
//           ),
//         ),
//       ],
//     );
//   }
// }
