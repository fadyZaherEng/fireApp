import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../core/services/shared_pref/shared_pref.dart';
import '../../../core/services/shared_pref/pref_keys.dart';
import '../../auth_features/login_feature/data/models/auth_models.dart';
import '../data/services/home_api_service.dart';
import 'home_states.dart';
import 'dart:convert';

class HomeCubit extends Cubit<HomeState> {
  final HomeApiService _homeApiService;
  final Logger _logger = Logger();

  HomeCubit(this._homeApiService) : super(HomeInitial());

  Future<void> checkAuthentication() async {
    _logger.i('🔐 HomeCubit: Checking authentication with API');
    emit(HomeLoading());

    try {
      // First check if user has a token stored locally
      final token = SharedPref().getString(PrefKeys.token);
      final isAuthenticated = SharedPref().getBool(PrefKeys.isAuthenticated);

      if (token == null || !isAuthenticated) {
        _logger.w('⚠️ HomeCubit: No token found locally');
        emit(HomeNotAuthenticated());
        return;
      }

      // Make API call to check authentication status
      final response = await _homeApiService.checkAuth();

      if (response.success && response.data != null) {
        final data = response.data!;
        _logger.i('✅ HomeCubit: Authentication check successful');
        _logger.d('📊 Status: ${data.status}');
        _logger.d('� Company: ${data.companyData?.companyName}');
        _logger.d(
            '👥 Onboarding - employees: ${data.onboarding?.employees}, branches: ${data.onboarding?.branches}, terms: ${data.onboarding?.termsAndConditions}');

        // Store the updated data locally
        await _storeAuthData(data);

        emit(HomeAuthCheckSuccess(
          status: data.status,
          onboarding: data.onboarding,
          companyData: data.companyData,
        ));
      } else {
        _logger.w(
            '⚠️ HomeCubit: Authentication check failed - ${response.message}');

        // If API fails with 401, clear local auth data
        if (response.statusCode == 401) {
          await _clearAuthData();
          emit(HomeNotAuthenticated());
        } else {
          // For other errors, try to use local data as fallback
          await _checkLocalUserStatus();
        }
      }
    } catch (e) {
      _logger.e('💥 HomeCubit: Error checking authentication - $e');

      // Fallback to local data check
      await _checkLocalUserStatus();
    }
  }

  Future<void> _storeAuthData(CheckAuthResponse data) async {
    try {
      if (data.status != null) {
        await SharedPref().setString('user_status', data.status!);
      }

      if (data.onboarding != null) {
        await SharedPref().setString(
            'user_onboarding',
            jsonEncode({
              'employees': data.onboarding!.employees,
              'branches': data.onboarding!.branches,
              'termsAndConditions': data.onboarding!.termsAndConditions,
            }));
      }

      if (data.companyData != null) {
        await SharedPref().setString(
            'user_company',
            jsonEncode({
              'companyName': data.companyData!.companyName,
              'image': data.companyData!.image,
              'email': data.companyData!.email,
            }));
      }

      _logger.i('✅ Authentication data updated locally');
    } catch (e) {
      _logger.e('💥 Error storing authentication data: $e');
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await SharedPref().removePreference(PrefKeys.token);
      await SharedPref().removePreference(PrefKeys.isAuthenticated);
      await SharedPref().removePreference('user_status');
      await SharedPref().removePreference('user_onboarding');
      await SharedPref().removePreference('user_company');
      await SharedPref().removePreference('user_employee');
      _logger.i('✅ Authentication data cleared');
    } catch (e) {
      _logger.e('💥 Error clearing authentication data: $e');
    }
  }

