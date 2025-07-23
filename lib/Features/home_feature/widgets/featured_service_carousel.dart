import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_constants.dart';
import '../cubit/home_ui_state.dart';

class FeaturedServiceCarousel extends StatelessWidget {
  final List<ServiceCard> services;
  final int currentIndex;
  final Function(int) onPageChanged;
  final Function(ServiceCard) onServiceTapped;

  const FeaturedServiceCarousel({
    super.key,
    required this.services,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onServiceTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel
        Container(
          height: 141.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: PageView.builder(
            onPageChanged: onPageChanged,
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return GestureDetector(
                onTap: () => onServiceTapped(service),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFFBA2D2D),
                        Color(0xFF8B1E1E),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background Pattern (optional)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Row(
                          children: [
                            // Image
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 120.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Image.asset(
                                  service.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Icon(
                                        Icons.fire_extinguisher,
                                        size: 60.r,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            SizedBox(width: 20.w),

                            // Text
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    service.title,
                                    style: TextStyle(
                                      fontFamily: 'Almarai',
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 16.sp,
                                      height:
                                          24 / 16, // line-height / font-size
                                      letterSpacing: 0,
                                      color: const Color.fromARGB(
                                          255, 242, 172, 172),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16.h),

        // Progress Text and Indicators
        if (services.length > 1) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              services.length,
              (index) => Container(
                width: 8.r,
                height: 8.r,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == currentIndex
                      ? AppColors.primaryRed
                      : AppColors.primaryRed.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
