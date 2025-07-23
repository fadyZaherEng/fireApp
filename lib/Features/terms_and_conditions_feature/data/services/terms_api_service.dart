import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../core/services/shared_pref/pref_keys.dart';
import '../models/terms_models.dart';

class TermsAndConditionsApiService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  late final Dio _dio;

  TermsAndConditionsApiService() {
    _dio = Dio();
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add pretty dio logger
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    // Add custom logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('🚀 API Request: ${options.method} ${options.path}');
          _logger.d('📤 Request Data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('✅ API Response: ${response.statusCode}');
          _logger.d('📥 Response Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ API Error: ${error.message}');
          _logger.e('❌ Error Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  /// Create or update terms and conditions
  Future<TermsAndConditionsResponse> createTermsAndConditions(
    CreateTermsRequest request,
  ) async {
    try {
      // Get token from shared preferences
      final token = SharedPref().getString(PrefKeys.token);

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Set authorization header
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/api/consumer/terms-and-condition',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TermsAndConditionsResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create terms and conditions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException in createTermsAndConditions: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 400) {
        throw Exception(
            'Invalid terms and conditions data: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      _logger.e('Exception in createTermsAndConditions: $e');
      throw Exception('Failed to create terms and conditions: $e');
    }
  }

  /// Get employees with Contract Documentation permission
  Future<List<Employee>> getContractDocumentationEmployees({
    int limit = 10,
    int page = 1,
  }) async {
    try {
      // Get token from shared preferences
      final token = SharedPref().getString(PrefKeys.token);

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Set authorization header
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/api/consumer/employee/permission/Contract Documentation',
        queryParameters: {
          'limit': limit,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        final result = response.data['result'] as List<dynamic>? ?? [];
        return result.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch employees: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger
          .e('DioException in getContractDocumentationEmployees: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      _logger.e('Exception in getContractDocumentationEmployees: $e');
      throw Exception('Failed to fetch employees: $e');
    }
  }
}
