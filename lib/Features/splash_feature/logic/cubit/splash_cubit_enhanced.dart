import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:safetyZone/core/services/shared_pref/pref_keys.dart';
import 'package:safetyZone/core/services/shared_pref/shared_pref.dart';

import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final Logger _logger = Logger();

  SplashCubit() : super(SplashInitial());

  Future<void> navigateToLogin() async {
    _logger.i('🚀 SplashCubit: Starting navigation logic');

    await Future.delayed(const Duration(seconds: 2));

    try {
      // Check if user has selected language
      final isLanguageSelected =
          SharedPref().getBool(PrefKeys.isLanguageSelected);

      if (!isLanguageSelected) {
        _logger.i(
            '🌐 SplashCubit: Language not selected, navigating to language selection');
        emit(SplashNavigateToLanguageSelection());
        return;
      }

      // Check if user is authenticated
      final token = SharedPref().getString(PrefKeys.token);
      final isAuthenticated = SharedPref().getBool(PrefKeys.isAuthenticated);

      if (token != null && isAuthenticated) {
        _logger.i('✅ SplashCubit: User authenticated, navigating to home');
        emit(SplashNavigateToHome());
        return;
      }

      // Check if onboarding is complete
      final isOnboardingComplete =
          SharedPref().getBool(PrefKeys.isOnboardingComplete);

      if (!isOnboardingComplete) {
        _logger.i(
            '📖 SplashCubit: Onboarding not complete, navigating to onboarding');
        emit(SplashNavigateToOnboarding());
        return;
      }

      // Default: navigate to login
      _logger.i('🔑 SplashCubit: Navigating to login');
      emit(SplashNavigateToLogin());
    } catch (e) {
      _logger.e('💥 SplashCubit: Error in navigation logic - $e');
      // Default fallback
      emit(SplashNavigateToLogin());
    }
  }
}
