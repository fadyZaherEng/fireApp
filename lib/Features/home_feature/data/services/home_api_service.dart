import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:safetyZone/core/config/app_config.dart';
import '../../../auth_features/login_feature/data/models/auth_models.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../core/services/shared_pref/pref_keys.dart';

class HomeApiService {
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

  HomeApiService() {
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
          _logger.d('📤 Request Headers: ${options.headers}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i(
              '✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          _logger.d('📥 Response Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ API Error: ${error.requestOptions.path}');
          _logger.e('💥 Error Details: ${error.message}');
          if (error.response != null) {
            _logger.e('📥 Error Response: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<ApiResponse<CheckAuthResponse>> checkAuth() async {
    try {
      // Get the stored token
      final token = SharedPref().getString(PrefKeys.token);

      if (token == null) {
        _logger.w('⚠️ No token found for authentication check');
        return ApiResponse(
          success: false,
          message: 'No authentication token found',
          statusCode: 401,
        );
      }

      _logger.i('🔐 Checking authentication status');

      final response = await _dio.get(
        '/api/consumer/authentication/check-auth',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final checkAuthResponse = CheckAuthResponse.fromJson(response.data);
        _logger.i('✅ Authentication check successful');
        _logger.d('📊 Status: ${checkAuthResponse.status}');
        _logger.d('🏢 Company: ${checkAuthResponse.companyData?.companyName}');

        return ApiResponse(
          success: true,
          message: 'Authentication check successful',
          data: checkAuthResponse,
          statusCode: response.statusCode,
        );
      } else {
        _logger.w(
            '⚠️ Authentication check failed with status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Authentication check failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('💥 Dio Exception in checkAuth: ${e.message}');
      return _handleDioException(e);
    } catch (e) {
      _logger.e('💥 Unexpected error in checkAuth: $e');
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  ApiResponse<CheckAuthResponse> _handleDioException(DioException e) {
    String message;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server response timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          message = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 403) {
          message = 'Access denied. Please check your permissions.';
        } else if (e.response?.statusCode == 404) {
          message = 'Service not found. Please contact support.';
        } else if (e.response?.statusCode == 500) {
          message = 'Server error. Please try again later.';
        } else {
          message = e.response?.data['message'] ??
              'Something went wrong. Please try again.';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      default:
        message = 'Something went wrong. Please try again.';
    }

    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
