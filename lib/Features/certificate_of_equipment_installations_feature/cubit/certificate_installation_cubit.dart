import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../data/services/certificate_installation_api_service.dart';
import 'certificate_installation_state.dart';

class CertificateInstallationCubit extends Cubit<CertificateInstallationState> {
  final CertificateInstallationApiService _apiService;
  late final Logger _logger;

  CertificateInstallationCubit(this._apiService)
      : super(CertificateInstallationInitial()) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 3,
        lineLength: 80,
        colors: false,
        printEmojis: true,
        printTime: true,
      ),
      output: ConsoleOutput(),
    );
  }

  Future<void> loadCertificates({bool isRefresh = false}) async {
    print('🔄 Certificate Installation Cubit: Loading certificates');
    print('🔄 Is Refresh: $isRefresh');
    print('📊 Current State: ${state.runtimeType}');

    _logger.i('🔄 Certificate Installation Cubit: Loading certificates');
    _logger.i('🔄 Is Refresh: $isRefresh');
    _logger.i('📊 Current State: ${state.runtimeType}');

    if (isRefresh && state is CertificateInstallationLoaded) {
      final currentState = state as CertificateInstallationLoaded;
      print(
          '🔄 Refreshing with ${currentState.certificateGroups.length} existing groups');
      _logger.i(
          '🔄 Refreshing with ${currentState.certificateGroups.length} existing groups');
      emit(CertificateInstallationRefreshing(
          previousData: currentState.certificateGroups));
    } else if (!isRefresh) {
      print('⏳ Emitting loading state');
      _logger.i('⏳ Emitting loading state');
      emit(CertificateInstallationLoading());
    }

    try {
      print('🌐 Calling API service...');
      _logger.i('🌐 Calling API service...');
      final response =
          await _apiService.getCertificatesOfEquipmentInstallations(
        limit: 10,
        page: 1,
      );

      print('✅ API call successful');
      print(
          '📦 Received ${response.certificateGroups.length} certificate groups');
      _logger.i('✅ API call successful');
      _logger.i(
          '📦 Received ${response.certificateGroups.length} certificate groups');

      emit(CertificateInstallationLoaded(
        certificateGroups: response.certificateGroups,
        hasReachedMax: response.certificateGroups.length < 10,
        currentPage: 1,
      ));

      print('✨ Successfully emitted loaded state');
      print('🏁 Has reached max: ${response.certificateGroups.length < 10}');
      _logger.i('✨ Successfully emitted loaded state');
      _logger
          .i('🏁 Has reached max: ${response.certificateGroups.length < 10}');
    } catch (e) {
      print('💥 Error loading certificates');
      print('🔍 Error details: $e');
      _logger.e('💥 Error loading certificates');
      _logger.e('🔍 Error details: $e');
      emit(CertificateInstallationError(message: e.toString()));
    }
  }

  Future<void> loadMoreCertificates() async {
    print('📄 Loading more certificates...');
    _logger.i('📄 Loading more certificates...');

    if (state is CertificateInstallationLoaded) {
      final currentState = state as CertificateInstallationLoaded;

      print('📊 Current page: ${currentState.currentPage}');
      print('🔚 Has reached max: ${currentState.hasReachedMax}');
      _logger.i('📊 Current page: ${currentState.currentPage}');
      _logger.i('🔚 Has reached max: ${currentState.hasReachedMax}');

      if (currentState.hasReachedMax) {
        print('🛑 Already reached maximum, not loading more');
        _logger.i('🛑 Already reached maximum, not loading more');
        return;
      }

      try {
        print('🌐 Loading page ${currentState.currentPage + 1}...');
        _logger.i('🌐 Loading page ${currentState.currentPage + 1}...');
        final response =
            await _apiService.getCertificatesOfEquipmentInstallations(
          limit: 10,
          page: currentState.currentPage + 1,
        );

        final newCertificates = [
          ...currentState.certificateGroups,
          ...response.certificateGroups
        ];

        print('📦 Merged ${newCertificates.length} total certificate groups');
        print('➕ Added ${response.certificateGroups.length} new groups');
        _logger
            .i('📦 Merged ${newCertificates.length} total certificate groups');
        _logger.i('➕ Added ${response.certificateGroups.length} new groups');

        emit(CertificateInstallationLoaded(
          certificateGroups: newCertificates,
          hasReachedMax: response.certificateGroups.length < 10,
          currentPage: currentState.currentPage + 1,
        ));

        print('✅ Successfully loaded more certificates');
        _logger.i('✅ Successfully loaded more certificates');
      } catch (e) {
        print('💥 Error loading more certificates');
        print('🔍 Error details: $e');
        _logger.e('💥 Error loading more certificates');
        _logger.e('🔍 Error details: $e');
        emit(CertificateInstallationError(message: e.toString()));
      }
    } else {
      print(
          '⚠️ Cannot load more - current state is not loaded: ${state.runtimeType}');
      _logger.w(
          '⚠️ Cannot load more - current state is not loaded: ${state.runtimeType}');
    }
  }

  Future<void> refreshCertificates() async {
    print('🔄 Refreshing certificates...');
    _logger.i('🔄 Refreshing certificates...');
    await loadCertificates(isRefresh: true);
  }
}
