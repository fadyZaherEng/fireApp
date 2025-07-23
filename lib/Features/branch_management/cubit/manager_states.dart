import '../data/models/manager_models.dart';

abstract class ManagerState {}

class ManagerInitial extends ManagerState {}

class ManagerLoading extends ManagerState {}

class ManagerLoaded extends ManagerState {
  final List<Manager> managers;
  final bool hasNextPage;
  final int currentPage;
  final bool isLoadingMore;

  ManagerLoaded({
    required this.managers,
    required this.hasNextPage,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  ManagerLoaded copyWith({
    List<Manager>? managers,
    bool? hasNextPage,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return ManagerLoaded(
      managers: managers ?? this.managers,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ManagerError extends ManagerState {
  final String error;

  ManagerError({required this.error});
}
