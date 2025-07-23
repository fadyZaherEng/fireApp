import 'package:equatable/equatable.dart';

abstract class HomeUiState extends Equatable {
  const HomeUiState();

  @override
  List<Object?> get props => [];
}

class HomeUiInitial extends HomeUiState {}

class HomeUiLoading extends HomeUiState {}

class HomeUiLoaded extends HomeUiState {
  final List<ServiceCard> featuredServices;
  final List<ServiceCard> allServices;
  final int currentCarouselIndex;
  final String userName;
  final String imageNetwork;

  const HomeUiLoaded({
    required this.featuredServices,
    required this.allServices,
    required this.currentCarouselIndex,
    required this.userName,
    required this.imageNetwork,
  });

  @override
  List<Object?> get props => [
        imageNetwork,
        featuredServices,
        allServices,
        currentCarouselIndex,
        userName,
      ];

  HomeUiLoaded copyWith({
    List<ServiceCard>? featuredServices,
    List<ServiceCard>? allServices,
    int? currentCarouselIndex,
    String? userName,
  }) {
    return HomeUiLoaded(
      featuredServices: featuredServices ?? this.featuredServices,
      allServices: allServices ?? this.allServices,
      currentCarouselIndex: currentCarouselIndex ?? this.currentCarouselIndex,
      userName: userName ?? this.userName,
      imageNetwork: imageNetwork,
    );
  }
}

class HomeUiError extends HomeUiState {
  final String message;

  const HomeUiError({required this.message});

  @override
  List<Object?> get props => [message];
}

class HomeUiNavigateToCertificateInstallation extends HomeUiState {
  final String serviceTitle;

  const HomeUiNavigateToCertificateInstallation({
    required this.serviceTitle,
  });

  @override
  List<Object?> get props => [serviceTitle];
}

class HomeUiNavigateToEngineeringInspection extends HomeUiState {
  final String serviceTitle;

  const HomeUiNavigateToEngineeringInspection({
    required this.serviceTitle,
  });

  @override
  List<Object?> get props => [serviceTitle];
}

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
