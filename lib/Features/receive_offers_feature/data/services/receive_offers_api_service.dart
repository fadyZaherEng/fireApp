import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../core/services/shared_pref/pref_keys.dart';
import '../models/offer_models.dart';
import '../models/accept_offer_models.dart';

class ReceiveOffersApiService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  late final Dio _dio;

  ReceiveOffersApiService() {
    _dio = Dio();
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add pretty logger for debugging
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = SharedPref().getString(PrefKeys.token);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          _logger.e('Error getting access token: $e');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        _logger.e('API Error: ${error.message}', error: error);
        handler.next(error);
      },
    ));
  }

  Future<OfferResponse> getOffers() async {
    try {
      _logger.i('Fetching offers from API...');

      final response = await _dio.get('/api/consumer/offer');

      if (response.statusCode == 200) {
        _logger.i('Successfully fetched offers');
        return OfferResponse.fromJson(response.data);
      } else {
        _logger
            .e('Failed to fetch offers. Status code: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch offers',
        );
      }
    } on DioException catch (e) {
      _logger.e('DioException while fetching offers: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error while fetching offers: $e', error: e);
      throw DioException(
        requestOptions: RequestOptions(path: '/api/consumer/offer'),
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<AcceptOfferResponse> acceptOffer(String offerId) async {
    try {
      _logger.i('Accepting offer: $offerId');

      final response = await _dio.put('/api/consumer/offer/accept/$offerId');

      if (response.statusCode == 200) {
        _logger.i('Successfully accepted offer: $offerId');
        return AcceptOfferResponse.fromJson(response.data);
      } else {
        _logger
            .e('Failed to accept offer. Status code: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to accept offer',
        );
      }
    } on DioException catch (e) {
      _logger.e('DioException while accepting offer: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error while accepting offer: $e', error: e);
      throw DioException(
        requestOptions:
            RequestOptions(path: '/api/consumer/offer/accept/$offerId'),
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<void> rejectOffer(String offerId) async {
    try {
      _logger.i('Rejecting offer: $offerId');

      final response = await _dio.put('/api/consumer/offer/reject/$offerId');

      if (response.statusCode == 200) {
        _logger.i('Successfully rejected offer: $offerId');
      } else {
        _logger
            .e('Failed to reject offer. Status code: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to reject offer',
        );
      }
    } on DioException catch (e) {
      _logger.e('DioException while rejecting offer: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error while rejecting offer: $e', error: e);
      throw DioException(
        requestOptions:
            RequestOptions(path: '/api/consumer/offer/reject/$offerId'),
        message: 'Unexpected error: $e',
      );
    }
  }
}
