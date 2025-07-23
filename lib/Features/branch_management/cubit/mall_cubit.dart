import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../data/services/mall_api_service.dart';
import 'mall_states.dart';

class MallCubit extends Cubit<MallState> {
  final MallApiService _mallApiService;

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

  MallCubit(this._mallApiService) : super(MallInitial());

  Future<void> loadNearbyMalls({
    double? longitude,
    double? latitude,
  }) async {
    try {
      emit(MallLoading());

      // Use provided coordinates or default to Riyadh, Saudi Arabia
      final finalLongitude = longitude!;
      final finalLatitude = latitude!;

      _logger.i(
          '🏢 Loading nearby malls at coordinates: Lat: $finalLatitude, Lng: $finalLongitude');

      final response = await _mallApiService.getNearbyMalls(
        longitude: finalLongitude,
        latitude: finalLatitude,
      );

      if (response.success && response.data != null) {
        _logger
            .i('✅ Malls loaded successfully: ${response.data!.length} malls');
        emit(MallSuccess(malls: response.data!));
      } else {
        _logger.w('⚠️ Failed to load malls: ${response.message}');
        emit(MallError(message: response.message));
      }
    } catch (e) {
      _logger.e('💥 Error loading malls: $e');
      emit(
          MallError(message: 'Failed to load nearby malls. Please try again.'));
    }
  }

  void reset() {
    emit(MallInitial());
  }
}
