import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/home_repository.dart';
import '../data/repositories/home_repository_impl.dart';
import '../../../core/services/shared_pref/shared_pref.dart';
import '../../../core/services/shared_pref/pref_keys.dart';
import 'home_ui_state.dart';

class HomeUiCubit extends Cubit<HomeUiState> {
  final HomeRepository _repository;

  HomeUiCubit({HomeRepository? repository})
      : _repository = repository ?? HomeRepositoryImpl(),
        super(HomeUiInitial()) {
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    if (isClosed) return;
    emit(HomeUiLoading());

    try {
      final user = await _repository.getCurrentUser();
      if (isClosed) return;

      final featuredServices = await _repository.getFeaturedServices();
      if (isClosed) return;

      final allServices = await _repository.getAllServices();
      if (isClosed) return;

      // Get current language code
      final String currentLanguage =
          SharedPref().getString(PrefKeys.languageCode) ?? 'en';
      final bool isArabic = currentLanguage == 'ar';

      final featuredServiceCards = featuredServices
          .map((service) => ServiceCard(
                title: isArabic ? service.titleAr : service.title,
                image: service.image,
                description:
                    isArabic ? service.descriptionAr : service.description,
                isFeatured: service.isFeatured,
              ))
          .toList();

      final allServiceCards = allServices
          .map((service) => ServiceCard(
                title: isArabic ? service.titleAr : service.title,
                image: service.image,
                description:
                    isArabic ? service.descriptionAr : service.description,
                isFeatured: service.isFeatured,
              ))
          .toList();

      if (!isClosed) {
        emit(HomeUiLoaded(
          imageNetwork: user.profileImage!,
          featuredServices: featuredServiceCards,
          allServices: allServiceCards,
          currentCarouselIndex: 0,
          userName: isArabic ? user.nameAr : user.name,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(HomeUiError(message: e.toString()));
      }
    }
  }

  void onCarouselPageChanged(int index) {
    if (!isClosed && state is HomeUiLoaded) {
      final currentState = state as HomeUiLoaded;
      emit(currentState.copyWith(currentCarouselIndex: index));
    }
  }

  void onServiceCardTapped(ServiceCard service) {
    if (isClosed) return;

    // Handle service card tap - emit a navigation event
    if (service.title.contains('شهادات تركيبات ادوات الوقاية')) {
      emit(HomeUiNavigateToCertificateInstallation(
        serviceTitle: service.title,
      ));
    } else if (service.title.contains('تقرير كشف هندسي على المنشآت')) {
      emit(HomeUiNavigateToEngineeringInspection(
        serviceTitle: service.title,
      ));
    } else {
      // Handle other services here
      print('🔥 Service tapped: ${service.title}');
    }
  }

  void onNotificationTapped() {
    // Handle notification bell tap
  }

  void onMenuTapped() {
    // Handle hamburger menu tap
  }

  void onProfileTapped() {
    // Handle profile image tap
  }

  Future<void> refreshData() async {
    if (isClosed) return;

    try {
      await _repository.refreshServices();
      await loadHomeData();
    } catch (e) {
      if (!isClosed) {
        emit(HomeUiError(message: e.toString()));
      }
    }
  }
}
