import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../core/services/shared_pref/pref_keys.dart';
import '../models/certificate_models.dart';

class FireExtinguisherApiService {
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

  FireExtinguisherApiService() {
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

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = SharedPref().getString(PrefKeys.token);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
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
          _logger.e(
              '💥 API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          _logger.e('📋 Error Message: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Only call this after a branch is selected. Uses the branch's coordinates (longitude, latitude).
  Future<ApiResponse<List<ServiceProvider>>> getServiceProviders(
      {required Branch branch}) async {
    assert(
        branch.coordinates.length >= 2, 'Branch must have valid coordinates');
    final longitude = branch.coordinates[0];
    final latitude = branch.coordinates[1];
    try {
      _logger.i(
          '🔍 Fetching nearby service providers for branch: ${branch.branchName}');

      final response = await _dio.get(
        '/api/consumer/provider/nearby',
        queryParameters: {
          'latitude': longitude,
          'longitude': latitude,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final providers =
            data.map((json) => ServiceProvider.fromJson(json)).toList();

        _logger
            .i('✅ Successfully fetched ${providers.length} service providers');

        return ApiResponse(
          success: true,
          data: providers,
          message: 'Service providers loaded successfully',
        );
      } else {
        _logger.e('❌ API returned status code: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message:
              'Failed to fetch service providers: ${response.statusMessage}',
        );
      }
    } catch (e) {
      _logger.e('💥 Error fetching service providers: $e');
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred while fetching providers',
      );
    }
  }

  // Submit certificate installation request
  Future<ApiResponse<CertificateInstallationResponse>>
      submitCertificateInstallationRequest(
    CertificateInstallationRequest request,
  ) async {
    try {
      _logger.i('🚀 Submitting certificate installation request');

      final response = await _dio.post(
        '/api/consumer/consumer-request/add',
        data: request.toJson(),
      );

      _logger.i('✅ Certificate installation request submitted successfully');

      return ApiResponse(
        success: true,
        data: CertificateInstallationResponse.fromJson(response.data),
        message: 'Certificate installation request submitted successfully',
      );
    } on DioException catch (e) {
      _logger.e(
          '💥 Error submitting certificate installation request: ${e.message}');
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ??
            'Network error occurred while submitting request',
      );
    } catch (e) {
      _logger.e(
          '💥 Unexpected error submitting certificate installation request: $e');
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  Future<ApiResponse<List<Branch>>> getBranches() async {
    try {
      _logger.i('🔍 Fetching branches');

      final response = await _dio.get('/api/consumer/branch');

      if (response.statusCode == 200) {
        final List<dynamic> branchesJson = response.data as List<dynamic>;
        final branches = branchesJson
            .map((json) => Branch.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.i('✅ Successfully fetched ${branches.length} branches');
        return ApiResponse(
          success: true,
          message: 'Branches fetched successfully',
          data: branches,
        );
      } else {
        _logger.e('❌ Failed to fetch branches: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Failed to fetch branches: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('💥 Error fetching branches: ${e.message}');
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ??
            'Network error occurred while fetching branches',
      );
    } catch (e) {
      _logger.e('💥 Unexpected error fetching branches: $e');
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  Future<ApiResponse<BranchDetails>> getBranchDetails(String branchId) async {
    try {
      _logger.i('🔍 Fetching branch details for ID: $branchId');

      final response = await _dio.get('/api/consumer/branch/$branchId');

      if (response.statusCode == 200) {
        final branchDetails =
            BranchDetails.fromJson(response.data as Map<String, dynamic>);

        _logger.i(
            '✅ Successfully fetched branch details for: ${branchDetails.branchName}');
        return ApiResponse(
          success: true,
          message: 'Branch details fetched successfully',
          data: branchDetails,
        );
      } else {
        _logger.e('❌ Failed to fetch branch details: ${response.statusCode}');
        return ApiResponse(
          success: true,
          message: '',
        );
      }
    } on DioException catch (e) {
      _logger.e('💥 Error fetching branch details: ${e.message}');
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ??
            'Network error occurred while fetching branch details',
      );
    } catch (e) {
      _logger.e('💥 Unexpected error fetching branch details: $e');
      return ApiResponse(
        success: true,
        message: '',
      );
    }
  }
}
