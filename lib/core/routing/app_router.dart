import 'package:flutter/material.dart';
import 'package:safetyZone/Features/splash_feature/view/splash_view.dart';
import '../../Features/add_employees_feature/view/add_employees_view.dart';
import '../../Features/auth_features/registration_feature/view/beneficiary_registration_view_refactored.dart';
import '../../Features/language_feature/view/language_selection_view.dart';
import '../../Features/onboarding_feature/view/onboarding_view.dart';
import '../../Features/auth_features/login_feature/view/login_view.dart';
import '../../Features/auth_features/login_feature/view/whatsapp_verification_view.dart';
import '../../Features/auth_features/registration_feature/view/beneficiary_registration_view.dart';
import '../../Features/bottom_navigation/view/main_app_container.dart';
import '../../Features/add_employees_feature/view/add_employees_success_view.dart';
import '../../Features/branch_management/view/branch_details_page.dart';
import '../../Features/branch_management/view/branch_quantities_page.dart';
import '../../Features/terms_and_conditions_feature/view/terms_and_conditions_page.dart';
import '../../Features/terms_and_conditions_feature/view/terms_and_conditions_success_page.dart';
import '../localization/app_localizations.dart';
import 'routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          builder: (navigatorKey) => const SplashView(),
        );
      case Routes.languageSelection:
        return MaterialPageRoute(
          builder: (_) => const LanguageSelectionView(),
        );
      case Routes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingView(),
        );
      case Routes.loginPhone:
        return MaterialPageRoute(
          builder: (_) => const LoginView(),
        );
      case Routes.whatsappVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        final phoneNumber = args?['phoneNumber'] ?? '';
        return MaterialPageRoute(
          builder: (_) => WhatsAppVerificationView(phoneNumber: phoneNumber),
        );
      case Routes.beneficiaryRegistration:
        return MaterialPageRoute(
          builder: (_) => const BeneficiaryRegistrationView(),
        );
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const MainAppContainer(),
        );
      case Routes.addEmployees:
        return MaterialPageRoute(
          builder: (_) => const AddEmployeeView(),
        );
      case Routes.addEmployeesSuccess:
        return MaterialPageRoute(
          builder: (_) => const AddEmployeesSuccessView(),
        );
      case Routes.addBranches:
      case Routes.branchDetails:
        return MaterialPageRoute(
          builder: (_) => const BranchDetailsPage(),
        );
      case Routes.branchQuantities:
        return MaterialPageRoute(
          builder: (_) => const BranchQuantitiesPage(),
        );
      case Routes.termsAndConditions:
        return MaterialPageRoute(
          builder: (_) => const TermsAndConditionsPage(),
        );
      case Routes.termsAndConditionsSuccess:
        return MaterialPageRoute(
          builder: (_) => const TermsAndConditionsSuccessPage(),
        );

      default:
        return _errorRoute();
    }
  }

  //QRCodeScannerScreen
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (navigatorKey) => Builder(builder: (context) {
        final localizations = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(localizations.translate('errorTitle'))),
          body: Center(child: Text(localizations.translate('routeNotFound'))),
        );
      }),
    );
  }
}

class NavigationService {
  // Global navigation key for whole application
  GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  /// Get app context
  BuildContext? get appContext => navigationKey.currentContext;

  /// App route observer
  RouteObserver<Route<dynamic>> routeObserver = RouteObserver<Route<dynamic>>();

  static final NavigationService _instance = NavigationService._private();
  factory NavigationService() {
    return _instance;
  }
  NavigationService._private();

  static NavigationService get instance => _instance;

  /// Pushing new page into navigation stack
  ///
  /// `routeName` is page's route name defined in [AppRoute]
  /// `args` is optional data to be sent to new page
  Future<T?> pushNamed<T extends Object>(String routeName,
      {Object? args}) async {
    print(navigationKey);
    print(navigationKey.currentState);
    return navigationKey.currentState?.pushNamed<T>(
      routeName,
      arguments: args,
    );
  }

  Future<T?> pushNamedIfNotCurrent<T extends Object>(String routeName,
      {Object? args}) async {
    if (!isCurrent(routeName)) {
      return pushNamed(routeName, args: args);
    }
    return null;
  }

  bool isCurrent(String routeName) {
    bool isCurrent = false;
    navigationKey.currentState!.popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }

  /// Pushing new page into navigation stack
  ///
  /// `route` is route generator
  Future<T?> push<T extends Object>(Route<T> route) async {
    return navigationKey.currentState?.push<T>(route);
  }

  /// Replace the current route of the navigator by pushing the given route and
  /// then disposing the previous route once the new route has finished
  /// animating in.
  Future<T?> pushReplacementNamed<T extends Object, TO extends Object>(
      String routeName,
      {Object? args}) async {
    return navigationKey.currentState?.pushReplacementNamed<T, TO>(
      routeName,
      arguments: args,
    );
  }

  /// Push the route with the given name onto the navigator, and then remove all
  /// the previous routes until the `predicate` returns true.
  Future<T?> pushNamedAndRemoveUntil<T extends Object>(
    String routeName, {
    Object? args,
    bool Function(Route<dynamic>)? predicate,
  }) async {
    return navigationKey.currentState?.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (_) => false,
      arguments: args,
    );
  }

  /// Push the given route onto the navigator, and then remove all the previous
  /// routes until the `predicate` returns true.
  Future<T?> pushAndRemoveUntil<T extends Object>(
    Route<T> route, {
    bool Function(Route<dynamic>)? predicate,
  }) async {
    return navigationKey.currentState?.pushAndRemoveUntil<T>(
      route,
      predicate ?? (_) => false,
    );
  }

  /// Consults the current route's [Route.willPop] method, and acts accordingly,
  /// potentially popping the route as a result; returns whether the pop request
  /// should be considered handled.
  Future<bool> maybePop<T extends Object>([Object? args]) async {
    return navigationKey.currentState!.maybePop<T>(args as T);
  }

  /// Whether the navigator can be popped.
  bool canPop() => navigationKey.currentState!.canPop();

  /// Pop the top-most route off the navigator.
  void goBack<T extends Object>({T? result}) {
    navigationKey.currentState?.pop<T>(result);
  }

  /// Calls [pop] repeatedly until the predicate returns true.
  void popUntil(String route) {
    navigationKey.currentState!.popUntil(ModalRoute.withName(route));
  }
}
