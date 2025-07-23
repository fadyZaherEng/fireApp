import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:safetyZone/core/config/app_config.dart';
import '../models/employee_models.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../core/services/shared_pref/pref_keys.dart';

class EmployeeApiService {
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

  EmployeeApiService() {
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

  Future<ApiResponse<AddEmployeeResponse>> addEmployee(
      AddEmployeeRequest request) async {
    try {
      // Get the stored token for authentication
      final token = SharedPref().getString(PrefKeys.token);

      if (token == null) {
        _logger.w('⚠️ No token found for adding employee');
        return ApiResponse(
          success: false,
          message: 'Authentication required. Please log in again.',
          statusCode: 401,
        );
      }

      _logger.i('👥 Adding employee: ${request.fullName}');

      final response = await _dio.post(
        '/api/consumer/employee/first-employee',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final addEmployeeResponse = AddEmployeeResponse.fromJson(response.data);
        _logger
            .i('✅ Employee added successfully: ${addEmployeeResponse.message}');

        return ApiResponse(
          success: true,
          message: addEmployeeResponse.message,
          data: addEmployeeResponse,
          statusCode: response.statusCode,
        );
      } else {
        _logger.w('⚠️ Add employee failed with status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: response.data?['message'] ?? 'Failed to add employee',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('💥 Dio Exception in addEmployee: ${e.message}');
      return _handleDioException(e);
    } catch (e) {
      _logger.e('💥 Unexpected error in addEmployee: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to add employee. Please try again.',
      );
    }
  }

  Future<ApiResponse<AddEmployeeResponse>> updateEmployee(
      String employeeId, AddEmployeeRequest request) async {
    try {
      final token = SharedPref().getString(PrefKeys.token);

      if (token == null) {
        _logger.w('⚠️ No token found for updating employee');
        return ApiResponse(
          success: false,
          message: 'Authentication required. Please log in again.',
          statusCode: 401,
        );
      }

      _logger.i('📝 Updating employee: ${request.fullName}');

      final response = await _dio.put(
        '/api/consumer/employee/$employeeId',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updateEmployeeResponse =
            AddEmployeeResponse.fromJson(response.data);
        _logger.i(
            '✅ Employee updated successfully: ${updateEmployeeResponse.message}');

        return ApiResponse(
          success: true,
          message: updateEmployeeResponse.message,
          data: updateEmployeeResponse,
          statusCode: response.statusCode,
        );
      } else {
        _logger
            .w('⚠️ Update employee failed with status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: response.data?['message'] ?? 'Failed to update employee',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('💥 Dio Exception in updateEmployee: ${e.message}');
      return _handleDioException(e);
    } catch (e) {
      _logger.e('💥 Unexpected error in updateEmployee: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to update employee. Please try again.',
      );
    }
  }

  ApiResponse<AddEmployeeResponse> _handleDioException(DioException e) {
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
}
