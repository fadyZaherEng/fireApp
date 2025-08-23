import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CountryData {
  final String nameKey;
  final String nameEn;
  final String nameAr;
  final String code;
  final String flag;
  final String isoCode;

  const CountryData({
    required this.nameKey,
    required this.nameEn,
    required this.nameAr,
    required this.code,
    required this.flag,
    required this.isoCode,
  });
}

class PhoneInputField extends StatefulWidget {
  final TextEditingController phoneController;
  final String selectedCountryCode;
  final String selectedCountryname;
  final Function(String) onCountryCodeChanged;
  final String? hint;

  const PhoneInputField({
    super.key,
    required this.phoneController,
    required this.selectedCountryCode,
    required this.selectedCountryname,
    required this.onCountryCodeChanged,
    this.hint,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  static const List<CountryData> countries = [
    CountryData(
        nameKey: 'saudiArabia',
        nameEn: 'Saudi Arabia',
        nameAr: 'السعودية',
        code: '+966',
        flag: '🇸🇦',
        isoCode: 'sa'),
  ];

  late CountryData selectedCountry;

  @override
  void initState() {
    super.initState();
    selectedCountry = countries.firstWhere(
      (country) => country.code == widget.selectedCountryCode,
      orElse: () => countries.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 320.w,
      height: 46.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFF1C4587),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Phone number input
          Expanded(
            child: TextField(
              controller: widget.phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                hintText: widget.hint ?? 'XXXXXXXXXX',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF888888),
                  fontFamily: 'Poppins',
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // Country flag and code section
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCountry.code,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: const Color(0xFF888888),
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),

          // Vertical divider
          Container(
            width: 1.w,
            height: 24.h,
            color: const Color(0xFFE0E0E0),
          ),

          // Country flag
          Container(
            width: 24.w,
            height: 16.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.r),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.r),
              child: Image.network(
                'https://flagcdn.com/w40/${selectedCountry.isoCode}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF5F5F5),
                    child: Center(
                      child: Text(
                        selectedCountry.flag,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFFF5F5F5),
                    child: Center(
                      child: SizedBox(
                        width: 12.w,
                        height: 12.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF1C4587),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // WhatsApp icon
          Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: SvgPicture.asset(
                'assets/icons/whatsapp.svg',
                width: 24.w,
                height: 24.h,
              )),
        ],
      ),
    );
  }
}
