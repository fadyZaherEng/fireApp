import '../models/home_service_model.dart';
import 'home_repository.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import 'dart:convert';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<List<HomeServiceModel>> getFeaturedServices() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));

    // In a real-world scenario, these would come from an API
    // and the translations would be handled server-side based on the locale
    return [
      const HomeServiceModel(
        id: '1',
        title: 'Fire Safety Services',
        titleAr: 'نقدم خدمة طفايات الحريق و تأمين الاماكن',
        image: 'assets/images/curusol.png',
        description: 'Complete fire safety and location security services',
        descriptionAr: 'خدمات شاملة لطفايات الحريق وتأمين المواقع',
        isFeatured: true,
        order: 1,
      ),
      const HomeServiceModel(
        id: '2',
        title: 'Fire Safety Services',
        titleAr: 'نقدم خدمة طفايات الحريق و تأمين الاماكن',
        image: 'assets/images/curusol.png',
        description: 'Complete fire safety and location security services',
        descriptionAr: 'خدمات شاملة لطفايات الحريق وتأمين المواقع',
        isFeatured: true,
        order: 1,
      ),
    ];
  }

  @override
  Future<List<HomeServiceModel>> getAllServices() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      const HomeServiceModel(
        id: '2',
        title: "Engineering Inspection Report",
        titleAr: "تقرير كشف هندسي على المنشآت",
        image: 'assets/images/engineerreport.png',
        order: 1,
      ),
      const HomeServiceModel(
        id: '3',
        title: "Safety Equipment Installation Certificates",
        titleAr: "شهادات تركيبات ادوات الوقاية",
        image: 'assets/images/protectioncertificate.png',
        order: 2,
      ),
      const HomeServiceModel(
        id: '4',
        title: 'Fire Extinguisher',
        titleAr: 'طفاية الحريق',
        image: 'assets/images/fireex.png',
        order: 3,
      ),
      const HomeServiceModel(
        id: '5',
        title: 'Fire Prevention Maintenance Contracts',
        titleAr: 'عقود صيانة إنذار و إطفاء حريق',
        image: 'assets/images/alarmfixcontract.png',
        order: 4,
      ),
    ];
  }

  @override
  Future<UserModel> getCurrentUser() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      // Get cached data from SharedPreferences
      final employeeJson = SharedPref().getString('user_employee');
      final companyJson = SharedPref().getString('user_company');

      String userId = '1';
      String userName = 'User';
      String userNameAr = 'مستخدم';
      String userEmail = 'user@example.com';
      String? userPhone;
      String? profileImage;

      // Parse employee data if available
      if (employeeJson != null && employeeJson.isNotEmpty) {
        try {
          final Map<String, dynamic> employeeData =
              Map<String, dynamic>.from(jsonDecode(employeeJson));

          if (employeeData.containsKey('fullName')) {
            userName = employeeData['fullName'];
            userNameAr = employeeData['fullName']; // Use same name for Arabic
          }

          if (employeeData.containsKey('image')) {
            profileImage = employeeData['image'];
          }
        } catch (e) {
          // Handle JSON parsing error silently
        }
      }

      // Parse company data if available for email
      if (companyJson != null && companyJson.isNotEmpty) {
        try {
          final Map<String, dynamic> companyData =
              Map<String, dynamic>.from(jsonDecode(companyJson));

          if (companyData.containsKey('email')) {
            userEmail = companyData['email'];
          }
        } catch (e) {
          // Handle JSON parsing error silently
        }
      }

      return UserModel(
        id: userId,
        name: userName,
        nameAr: userNameAr,
        email: userEmail,
        phone: userPhone,
        profileImage: profileImage,
      );
    } catch (e) {
      // Fallback to default user if any error occurs
      return const UserModel(
        id: '1',
        name: 'User',
        nameAr: 'مستخدم',
        email: 'user@example.com',
        phone: '+966501234567',
        profileImage: 'assets/images/profile_placeholder.png',
      );
    }
  }

  @override
  Future<void> refreshServices() async {
    // Simulate refresh operation
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
