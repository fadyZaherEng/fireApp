import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../core/services/shared_pref/pref_keys.dart';
import '../models/branch_model.dart';

class BranchApiService {
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

  BranchApiService() {
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

  /// Create a new branch
  Future<BranchResponse> createBranch(CreateBranchRequest request) async {
    try {
      // Get token from shared preferences
      final token = SharedPref().getString(PrefKeys.token);

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Set authorization header
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.post(
        '/api/consumer/branch',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        SharedPref().setString(PrefKeys.employeeId, request.employee);
        return BranchResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to create branch: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException in createBranch: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid branch data: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      _logger.e('Exception in createBranch: $e');
      throw Exception('Failed to create branch: $e');
    }
  }

  /// Add items to an existing branch
  Future<BranchResponse> addItemsToBranch(
    String branchId,
    AddItemsRequest request,
    List<BranchItem> fireExtinguisherItems,
  ) async {
    try {
      // Get token from shared preferences
      final token = SharedPref().getString(PrefKeys.token);

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Set authorization header
      _dio.options.headers['Authorization'] = 'Bearer $token';
       // Add items to the request
      final response = await _dio.put(
        '/api/consumer/branch/add-item/$branchId',
        data: request.toJson(),
      );
      final fireExtinguisherRequest = AddFireItemsRequest(
        items: FireItems(
          fireExtinguisherItem: fireExtinguisherItems,
        ),
        status: true,
      );

      // Add fire extinguisher items to the request
      final fireExtinguisherResponse = await _dio.get(
        '/api/consumer/branch/$branchId',
        data: fireExtinguisherRequest.toJson(),
      );
      print(fireExtinguisherResponse.data);
      if (response.statusCode == 200) {
        return BranchResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to add items to branch: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException in addItemsToBranch: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Branch not found with ID: $branchId');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid items data: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      _logger.e('Exception in addItemsToBranch: $e');
      throw Exception('Failed to add items to branch: $e');
    }
  }
}
