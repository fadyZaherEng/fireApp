import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safetyZone/Features/add_employees_feature/view/add_employees_view.dart';
import 'package:safetyZone/Features/auth_features/login_feature/view/login_view.dart';
import 'package:safetyZone/Features/branches/branches_screen.dart';
import 'package:safetyZone/Features/engineering_inspection_report_feature/data/services/engineering_inspection_report_api_service.dart';
import 'package:safetyZone/Features/engineering_inspection_report_feature/view/engineering_inspection_report_view.dart';
import 'package:safetyZone/Features/fire_extinguisher_feature/cubit/fire_extinguisher_cubit.dart';
import 'package:safetyZone/Features/fire_extinguisher_feature/data/services/fire_extinguisher_api_service.dart';
import 'package:safetyZone/Features/fire_extinguisher_feature/view/fire_extinguisher_view.dart';
import 'package:safetyZone/Features/fire_prevention_maintenance_contract_feature/cubit/fire_prevention_maintenance_cubit.dart';
import 'package:safetyZone/Features/fire_prevention_maintenance_contract_feature/data/services/fire_prevention_maintenance_api_service.dart';
import 'package:safetyZone/Features/fire_prevention_maintenance_contract_feature/view/fire_prevention_maintenance_view.dart';
import 'package:safetyZone/Features/repair_reports/repair_reports_screen.dart';
import '../../../constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../engineering_inspection_report_feature/cubit/engineering_inspection_report_cubit.dart';
import '../cubit/home_ui_cubit.dart';
import '../cubit/home_ui_state.dart';
import '../widgets/home_header.dart';
import '../widgets/featured_service_carousel.dart';
import '../widgets/service_grid.dart';
import '../widgets/common_widgets.dart';
import '../../certificate_installation_feature/view/service_provider_selection_view.dart';
import '../../certificate_installation_feature/cubit/certificate_cubit.dart';
import '../../certificate_installation_feature/data/services/certificate_api_service.dart';
import '../../language_feature/view/language_settings_view.dart';
import '../../certificate_of_equipment_installations_feature/view/certificate_installation_view.dart';
import '../../certificate_of_equipment_installations_feature/cubit/certificate_installation_cubit.dart';
import '../../certificate_of_equipment_installations_feature/data/services/certificate_installation_api_service.dart';

class HomeContentView extends StatefulWidget {
  const HomeContentView({super.key});

  @override
  State<HomeContentView> createState() => _HomeContentViewState();
}

