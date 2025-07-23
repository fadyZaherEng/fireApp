import '../../auth_features/login_feature/data/models/auth_models.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeNotAuthenticated extends HomeState {}

class HomeAuthCheckSuccess extends HomeState {
  final String? status;
  final OnboardingData? onboarding;
  final CompanyData? companyData;

  HomeAuthCheckSuccess({
    this.status,
    this.onboarding,
    this.companyData,
  });

  bool get isCompleteRegistration => status == 'Complete_Register';

  bool get isOnboardingComplete {
    return onboarding?.employees == true &&
        onboarding?.branches == true &&
        onboarding?.termsAndConditions == true;
  }
}

class HomeCompleteRegistration extends HomeState {
  final String token;
  final String status;
  final OnboardingData onboarding;
  final CompanyData companyData;
  final EmployeeDetails employeeDetails;
  final List<ServiceCard> featuredServices;
  final List<ServiceCard> allServices;
  final int currentCarouselIndex;
  final String userName;

  HomeCompleteRegistration({
    required this.token,
    required this.status,
    required this.onboarding,
    required this.companyData,
    required this.employeeDetails,
    this.featuredServices = const [],
    this.allServices = const [],
    this.currentCarouselIndex = 0,
    this.userName = '',
  });

  HomeCompleteRegistration copyWith({
    String? token,
    String? status,
    OnboardingData? onboarding,
    CompanyData? companyData,
    EmployeeDetails? employeeDetails,
    List<ServiceCard>? featuredServices,
    List<ServiceCard>? allServices,
    int? currentCarouselIndex,
    String? userName,
  }) {
    return HomeCompleteRegistration(
      token: token ?? this.token,
      status: status ?? this.status,
      onboarding: onboarding ?? this.onboarding,
      companyData: companyData ?? this.companyData,
      employeeDetails: employeeDetails ?? this.employeeDetails,
      featuredServices: featuredServices ?? this.featuredServices,
      allServices: allServices ?? this.allServices,
      currentCarouselIndex: currentCarouselIndex ?? this.currentCarouselIndex,
      userName: userName ?? this.userName,
    );
  }
}

class HomeIncompleteRegistration extends HomeState {
  final String token;
  final String status;
  final OnboardingData onboarding;
  final CompanyData companyData;
  final EmployeeDetails employeeDetails;

  HomeIncompleteRegistration({
    required this.token,
    required this.status,
    required this.onboarding,
    required this.companyData,
    required this.employeeDetails,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});
}

// Service Card class for UI
class ServiceCard extends Equatable {
  final String title;
  final String image;
  final String? description;
  final bool isFeatured;

  const ServiceCard({
    required this.title,
    required this.image,
    this.description,
    this.isFeatured = false,
  });

  @override
  List<Object?> get props => [title, image, description, isFeatured];
}
