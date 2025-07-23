import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/localization/app_localizations_setup.dart';
import 'core/localization/cubit/locale_cubit.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/utils/theme/cubit/theme_cubit.dart';
import 'core/utils/theme/theme.dart';

class SafetyZone extends StatelessWidget {
  const SafetyZone({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocaleCubit()..getSavedLanguage(),
      child: BlocProvider(
        create: (context) => ThemeCubit(),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (BuildContext context, Widget? child) {
            return BlocBuilder<LocaleCubit, ChangeLocaleState>(
              builder: (context, localeState) {
                return BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeState) {
                    return MaterialApp(
                        navigatorKey: NavigationService.instance.navigationKey,
                        locale: localeState.locale,
                        supportedLocales:
                            AppLocalizationsSetup.supportedLocales,
                        localizationsDelegates: [
                          ...AppLocalizationsSetup.localizationsDelegates,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        localeResolutionCallback:
                            AppLocalizationsSetup.localeResolutionCallback,
                        title: "Safety Zone",
                        themeMode: themeState,
                        theme: TAppTheme.lightTheme,
                        darkTheme: TAppTheme.darkTheme,
                        debugShowCheckedModeBanner: false,
                        initialRoute: Routes.splash,
                        onGenerateRoute: (settings) =>
                            AppRouter.generateRoute(settings));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
