import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safetyZone/Features/splash_feature/view/splash_view.dart';
import 'core/di/dependency_injection.dart';
import 'core/services/shared_pref/shared_pref.dart';
import 'core/localization/app_localizations_setup.dart';
import 'core/localization/cubit/locale_cubit.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/theme/app_theme.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPref.init();

  await setupInjector();

  HttpOverrides.global = MyHttpOverrides();

  runApp(
    BlocProvider(
      create: (context) => LocaleCubit()..getSavedLanguage(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, ChangeLocaleState>(
      builder: (context, state) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              title: 'Safety Zone Provider',
              theme: AppTheme.getTheme(state.locale.languageCode),
              home: const SplashView(),
              debugShowCheckedModeBanner: false,
              locale: state.locale,
              supportedLocales: AppLocalizationsSetup.supportedLocales,
              localizationsDelegates:
                  AppLocalizationsSetup.localizationsDelegates,
              localeResolutionCallback:
                  AppLocalizationsSetup.localeResolutionCallback,
              initialRoute: Routes.splash,
              onGenerateRoute: AppRouter.generateRoute,
              navigatorKey: NavigationService.instance.navigationKey,
            );
          },
        );
      },
    );
  }
}

// For development only - bypasses SSL certificate validation
// Comment this out for production
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
