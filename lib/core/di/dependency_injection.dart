import 'package:get_it/get_it.dart';

import '../services/shared_pref/shared_pref.dart';
import '../config/app_config.dart';
import '../../Features/home_feature/data/services/home_api_service.dart';
import '../../Features/auth_features/login_feature/data/services/auth_api_service.dart';

final GetIt sl = GetIt.instance;

Future<void> setupInjector() async {
  await _initAppConfig();

  await _initLocalStorage();

  _initApiServices();

  _initRepositories();

  _initCubits();
}

Future<void> _initAppConfig() async {
  sl.registerSingleton<AppConfig>(AppConfig());
}

Future<void> _initLocalStorage() async {
  final sharedPref = SharedPref();
  SharedPref.init();
  sl.registerSingleton<SharedPref>(sharedPref);
}

void _initApiServices() {
  sl.registerLazySingleton<AuthApiService>(() => AuthApiService());
  sl.registerLazySingleton<HomeApiService>(() => HomeApiService());
}

void _initRepositories() {}

void _initCubits() {}
