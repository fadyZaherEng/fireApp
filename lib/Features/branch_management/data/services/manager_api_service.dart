import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:safetyZone/Features/branches/branches_screen.dart';
import 'package:safetyZone/core/config/app_config.dart';
import '../models/manager_models.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../core/services/shared_pref/pref_keys.dart';

class ManagerApiService {
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

  ManagerApiService() {
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
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('✅ API Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('💥 API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getAuthToken() async {
    try {
      final token = SharedPref().getString(PrefKeys.token);
      return token;
    } catch (e) {
      _logger.e('Failed to get auth token: $e');
      return null;
    }
  }

  Future<ApiResponse<ManagerListResponse>> getManagers({
    int limit = 10,
    int page = 1,
  }) async {
    try {
      _logger.i('🔍 Fetching managers - Page: $page, Limit: $limit');

      // Get auth token
      final token = await _getAuthToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.get(
        '/api/consumer/employee/permission/management',
        queryParameters: {
          'limit': limit,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        _logger.i('📄 Raw API Response: ${response.data}');

        // Check if response has the expected structure
        if (response.data != null && response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;

          if (data.containsKey('result') && data['result'] is List) {
            final managerListResponse = ManagerListResponse.fromJson(data);
            _logger.i(
                '✅ Managers fetched successfully: ${managerListResponse.managers.length} managers');
            _logger.i(
                '👥 Manager details: ${managerListResponse.managers.map((m) => '${m.fullName} (${m.id})').join(', ')}');

            return ApiResponse(
              success: true,
              message: 'Managers fetched successfully',
              data: managerListResponse,
              statusCode: response.statusCode,
            );
          } else {
            _logger.w('⚠️ Unexpected response structure: ${response.data}');
            return ApiResponse(
              success: false,
              message: 'Unexpected response format from server',
              statusCode: response.statusCode,
            );
          }
        } else {
          _logger.w('⚠️ Response data is null or not a Map');
          return ApiResponse(
            success: false,
            message: 'Invalid response from server',
            statusCode: response.statusCode,
          );
        }
      } else {
        _logger.w('⚠️ Get managers failed with status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: response.data?['message'] ?? 'Failed to fetch managers',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('💥 Dio Exception in getManagers: ${e.message}');
      return _handleDioException(e);
    } catch (e) {
      _logger.e('💥 Unexpected error in getManagers: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to fetch managers. Please try again.',
      );
    }
  }

  ApiResponse<ManagerListResponse> _handleDioException(DioException e) {
    String message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        if (e.response?.data != null && e.response!.data['message'] != null) {
          message = e.response!.data['message'];
        } else {
          message = 'Server error. Please try again later.';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Network error. Please check your internet connection.';
        break;
      default:
        message = 'An unexpected error occurred. Please try again.';
    }

    return ApiResponse(
      success: false,
      message: message,
      statusCode: e.response?.statusCode,
    );
  }

  Future<ApiResponse<PaginatedBranchesResponse>> getBranchesPaginated({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _logger.i('🔍 Fetching paginated branches (page: $page, limit: $limit)');
      // Get auth token
      final token = await _getAuthToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.get(
        '/api/consumer/branch/paginated',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = PaginatedBranchesResponse.fromJson(
            response.data as Map<String, dynamic>);

        _logger.i(
            '✅ Successfully fetched ${data.data.length} branches (total: ${data.total})');

        return ApiResponse(
          success: true,
          message: 'Branches fetched successfully',
          data: data,
        );
      } else {
        _logger
            .e('❌ Failed to fetch paginated branches: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Failed to fetch paginated branches: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('💥 Error fetching paginated branches: ${e.message}');
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ??
            'Network error occurred while fetching paginated branches',
      );
    } catch (e) {
      _logger.e('💥 Unexpected error fetching paginated branches: $e');
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }
}
