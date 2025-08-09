import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/certificate_installation_cubit.dart';
import '../cubit/certificate_installation_state.dart';
import '../data/models/certificate_installation_model.dart';
import '../data/services/certificate_installation_api_service.dart';

class CertificateInstallationView extends StatefulWidget {
  const CertificateInstallationView({super.key});

  @override
  State<CertificateInstallationView> createState() =>
      _CertificateInstallationViewState();
}

class _CertificateInstallationViewState
    extends State<CertificateInstallationView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _selectedCompanyIndex;
  List<CertificateGroup> _filteredCertificateGroups = [];
  List<CertificateGroup> _allCertificateGroups = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load certificates when the widget is initialized
    context.read<CertificateInstallationCubit>().loadCertificates();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Add search listener
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _selectedCompanyIndex = null; // Reset selection when searching
    });
    _filterCertificates();
  }

  void _filterCertificates() {
    if (_searchQuery.isEmpty) {
      _filteredCertificateGroups = List.from(_allCertificateGroups);
    } else {
      _filteredCertificateGroups = _allCertificateGroups.where((group) {
        // Search in provider name (company name)
        final providerMatch = group.provider.name
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());

        // Search in branch name
        final branchMatch = group.branch.name
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());

        // Search in request numbers from certificates
        final requestMatch = group.certificates.any((cert) => cert
            .scheduleJob.requestNumber
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()));

        // Search in employee names
        final employeeMatch = group.certificates.any((cert) => cert
            .scheduleJob.responseEmployee.fullName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()));

        return providerMatch || branchMatch || requestMatch || employeeMatch;
      }).toList();
    }
  }

  void _updateCertificateData(List<CertificateGroup> newData) {
    setState(() {
      _allCertificateGroups = newData;
    });
    _filterCertificates();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<CertificateInstallationCubit>().loadMoreCertificates();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (context) =>
            CertificateInstallationCubit(CertificateInstallationApiService())
              ..loadCertificates(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7FA), // Secondary Light Blue/Gray
          body: SafeArea(
            child: Column(
              children: [
                _buildNavbar(),
                _buildSearchInput(),
                if (_searchQuery.isNotEmpty) _buildSearchSummary(),
                Expanded(child: _buildCompanyList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📌 1️⃣ Navbar Component
  Widget _buildNavbar() {
    return Container(
      height: 60.h,
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Placeholder to balance the layout
          SizedBox(width: 44.w),
          // Title centered
          Expanded(
            child: Text(
              'شهادات الرخصة الفورية',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF005CB9), // Primary Blue
                fontFamily: 'Almarai',
              ),
            ),
          ),
          // Back arrow icon (right aligned in RTL)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44.w,
              height: 44.h,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 24.sp,
                color: const Color(0xFF005CB9), // Primary Blue
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 2️⃣ Search Input Component
  Widget _buildSearchInput() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      height: 44.h,
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF1E1E1E), // Dark Text
          fontFamily: 'Almarai',
        ),
        decoration: InputDecoration(
          hintText: 'ابحث باسم الشركة او الفرع او رقم الطلب',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF9CA3AF), // Light grey
            fontFamily: 'Almarai',
          ),
          hintTextDirection: TextDirection.rtl,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 20.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedCompanyIndex = null;
                    });
                    _filterCertificates();
                  },
                )
              : Icon(
                  Icons.search,
                  size: 20.sp,
                  color: const Color(0xFF9CA3AF),
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: const Color(0xFFE5E7EB), width: 1.w),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: const Color(0xFFE5E7EB), width: 1.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: const Color(0xFF005CB9), width: 2.w),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
        ),
      ),
    );
  }

  /// 📌 Search Summary Component
  Widget _buildSearchSummary() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF005CB9).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: const Color(0xFF005CB9).withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 16.sp,
            color: const Color(0xFF005CB9),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'نتائج البحث عن "$_searchQuery": ${_filteredCertificateGroups.length} نتيجة',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF005CB9),
                fontFamily: 'Almarai',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedCompanyIndex = null;
              });
              _filterCertificates();
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: const Color(0xFF005CB9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(
                Icons.close,
                size: 14.sp,
                color: const Color(0xFF005CB9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 3️⃣ Company Cards List
  Widget _buildCompanyList() {
    return BlocBuilder<CertificateInstallationCubit,
        CertificateInstallationState>(
      builder: (context, state) {
        if (state is CertificateInstallationLoading) {
          return const Center(
            child: SpinKitDoubleBounce(color: Color(0xFF005CB9)),
          );
        }

        if (state is CertificateInstallationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: const Color(0xFFE53935),
                ),
                SizedBox(height: 16.h),
                Text(
                  'حدث خطأ في تحميل الشهادات',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF424242),
                    fontFamily: 'Almarai',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'Almarai',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<CertificateInstallationCubit>()
                        .loadCertificates();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005CB9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontFamily: 'Almarai', fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is CertificateInstallationLoaded ||
            state is CertificateInstallationRefreshing) {
          final certificateGroups = state is CertificateInstallationLoaded
              ? state.certificateGroups
              : (state as CertificateInstallationRefreshing).previousData;

          // Update data when state changes
          if (_allCertificateGroups != certificateGroups) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateCertificateData(certificateGroups);
            });
          }

          // Use filtered data for display
          final displayData = _searchQuery.isEmpty
              ? certificateGroups
              : _filteredCertificateGroups;

          if (displayData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isEmpty
                        ? Icons.description_outlined
                        : Icons.search_off,
                    size: 64.sp,
                    color: const Color(0xFFB0BEC5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _searchQuery.isEmpty
                        ? 'لا توجد شهادات متاحة'
                        : 'لا توجد نتائج للبحث عن "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF424242),
                      fontFamily: 'Almarai',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _filterCertificates();
                      },
                      child: Text(
                        'مسح البحث',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF005CB9),
                          fontFamily: 'Almarai',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context
                .read<CertificateInstallationCubit>()
                .refreshCertificates(),
            color: const Color(0xFF005CB9),
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              itemCount: displayData.length +
                  (state is CertificateInstallationLoaded &&
                          !state.hasReachedMax &&
                          _searchQuery.isEmpty
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (index >= displayData.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SpinKitDoubleBounce(
                        color: Color(0xFF005CB9),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildCompanyCard(index, displayData[index]),
                    // Add special card under the second company card (only when not searching)
                    if (index == 1 && _searchQuery.isEmpty)
                      _buildSpecialRequestCard(),
                  ],
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// 📌 4️⃣ Individual Company Card
  Widget _buildCompanyCard(int index, CertificateGroup certificateGroup) {
    final isSelected = _selectedCompanyIndex == index;

    // Extract provider and branch information
    final providerName = certificateGroup.provider.name;
    final branchName = certificateGroup.branch.name;
    final certificatesCount = certificateGroup.total;
    final firstCertificate = certificateGroup.certificates.isNotEmpty
        ? certificateGroup.certificates[0]
        : null;
    final requestNumber = firstCertificate?.scheduleJob.requestNumber ?? 'N/A';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isSelected ? const Color(0xFF005CB9) : const Color(0xFFE5E7EB),
          width: isSelected ? 2.w : 1.w,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF005CB9).withOpacity(0.1),
                  offset: Offset(0, 2.h),
                  blurRadius: 8.r,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: Offset(0, 1.h),
                  blurRadius: 3.r,
                ),
              ],
      ),
      child: Column(
        children: [
          // Company Header
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCompanyIndex = isSelected ? null : index;
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Company name
                      Expanded(
                        child: _buildHighlightedText(
                          providerName,
                          TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF005CB9), // Primary Blue
                            fontFamily: 'Almarai',
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Certificate count badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF005CB9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '$certificatesCount شهادات',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF005CB9),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Almarai',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  _buildHighlightedText(
                    branchName,
                    TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280), // Light Text
                      fontFamily: 'Almarai',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _buildHighlightedText(
                    'رقم الطلب: $requestNumber',
                    TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF9CA3AF),
                      fontFamily: 'Almarai',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Request Box (visible when selected)
          if (isSelected) _buildRequestBox(certificateGroup),
        ],
      ),
    );
  }

  /// 📌 5️⃣ Request Box Component
  Widget _buildRequestBox(CertificateGroup certificateGroup) {
    final firstCertificate = certificateGroup.certificates.isNotEmpty
        ? certificateGroup.certificates[0]
        : null;
    final requestNumber = firstCertificate?.scheduleJob.requestNumber ?? 'N/A';
    final employeeName =
        firstCertificate?.scheduleJob.responseEmployee.fullName ?? 'غير محدد';
    final certificateFile = firstCertificate?.file ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E7EB), width: 1.w),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request Type Header
          Row(
            children: [
              Text(
                'نوع الطلب:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1E1E),
                  fontFamily: 'Almarai',
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626), // Red toolbox color
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(Icons.verified, size: 12.sp, color: Colors.white),
              ),
              SizedBox(width: 8.w),
              Text(
                'شهادة تعميد',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E1E1E),
                  fontFamily: 'Almarai',
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Employee and Request Info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(
                  'المسؤول: $employeeName',
                  TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'Almarai',
                  ),
                ),
                SizedBox(height: 2.h),
                _buildHighlightedText(
                  'رقم الطلب: $requestNumber',
                  TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'Almarai',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Action Buttons Row
          Row(
            children: [
              // عرض الشهادة Button
              Expanded(
                child: _buildOutlinedButton(
                  text: 'عرض الشهادة',
                  icon: Icons.description_outlined,
                  onTap: () => _openCertificate(certificateFile),
                ),
              ),

              SizedBox(width: 8.w),

              // تحميل الشهادة Button
              Expanded(
                child: _buildOutlinedButton(
                  text: 'تحميل الشهادة',
                  icon: Icons.download_outlined,
                  onTap: () => _downloadCertificate(certificateFile),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  /// 📌 6️⃣ Special Request Card (appears under second company card)
  Widget _buildSpecialRequestCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 1.h),
            blurRadius: 3.r,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with red flag icon and title
            Row(
              children: [
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Icon(Icons.flag, size: 16.sp, color: Colors.white),
                ),
                SizedBox(width: 8.w),
                Text(
                  'إعطاب صيانة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF005CB9),
                    fontFamily: 'Almarai',
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Action Buttons Row
            Row(
              children: [
                // عرض التقارير Button (Blue outlined)
                Expanded(
                  child: Container(
                    height: 40.h,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showSnackBar('عرض التقارير', Colors.blue),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFF005CB9),
                          width: 1.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                      ),
                      icon: Icon(
                        Icons.description_outlined,
                        size: 16.sp,
                        color: const Color(0xFF005CB9),
                      ),
                      label: Text(
                        'عرض التقارير',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF005CB9),
                          fontFamily: 'Almarai',
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                // عرض التقرير Button (Blue outlined)
                Expanded(
                  child: Container(
                    height: 40.h,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showSnackBar('عرض التقرير', Colors.blue),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFF005CB9),
                          width: 1.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                      ),
                      icon: Icon(
                        Icons.visibility_outlined,
                        size: 16.sp,
                        color: const Color(0xFF005CB9),
                      ),
                      label: Text(
                        'عرض التقرير',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF005CB9),
                          fontFamily: 'Almarai',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Submit Request Button (Blue filled)
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                onPressed: () =>
                    _showSnackBar('تم تحديد الطلب بنجاح', Colors.green),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005CB9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'تحديد الطلب',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build outlined buttons
  Widget _buildOutlinedButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 40.h,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: const Color(0xFF005CB9), width: 1.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
        ),
        icon: Icon(icon, size: 16.sp, color: const Color(0xFF005CB9)),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF005CB9),
            fontFamily: 'Almarai',
          ),
        ),
      ),
    );
  }

  /// Helper method to show snack bars
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Almarai', color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  /// Helper method to open certificate file
  Future<void> _openCertificate(String fileUrl) async {
    if (fileUrl.isEmpty) {
      _showSnackBar('رابط الشهادة غير متاح', Colors.red);
      return;
    }

    try {
      final Uri url = Uri.parse(fileUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Opens in external browser/app
        );
      } else {
        _showSnackBar('لا يمكن فتح رابط الشهادة', Colors.red);
      }
    } catch (e) {
      _showSnackBar('خطأ في فتح الشهادة: ${e.toString()}', Colors.red);
    }
  }

  /// Helper method to highlight search terms in text
  Widget _buildHighlightedText(String text, TextStyle style) {
    if (_searchQuery.isEmpty) {
      return Text(text, style: style, textAlign: TextAlign.start);
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = _searchQuery.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + _searchQuery.length),
        style: style.copyWith(
          backgroundColor: const Color(0xFFFFEB3B).withOpacity(0.3),
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + _searchQuery.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.start,
    );
  }

  /// Helper method to download certificate file
  void _downloadCertificate(String fileUrl) {
    _showSnackBar('بدء تحميل الشهادة...', Colors.green);
    // Here you would typically implement file download functionality
    // using packages like dio, http, or flutter_downloader
  }
}
