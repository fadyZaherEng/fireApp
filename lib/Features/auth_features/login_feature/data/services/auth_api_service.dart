import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:safetyZone/core/config/app_config.dart';
import '../models/auth_models.dart';

class AuthApiService {
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

  AuthApiService() {
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

  Future<ApiResponse<OtpResponse>> sendOtp(SendOtpRequest request) async {
    try {
      _logger.i('📱 Sending OTP to: ${request.phoneNumber}');

      final response = await _dio.post(
        '/api/consumer/authentication/send-otp',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final otpResponse = OtpResponse.fromJson(response.data);
        _logger.i('✅ OTP sent successfully: ${otpResponse.message}');

        return ApiResponse(
          success: true,
          message: otpResponse.message,
          data: otpResponse,
          statusCode: response.statusCode,
        );
      } else {
        _logger.w('⚠️ Send OTP failed with status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to send OTP',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('💥 Dio Exception in sendOtp: ${e.message}');
      return _handleDioException(e);
    } catch (e) {
      _logger.e('💥 Unexpected error in sendOtp: $e');
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<ApiResponse<OtpResponse>> resendOtp(ResendOtpRequest request) async {
    try {
      _logger.i('🔄 Resending OTP to: ${request.phoneNumber}');

      final response = await _dio.post(
        '/api/consumer/authentication/resend-otp',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final otpResponse = OtpResponse.fromJson(response.data);
        _logger.i('✅ OTP resent successfully: ${otpResponse.message}');

        return ApiResponse(
          success: true,
          message: otpResponse.message,
          data: otpResponse,
          statusCode: response.statusCode,
        );
      } else {
        _logger.w('⚠️ Resend OTP failed with status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to resend OTP',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('💥 Dio Exception in resendOtp: ${e.message}');
      return _handleDioException(e);
    } catch (e) {
      _logger.e('💥 Unexpected error in resendOtp: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to resend OTP. Please try again.',
      );
    }
  }

  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(
      VerifyOtpRequest request) async {
    try {
      _logger.i('🔐 Verifying OTP for: ${request.phoneNumber}');

      final response = await _dio.post(
        '/api/consumer/authentication/verify-otp',
        data: request.toJson(),
      );
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        try {
          final verifyResponse = VerifyOtpResponse.fromJson(response.data);
          _logger.i(
              '✅ OTP verified successfully - Status: ${verifyResponse.status}');
          _logger.d('🏢 Company: ${verifyResponse.companyData.companyName}');
          _logger.d('👤 Employee: ${verifyResponse.employeeDetails.fullName}');

          return ApiResponse(
            success: true,
            message: 'OTP verified successfully',
            data: verifyResponse,
            statusCode: response.statusCode,
          );
        } catch (e) {
          _logger.e('💥 Error parsing verify response: $e');
          return ApiResponse(
            success: false,
            message: 'Invalid response format from server',
            statusCode: response.statusCode,
          );
        }
      } else {
        _logger.w('⚠️ Verify OTP failed with status: ${response.statusCode}');

        // Handle error response
        try {
          final errorResponse = VerifyOtpErrorResponse.fromJson(response.data);
          _logger.e('❌ Verify error: ${errorResponse.message}');

          return ApiResponse(
            success: false,
            message: errorResponse.message,
            statusCode: response.statusCode,
          );
        } catch (e) {
          return ApiResponse(
            success: false,
            message: response.data['message'] ?? 'Invalid OTP',
            statusCode: response.statusCode,
          );
        }
      }
    } on DioException catch (e) {
      _logger.e('💥 Dio Exception in verifyOtp: ${e.message}');
      return _handleDioException(e);
    } catch (e) {
      _logger.e('💥 Unexpected error in verifyOtp: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to verify OTP. Please try again.',
      );
    }
  }

  Future<ApiResponse<RegisterResponse>> register(
      RegisterRequest request) async {
    _logger.i('🔐 Registering new beneficiary');

    try {
      final response = await _dio.post(
        '/api/consumer/authentication/register',
        data: request.toJson(),
      );

      _logger.i('✅ Registration API Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null) {
          final registerResponse = RegisterResponse.fromJson(data);
          return ApiResponse(
            success: true,
            message: 'Registration successful',
            data: registerResponse,
            statusCode: response.statusCode,
          );
        } else {
          _logger.w('⚠️ Registration response has no data');
          return ApiResponse(
            success: false,
            message: 'Invalid response from server',
          );
        }
      } else {
        _logger.w('⚠️ Registration failed with status: ${response.statusCode}');
        final errorMessage = response.data?['message'] ?? 'Registration failed';
        return ApiResponse(
          success: false,
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('💥 Dio Exception in register: ${e.message}');
      return _handleDioException(e);
    } catch (e) {
      _logger.e('💥 Unexpected error in register: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to register. Please try again.',
      );
    }
  }

  ApiResponse<T> _handleDioException<T>(DioException e) {
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
