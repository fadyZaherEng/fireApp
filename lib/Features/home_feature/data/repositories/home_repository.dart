import '../models/home_service_model.dart';

abstract class HomeRepository {
  Future<List<HomeServiceModel>> getFeaturedServices();
  Future<List<HomeServiceModel>> getAllServices();
  Future<UserModel> getCurrentUser();
  Future<void> refreshServices();
}
