import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../core/services/shared_pref/pref_keys.dart';
import '../models/product_item_model.dart';

class ProductApiService {
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

  ProductApiService() {
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

  /// Get product items by nameKey (subCategory)
  Future<ProductItemResponse> getProductItems({
    required String nameKey,
    required String type,
    required String itemType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Get token from shared preferences
      final token = SharedPref().getString(PrefKeys.token);

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }
      // Set authorization header
      _dio.options.headers['Authorization'] = 'Bearer $token';

      if (nameKey != "Fire extinguisher maintenance") {
        final response = await _dio.get(
          '/api/consumer/item-management/$itemType/$nameKey?alarmType=$type',
          queryParameters: {
            'page': page,
            'limit': limit,
          },
        );

        if (response.statusCode == 200) {
          return ProductItemResponse.fromJson(response.data);
        } else {
          throw Exception(
              'Failed to fetch product items: ${response.statusCode}');
        }
      } else {
        final response = await _dio.get(
          '/api/consumer/item-management/fire-extinguisher?page=1&limit=2',
          queryParameters: {
            'page': page,
            'limit': limit,
          },
        );

        if (response.statusCode == 200) {
          return ProductItemResponse.fromJson(response.data);
        } else {
          throw Exception(
              'Failed to fetch product items: ${response.statusCode}');
        }
      }
    } on DioException catch (e) {
      _logger.e('DioException in getProductItems: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Product items not found for category: $nameKey');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      _logger.e('Exception in getProductItems: $e');
      throw Exception('Failed to fetch product items: $e');
    }
  }
}