class _HomeContentViewState extends State<HomeContentView> {
  @override
  void didUpdateWidget(covariant HomeContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    context.read<HomeUiCubit>().loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: BlocListener<HomeUiCubit, HomeUiState>(
          listener: (context, state) {
            if (state is HomeUiNavigateToCertificateInstallation) {
              _navigateToCertificateInstallation(context);
            } else if (state is HomeUiNavigateToEngineeringInspection) {
              _navigateToEngineeringInspection(context);
            }
          },
          child: BlocBuilder<HomeUiCubit, HomeUiState>(
            builder: (context, state) {
              if (state is HomeUiLoading) {
                return const LoadingWidget();
              }

              if (state is HomeUiError) {
                return HomeErrorWidget(
                  message: state.message,
                  onRetry: () {
                    context.read<HomeUiCubit>().refreshData();
                  },
                );
              }

              if (state is HomeUiLoaded) {
                return RefreshIndicator(
                  onRefresh: () => context.read<HomeUiCubit>().refreshData(),
                  color: AppColors.primaryRed,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        HomeHeader(
                          userName: state.userName,
                          imageNetwork: state.imageNetwork,
                        ),
                        SizedBox(height: 24.h),
                        // Featured Services Carousel
                        FeaturedServiceCarousel(
                          services: state.featuredServices,
                          currentIndex: state.currentCarouselIndex,
                          onPageChanged: (index) {
                            context
                                .read<HomeUiCubit>()
                                .onCarouselPageChanged(index);
                          },
                          onServiceTapped: (service) {
                            if (service.title.contains(
                                AppLocalizations.of(context).translate(
                                    'safety_equipment_installation_certificates'))) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => CertificateCubit(
                                        CertificateApiService()),
                                    child: const ServiceProviderSelectionView(),
                                  ),
                                ),
                              );
                            } else if (service.title.contains(
                                AppLocalizations.of(context).translate(
                                    'engineering_inspection_report'))) {
                            } else {
                              context
                                  .read<HomeUiCubit>()
                                  .onServiceCardTapped(service);
                            }
                          },
                        ),

                        SizedBox(height: 32.h),

                        // Services Grid
                        ServiceGrid(
                          services: state.allServices,
                          onServiceTapped: (service) {
                            print("service title: ${service.title}");
                            if (service.title.contains(
                                    AppLocalizations.of(context).translate(
                                        'safety_equipment_installation_certificates')) ||
                                service.title
                                    .contains("شهادات تركيبات ادوات الوقاية")) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => CertificateCubit(
                                        CertificateApiService()),
                                    child: const ServiceProviderSelectionView(),
                                  ),
                                ),
                              );
                            } else if (service.title.contains(
                                AppLocalizations.of(context).translate(
                                    'engineering_inspection_report'))) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (context) =>
                                          EngineeringInspectionReportCubit(
                                              EngineeringInspectionReportApiService()),
                                      child:
                                          const EngineeringInspectionReportView(),
                                    ),
                                  ));
                            } else if (service.title.contains(
                                AppLocalizations.of(context)
                                    .translate('fire_extinguisher'))) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (context) =>
                                          FireExtinguisherCubit(
                                              FireExtinguisherApiService()),
                                      child: const FireExtinguisherView(),
                                    ),
                                  ));
                            } else if (service.title.contains(
                                AppLocalizations.of(context).translate(
                                    'fire_prevention_maintenance_contracts'))) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (context) =>
                                          FirePreventionMaintenanceCubit(
                                              FirePreventionMaintenanceApiService()),
                                      child:
                                          const FirePreventionMaintenanceView(),
                                    ),
                                  ));
                            } else {
                              context
                                  .read<HomeUiCubit>()
                                  .onServiceCardTapped(service);
                            }
                          },
                        ),

                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                );
              }

              if (state is HomeUiNavigateToCertificateInstallation) {
                // Return the previous loaded state while navigation is happening
                context.read<HomeUiCubit>().loadHomeData();
                return const LoadingWidget();
              }

              if (state is HomeUiNavigateToEngineeringInspection) {
                // Return the previous loaded state while navigation is happening
                context.read<HomeUiCubit>().loadHomeData();
                return const LoadingWidget();
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _navigateToCertificateInstallation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => CertificateCubit(CertificateApiService()),
          child: const ServiceProviderSelectionView(),
        ),
      ),
    );
  }

  void _navigateToEngineeringInspection(BuildContext context) {}

  Widget _buildDrawer(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Drawer(
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8.r),
            bottomRight: Radius.circular(8.r),
          ),
          border: Border.all(
            width: 1,
            color: const Color(0xFFE0E0E0),
          ),
        ),
        child: Column(
          children: [
            // Header with logo and title
            Container(
              height: 120.h,
              width: double.infinity,
              color: const Color(0xFFF8F9FA),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    localizations.translate('drawerCompanyName'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'saafetaalmanzel.com',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF666666),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerIconItem(
                    icon: Icons.person_outline,
                    title: localizations.translate('drawerAccountSettings'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to account settings
                    },
                  ),
                  SizedBox(height: 10.h),
                  _buildDrawerIconItem(
                    icon: Icons.verified_outlined,
                    title: localizations.translate('drawerInstantCertificates'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => CertificateInstallationCubit(
                                CertificateInstallationApiService())
                              ..loadCertificates(),
                            child: const CertificateInstallationView(),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  _buildDrawerItem(
                    icon: "assets/images/b.svg",
                    title: localizations.translate('drawerBranchesList'),
                    onTap: () {
                      // Navigator.pop(context);
                      // Navigate to branches list
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BranchesScreen(),
                          ));
                    },
                  ),
                  SizedBox(height: 10.h),
                  _buildDrawerItem(
                    icon: "assets/images/add.svg",
                    title: localizations.translate('drawerAddEmployees'),
                    onTap: () {
                      // Navigator.pop(context);
                      // Navigate to add employees
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEmployeeView(
                            isEditMode: true,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  _buildDrawerItem(
                    icon: "assets/images/reports.svg",
                    title: localizations.translate('drawerModificationReports'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to reports
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RepairReportsScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  _buildDrawerItem(
                    icon: "assets/images/m.svg",
                    title:
                        localizations.translate('drawerMaintenanceContracts'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to maintenance contracts
                    },
                  ),
                  SizedBox(height: 10.h),
                  _buildDrawerItem(
                    icon: "assets/images/visit.svg",
                    title: localizations.translate('drawerVisitReports'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to visit reports
                    },
                  ),
                  SizedBox(height: 10.h),
                  // Notifications with toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/images/zondicons_notification.svg",
                          color: const Color(0xFFE53935),
                          width: 20.w,
                          height: 20.h,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            localizations.translate('drawerNotifications'),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF333333),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Switch(
                          value: true,
                          onChanged: (value) {
                            // Handle notification toggle
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildDrawerIconItem(
                    icon: Icons.language,
                    title: localizations.translate('drawerLanguage'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSettingsView(),
                        ),
                      ).then((_) {
                        // Reload the home data to reflect language changes
                        context.read<HomeUiCubit>().loadHomeData();
                      });
                    },
                  ),
                  SizedBox(height: 10.h),
                  _buildDrawerIconItem(
                    icon: Icons.phone,
                    title: localizations.translate('drawerContactUs'),
                    onTap: () {
                      Navigator.pop(context);
                      // Open contact options
                    },
                  ),

                  SizedBox(height: 10.h),
                  _buildDrawerItem(
                    icon: "assets/images/heroicons-solid_logout.svg",
                    title: localizations.translate('drawerLogout'),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                        (route) => false,
                      );
                      // Open contact options
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: Color(0xFFE53935).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
            shape: BoxShape.rectangle,
          ),
          child: Center(
            child: SvgPicture.asset(
              icon,
              color: const Color(0xFFE53935),
              width: 20.w,
              height: 20.h,
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF333333),
            fontFamily: 'Poppins',
          ),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: 0,
        horizontalTitleGap: 16.w,
        dense: true,
      ),
    );
  }

  Widget _buildDrawerIconItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: Color(0xFFE53935).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
            shape: BoxShape.rectangle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: const Color(0xFFE53935),
              size: 20.sp,
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF333333),
            fontFamily: 'Poppins',
          ),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: 0,
        horizontalTitleGap: 16.w,
        dense: true,
      ),
    );
  }
}
