import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:logger/logger.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../core/services/shared_pref/pref_keys.dart';
import '../models/certificate_installation_model.dart';

class CertificateInstallationApiService {
  final Dio _dio = Dio();
  late final Logger _logger;

  CertificateInstallationApiService() {
    // Initialize logger
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 3,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.none,
      ),
    );

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
          _logger.i('� API Request: ${options.method} ${options.path}');
          _logger.d('📤 Request Headers: ${options.headers}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ API Error: ${error.requestOptions.path}');
          _logger.e('� Error Details: ${error.message}');
          if (error.response != null) {
            _logger.e('📥 Error Response: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<CertificateInstallationResponse>
      getCertificatesOfEquipmentInstallations({
    int limit = 10,
    int page = 1,
  }) async {
    try {
      _logger.i('🔍 Starting Certificate Installation API Call');
      _logger.i('📄 Parameters - Limit: $limit, Page: $page');

      final response = await _dio.get(
        '/api/consumer/certificate-of-equipment-installations',
        queryParameters: {
          'limit': limit,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        _logger.i('✨ Successfully received response, parsing data...');
        final result = CertificateInstallationResponse.fromJson(response.data);

        _logger.i(
            '📊 Parsed ${result.certificateGroups.length} certificate groups');

        // Log summary of each group
        for (int i = 0; i < result.certificateGroups.length; i++) {
          final group = result.certificateGroups[i];
          _logger.i(
              '📋 Group $i: ${group.provider.name} - ${group.certificates.length} certificates');
        }

        return result;
      } else {
        _logger.e('❌ Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to load certificates: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('🚨 DioException occurred');
      _logger.e('📱 Error Type: ${e.type}');
      _logger.e('💬 Error Message: ${e.message}');

      if (e.response != null) {
        _logger.e('📊 Response Status: ${e.response?.statusCode}');
        _logger.e('📄 Response Data: ${e.response?.data}');
        _logger.e('🔗 Request URL: ${e.response?.requestOptions.uri}');

        throw Exception(
            'API Error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        _logger.e('🌐 Network connectivity issue');
        throw Exception('Network Error: ${e.message}');
      }
    } catch (e, stackTrace) {
      _logger.e('💥 Unexpected error occurred');
      _logger.e('🔍 Error: $e');
      _logger.e('📚 Stack Trace: $stackTrace');
      throw Exception('Unexpected Error: $e');
    }
  }
}
