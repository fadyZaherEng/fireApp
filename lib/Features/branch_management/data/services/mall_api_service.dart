import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../core/services/shared_pref/pref_keys.dart';
import '../models/mall_model.dart';

class MallApiService {
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

  MallApiService() {
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

  Future<ApiResponse<List<Mall>>> getNearbyMalls({
    double longitude = 30.0444,
    double latitude = 31.2357,
  }) async {
    try {
      _logger.i('🏢 Fetching nearby malls - Lat: $latitude, Lng: $longitude');

      // Get auth token
      final token = await _getAuthToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get(
        '/api/consumer/mall/near-by',
        queryParameters: {
          'longitude': longitude,
          'latitude': latitude,
          'maxDistance': 100000,
        },
      );

      if (response.statusCode == 200) {
        _logger.i('📄 Raw API Response: ${response.data}');

        // Check if response is a list (as per the new API format)
        if (response.data != null && response.data is List) {
          final mallList = (response.data as List)
              .map((item) => Mall.fromJson(item as Map<String, dynamic>))
              .toList();

          _logger.i('✅ Malls fetched successfully: ${mallList.length} malls');
          _logger.i(
              '🏢 Mall details: ${mallList.map((m) => '${m.name} (${m.id})').join(', ')}');

          return ApiResponse(
            success: true,
            message: 'Malls fetched successfully',
            data: mallList,
            statusCode: response.statusCode,
          );
        } else {
          _logger.w('⚠️ Response data is not a List: ${response.data}');
          return ApiResponse(
            success: false,
            message: 'Unexpected response format from server',
            statusCode: response.statusCode,
          );
        }
      } else {
        _logger.w('⚠️ Get malls failed with status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: response.data?['message'] ?? 'Failed to fetch malls',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('💥 Dio Exception in getNearbyMalls: ${e.message}');
      return _handleDioException(e);
    } catch (e) {
      _logger.e('💥 Unexpected error in getNearbyMalls: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to fetch malls. Please try again.',
      );
    }
  }

  ApiResponse<List<Mall>> _handleDioException(DioException e) {
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
