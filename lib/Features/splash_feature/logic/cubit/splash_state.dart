import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashNavigateToLogin extends SplashState {}

class SplashNavigateToHome extends SplashState {}

class SplashNavigateToLanguageSelection extends SplashState {}

class SplashNavigateToOnboarding extends SplashState {}

class SplashNavigateToWelcome extends SplashState {}
