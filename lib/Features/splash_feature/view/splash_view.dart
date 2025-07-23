import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/constants/image_strings.dart';
import '../../../../core/utils/helpers/helper_functions.dart';
import '../logic/cubit/splash_cubit.dart';
import '../logic/cubit/splash_state.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return BlocProvider(
      create: (context) => SplashCubit()..navigateToLogin(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          // Handle different navigation states
          if (state is SplashNavigateToHome) {
            Navigator.pushReplacementNamed(context, Routes.home);
          } else if (state is SplashNavigateToLanguageSelection) {
            Navigator.pushReplacementNamed(context, Routes.languageSelection);
          } else if (state is SplashNavigateToOnboarding) {
            Navigator.pushReplacementNamed(context, Routes.onboarding);
          } else if (state is SplashNavigateToLogin) {
            Navigator.pushReplacementNamed(context, Routes.loginPhone);
          }
        },
        child: Scaffold(
          body: Container(
            width: 1.sw, // Full screen width
            height: 1.sh, // Full screen height
            decoration: BoxDecoration(
                color: dark ? CColors.darkContainer : CColors.lightContainer),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    TImages.splash,
                    fit: BoxFit.cover, // Cover the entire area
                    width: 1.sw, // Full screen width
                    height: 1.sh, // Full screen height
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
