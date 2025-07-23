import 'package:equatable/equatable.dart';
import '../data/models/certificate_models.dart';

abstract class  EngineeringInspectionReportStates extends Equatable {
  @override
  List<Object?> get props => [];
}

class CertificateInitial extends EngineeringInspectionReportStates {}

class CertificateLoading extends EngineeringInspectionReportStates {}

// Service Provider Selection States
class ServiceProvidersLoaded extends EngineeringInspectionReportStates {
  final List<ServiceProvider> providers;
  final ServiceProvider? selectedProvider;
  final bool wantsToSkipProvider;
  final Branch? selectedBranch;

  ServiceProvidersLoaded({
    required this.providers,
    this.selectedProvider,
    this.wantsToSkipProvider = false,
    this.selectedBranch,
  });

  ServiceProvidersLoaded copyWith({
    List<ServiceProvider>? providers,
    ServiceProvider? selectedProvider,
    bool? wantsToSkipProvider,
    Branch? selectedBranch,
    bool clearSelectedProvider = false,
    bool clearSelectedBranch = false,
  }) {
    return ServiceProvidersLoaded(
      providers: providers ?? this.providers,
      selectedProvider: clearSelectedProvider
          ? null
          : (selectedProvider ?? this.selectedProvider),
      wantsToSkipProvider: wantsToSkipProvider ?? this.wantsToSkipProvider,
      selectedBranch:
          clearSelectedBranch ? null : (selectedBranch ?? this.selectedBranch),
    );
  }

  @override
  List<Object?> get props =>
      [providers, selectedProvider, wantsToSkipProvider, selectedBranch];
}

// Installation Details States
class CertificateInstallationForm extends EngineeringInspectionReportStates {
  final String branchId;
  final String systemType;
  final double area;
  final List<AlertDevice> alertDevices;
  final List<FireExtinguisher> fireExtinguishers;
  final ServiceProvider? selectedProvider;
  final List<ServiceProvider> availableProviders;
  final bool isFormValid;

  CertificateInstallationForm({
    required this.branchId,
    required this.systemType,
    required this.area,
    required this.alertDevices,
    required this.fireExtinguishers,
    this.selectedProvider,
    this.availableProviders = const [],
    this.isFormValid = false,
  });

  CertificateInstallationForm copyWith({
    String? branchId,
    String? systemType,
    double? area,
    List<AlertDevice>? alertDevices,
    List<FireExtinguisher>? fireExtinguishers,
    ServiceProvider? selectedProvider,
    List<ServiceProvider>? availableProviders,
    bool? isFormValid,
    bool clearSelectedProvider = false,
  }) {
    return CertificateInstallationForm(
      branchId: branchId ?? this.branchId,
      systemType: systemType ?? this.systemType,
      area: area ?? this.area,
      alertDevices: alertDevices ?? this.alertDevices,
      fireExtinguishers: fireExtinguishers ?? this.fireExtinguishers,
      selectedProvider: clearSelectedProvider
          ? null
          : (selectedProvider ?? this.selectedProvider),
      availableProviders: availableProviders ?? this.availableProviders,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  @override
  List<Object?> get props => [
        branchId,
        systemType,
        area,
        alertDevices,
        fireExtinguishers,
        selectedProvider,
        availableProviders,
        isFormValid
      ];
}

// Success/Error States
class CertificateRequestSubmitted extends EngineeringInspectionReportStates {
  final String requestId;
  final String message;

  CertificateRequestSubmitted({
    required this.requestId,
    required this.message,
  });

  @override
  List<Object?> get props => [requestId, message];
}

class CertificateError extends EngineeringInspectionReportStates {
  final String message;

  CertificateError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Branch States
class BranchesLoaded extends EngineeringInspectionReportStates {
  final List<Branch> branches;

  BranchesLoaded({required this.branches});

  @override
  List<Object?> get props => [branches];
}
