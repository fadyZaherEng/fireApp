import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetyZone/core/utils/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../home_feature/cubit/home_cubit.dart';
import '../../home_feature/cubit/home_states.dart';
import 'package:table_calendar/table_calendar.dart';

class MaintenanceScheduleView extends StatelessWidget {
  const MaintenanceScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final localizations = AppLocalizations.of(context);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeAuthCheckSuccess &&
            state.status == "Complete_Register" &&
            !state.isOnboardingComplete) {
          return _buildBlockingScreen(localizations, isRTL, state, context);
        }

        return SimpleMaintenancePage();
      },
    );
  }

  Widget _buildBlockingScreen(AppLocalizations localizations, bool isRTL,
      HomeAuthCheckSuccess state, BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFEDF2FA),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                margin: EdgeInsets.only(bottom: 24.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE6F4),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Sad emoji
                    Image.asset(
                      'assets/images/sad_emoji.png',
                      width: 69.w,
                      height: 69.h,
                    ),
                    SizedBox(height: 12.h),
                    // Warning text
                    Text(
                      localizations.translate('cannotReceiveRequestsMessage'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF444444),
                        fontWeight: FontWeight.w500,
                        fontFamily: isRTL ? 'Almarai' : 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Action buttons based on onboarding status
              _buildActionButtons(state, isRTL, localizations, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(HomeAuthCheckSuccess state, bool isRTL,
      AppLocalizations localizations, BuildContext context) {
    List<Widget> buttons = [];

    // Add employees button if not completed
    buttons.add(_buildActionButton(
      text: localizations.translate('addEmployees'),
      onPressed: () => _navigateToAddEmployees(context),
      isRTL: isRTL,
    ));

    // Add branches button if not completed

    buttons.add(_buildActionButton(
      text: localizations.translate('addBranches'),
      onPressed: () => _navigateToAddBranches(context),
      isRTL: isRTL,
    ));

    buttons.add(_buildActionButton(
      text: localizations.translate('termsAndConditions'),
      onPressed: () => _navigateToTermsAndConditions(context),
      isRTL: isRTL,
    ));

    return Column(
      children: buttons
          .map((button) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: button,
              ))
          .toList(),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required bool isRTL,
  }) {
    return SizedBox(
      width: 240.w,
      height: 44.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFFB60000),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: Color(0xFFB60000).withOpacity(0.1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB60000),
            fontFamily: isRTL ? 'Almarai' : 'Poppins',
          ),
        ),
      ),
    );
  }

  void _navigateToAddEmployees(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.addEmployees);
  }

  void _navigateToAddBranches(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.branchDetails);
  }

  void _navigateToTermsAndConditions(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.termsAndConditions);
  }
}

class SimpleMaintenancePage extends StatefulWidget {
  const SimpleMaintenancePage({super.key});

  @override
  State<SimpleMaintenancePage> createState() => _SimpleMaintenancePageState();
}

class _SimpleMaintenancePageState extends State<SimpleMaintenancePage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.translate("maintenanceTitle"),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CColors.secondary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: t.translate("searchHint"),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card Example
            _buildMaintenanceCard(
              context,
              companyName: t.translate("company1"),
              branchInfo: t.translate("branchInfo"),
              address: "شارع عبد العزيز - المملكة العربية السعودية",
              visitDate: "22/06/2025",
              visitNumber: "2",
            ),
            const SizedBox(height: 10),
            _simpleCard(t.translate("company2"), t.translate("branchInfo")),
            const SizedBox(height: 10),
            _simpleCard(t.translate("company3"), t.translate("branchInfo")),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceCard(
    BuildContext context, {
    required String companyName,
    required String branchInfo,
    required String address,
    required String visitDate,
    required String visitNumber,
  }) {
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            companyName,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: CColors.secondary),
          ),
          const SizedBox(height: 4),
          Text(branchInfo,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: CColors.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(address)),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text("${t.translate("visitNumber")}: ",
                          style: const TextStyle(color: CColors.secondary)),
                      Text(visitNumber,
                          style: const TextStyle(color: CColors.black)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("${t.translate("visitDate")}: ",
                          style: const TextStyle(color: CColors.secondary)),
                      Text(visitDate,
                          style: const TextStyle(color: CColors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CColors.primary,
                minimumSize: const Size(double.infinity, 40),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VisitDateScreen(),
                  ),
                );
              },
              child: Text(t.translate("rescheduleButton"),
                  style: const TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _simpleCard(String companyName, String branchInfo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(companyName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: CColors.secondary)),
          const SizedBox(height: 4),
          Text(branchInfo,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class VisitDateScreen extends StatefulWidget {
  const VisitDateScreen({super.key});

  @override
  State<VisitDateScreen> createState() => _VisitDateScreenState();
}

class _VisitDateScreenState extends State<VisitDateScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate("selectVisitDate"),
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              // color: Colors.white,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  availableGestures: AvailableGestures.all,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: CColors.secondary.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: CColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.black),
                    weekdayStyle: TextStyle(color: Colors.black),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: handle save/send logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SuccessScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).translate("saveAndSend"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/success.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(context)
                    .translate('providerWillBeContacted'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
