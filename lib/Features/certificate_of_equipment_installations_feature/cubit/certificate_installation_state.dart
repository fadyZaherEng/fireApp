import 'package:equatable/equatable.dart';
import '../data/models/certificate_installation_model.dart';

abstract class CertificateInstallationState extends Equatable {
  const CertificateInstallationState();

  @override
  List<Object> get props => [];
}

class CertificateInstallationInitial extends CertificateInstallationState {}

class CertificateInstallationLoading extends CertificateInstallationState {}

class CertificateInstallationLoaded extends CertificateInstallationState {
  final List<CertificateGroup> certificateGroups;
  final bool hasReachedMax;
  final int currentPage;

  const CertificateInstallationLoaded({
    required this.certificateGroups,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  CertificateInstallationLoaded copyWith({
    List<CertificateGroup>? certificateGroups,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return CertificateInstallationLoaded(
      certificateGroups: certificateGroups ?? this.certificateGroups,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [certificateGroups, hasReachedMax, currentPage];
}

class CertificateInstallationError extends CertificateInstallationState {
  final String message;

  const CertificateInstallationError({required this.message});

  @override
  List<Object> get props => [message];
}

class CertificateInstallationRefreshing extends CertificateInstallationState {
  final List<CertificateGroup> previousData;

  const CertificateInstallationRefreshing({required this.previousData});

  @override
  List<Object> get props => [previousData];
}