  Future<void> _checkLocalUserStatus() async {
    _logger.i('📱 HomeCubit: Checking local user status as fallback');

    try {
      // Get stored user data from SharedPreferences
      final token = SharedPref().getString(PrefKeys.token);
      final isAuthenticated = SharedPref().getBool(PrefKeys.isAuthenticated);

      if (token == null || !isAuthenticated) {
        _logger.w('⚠️ HomeCubit: User not authenticated locally');
        emit(HomeNotAuthenticated());
        return;
      }

      // Get stored status and onboarding data
      final status = SharedPref().getString('user_status');
      final onboardingJson = SharedPref().getString('user_onboarding');
      final companyJson = SharedPref().getString('user_company');

      final employeeJson = SharedPref().getString('user_employee');

      if (status == null || onboardingJson == null) {
        _logger.w('⚠️ HomeCubit: Missing user data locally');
        emit(HomeNotAuthenticated());
        return;
      }

      final onboarding = OnboardingData.fromJson(jsonDecode(onboardingJson));
      final companyData = CompanyData.fromJson(jsonDecode(companyJson ?? '{}'));
      final employeeDetails =
          EmployeeDetails.fromJson(jsonDecode(employeeJson ?? '{}'));

      _logger.i('✅ HomeCubit: Using local data - Status: $status');
      _logger.d('🏢 Company: ${companyData.companyName}');
      _logger.d('👤 Employee: ${employeeDetails.fullName}');
      _logger.d(
          '📋 Onboarding: employees=${onboarding.employees}, branches=${onboarding.branches}, terms=${onboarding.termsAndConditions}');

      if (status == 'Complete_Register') {
        if (onboarding.employees &&
            onboarding.branches &&
            onboarding.termsAndConditions) {
          _logger.i(
              '🎉 HomeCubit: Registration complete - all onboarding done (local)');

          final featuredServices = _getFeaturedServices();
          final allServices = _getAllServices();
          final userName = employeeDetails.fullName.split(' ').first;

          emit(HomeCompleteRegistration(
            token: token,
            status: status,
            onboarding: onboarding,
            companyData: companyData,
            employeeDetails: employeeDetails,
            featuredServices: featuredServices,
            allServices: allServices,
            userName: userName,
          ));
        } else {
          _logger.i(
              '⏳ HomeCubit: Registration complete but onboarding incomplete (local)');
          emit(HomeIncompleteRegistration(
            token: token,
            status: status,
            onboarding: onboarding,
            companyData: companyData,
            employeeDetails: employeeDetails,
          ));
        }
      } else {
        _logger.i('⏳ HomeCubit: Registration incomplete (local)');
        emit(HomeIncompleteRegistration(
          token: token,
          status: status,
          onboarding: onboarding,
          companyData: companyData,
          employeeDetails: employeeDetails,
        ));
      }
    } catch (e) {
      _logger.e('💥 HomeCubit: Error checking local user status - $e');
      emit(HomeError(message: 'Failed to load user data'));
    }
  }

// UI-related methods
  void onCarouselPageChanged(int index) {
    if (state is HomeCompleteRegistration) {
      final currentState = state as HomeCompleteRegistration;
      emit(currentState.copyWith(currentCarouselIndex: index));
    }
  }

  void onServiceCardTapped(ServiceCard service) {
    // Handle service card tap
    // Navigate to specific service page or show details
    _logger.i('🔥 Service tapped: ${service.title}');
  }

  void onNotificationTapped() {
    // Handle notification bell tap
    _logger.i('🔔 Notification tapped');
  }

  void onMenuTapped() {
    // Handle hamburger menu tap
    _logger.i('📋 Menu tapped');
  }

  void onProfileTapped() {
    // Handle profile image tap
    _logger.i('👤 Profile tapped');
  }

  Future<void> loadHomeServices() async {
    if (state is HomeCompleteRegistration) {
      final currentState = state as HomeCompleteRegistration;
      try {
        // Simulate loading services
        await Future.delayed(const Duration(milliseconds: 300));

        final featuredServices = _getFeaturedServices();
        final allServices = _getAllServices();
        final userName = currentState.employeeDetails.fullName.split(' ').first;

        emit(currentState.copyWith(
          featuredServices: featuredServices,
          allServices: allServices,
          userName: userName,
        ));
      } catch (e) {
        _logger.e('💥 Error loading home services: $e');
      }
    }
  }

  List<ServiceCard> _getFeaturedServices() {
    return [
      const ServiceCard(
        title: 'نقدم خدمة طفايات الحريق و تأمين الاماكن',
        image: 'assets/images/extinguisher_icon.png',
        description: 'خدمات شاملة لطفايات الحريق وتأمين المواقع',
        isFeatured: true,
      ),
    ];
  }

  List<ServiceCard> _getAllServices() {
    return [
      const ServiceCard(
        title: 'تقرير كشف هندسي على المنشآت',
        image: 'assets/images/contract_icon.png',
      ),
      const ServiceCard(
        title: 'شهادات تركيبات ادوات الوقاية',
        image: 'assets/images/firefighter.png',
      ),
      const ServiceCard(
        title: 'طفاية الحريق',
        image: 'assets/images/extinguisher_icon.png',
      ),
      const ServiceCard(
        title: 'عقود صيانة إنذار و إطفاء حريق',
        image: 'assets/images/alarmBell.png',
      ),
    ];
  }

  Future<void> refreshUserStatus() async {
    await checkAuthentication();
  }

  Future<void> checkUserStatus() async {
    // Keep this method for backward compatibility
    await checkAuthentication();
  }
}
