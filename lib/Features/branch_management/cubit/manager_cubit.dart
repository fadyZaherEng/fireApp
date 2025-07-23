import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../data/services/manager_api_service.dart';
import '../data/models/manager_models.dart';
import 'manager_states.dart';

class ManagerCubit extends Cubit<ManagerState> {
  final ManagerApiService _managerApiService;
  final Logger _logger = Logger();

  // Pagination variables
  List<Manager> _allManagers = [];
  int _currentPage = 0;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;
  static const int _limit = 10;

  ManagerCubit(this._managerApiService) : super(ManagerInitial());

  Future<void> loadManagers({bool refresh = false}) async {
    if (refresh) {
      _reset();
    }

    if (state is ManagerLoading || _isLoadingMore || !_hasNextPage) {
      return;
    }

    if (_currentPage == 0) {
      _logger.i('🔍 ManagerCubit: Loading initial managers');
      emit(ManagerLoading());
    } else {
      _logger.i(
          '🔍 ManagerCubit: Loading more managers - Page: ${_currentPage + 1}');
      _isLoadingMore = true;
      if (state is ManagerLoaded) {
        emit((state as ManagerLoaded).copyWith(isLoadingMore: true));
      }
    }

    try {
      final response = await _managerApiService.getManagers(
        limit: _limit,
        page: _currentPage + 1,
      );
      if (response.success && response.data != null) {
        final managerResponse = response.data!;

        // Since the API doesn't provide real pagination info, we'll handle it manually
        if (_currentPage == 0) {
          // First load
          _allManagers = managerResponse.managers;
          _currentPage = 1;
          _hasNextPage = false; // No real pagination support, so no next page
        } else {
          // This shouldn't happen since we have no real pagination
          _allManagers.addAll(managerResponse.managers);
          _currentPage++;
        }

        _logger.i(
            '✅ ManagerCubit: Loaded ${managerResponse.managers.length} managers. Total: ${_allManagers.length}');
        _logger.i(
            '📋 ManagerCubit: Manager names: ${_allManagers.map((m) => m.fullName).join(', ')}');

        emit(ManagerLoaded(
          managers: List.from(_allManagers),
          hasNextPage: _hasNextPage,
          currentPage: _currentPage,
          isLoadingMore: false,
        ));
      } else {
        _logger
            .w('⚠️ ManagerCubit: Load managers failed - ${response.message}');
        emit(ManagerError(error: response.message));
      }
    } catch (e) {
      _logger.e('💥 ManagerCubit: Unexpected error in loadManagers - $e');
      emit(ManagerError(error: 'Failed to load managers. Please try again.'));
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> loadMoreManagers() async {
    if (_hasNextPage && !_isLoadingMore) {
      await loadManagers();
    }
  }

  Future<void> refreshManagers() async {
    await loadManagers(refresh: true);
  }

  void _reset() {
    _allManagers.clear();
    _currentPage = 0;
    _hasNextPage = true;
    _isLoadingMore = false;
  }

  Manager? getManagerById(String id) {
    try {
      return _allManagers.firstWhere((manager) => manager.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Manager> get managers => List.from(_allManagers);
  bool get hasNextPage => _hasNextPage;
  int get currentPage => _currentPage;
  bool get isLoadingMore => _isLoadingMore;
}
