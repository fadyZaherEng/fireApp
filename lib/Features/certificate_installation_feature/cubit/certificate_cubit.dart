import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../data/services/certificate_api_service.dart';
import '../data/models/certificate_models.dart';
import 'certificate_states.dart';

class CertificateCubit extends Cubit<CertificateState> {
  final CertificateApiService _apiService;
  final Logger _logger = Logger();
  bool _isClosed = false;

  CertificateCubit(this._apiService) : super(CertificateInitial());

  // Safe emit helper method to prevent "Cannot emit new states after calling close" error
  void safeEmit(CertificateState state) {
    if (!_isClosed && !isClosed) {
      emit(state);
    } else {
      _logger.w('⚠️ Attempted to emit state after cubit was closed');
    }
  }

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }

  // Load service providers for selection
  Future<void> loadServiceProviders({Branch? selectedBranch}) async {
    safeEmit(CertificateLoading());

    // Use branch coordinates if available
    ApiResponse<List<ServiceProvider>> response;

    if (selectedBranch != null && selectedBranch.coordinates.length >= 2) {
      _logger.i(
          '🌍 Loading providers near selected branch: ${selectedBranch.branchName}');

      response = await _apiService.getServiceProviders(
        branch: selectedBranch,
      );

      if (response.success && response.data != null) {
        _logger.i('✅ Service providers loaded successfully');
        safeEmit(ServiceProvidersLoaded(
          providers: response.data!,
          selectedBranch: selectedBranch,
        ));
      } else {
        _logger.e('❌ Failed to load service providers: ${response.message}');
        safeEmit(CertificateError(message: response.message));
      }
    }
  }

  // Load branches for selection
  Future<void> loadBranches() async {
    safeEmit(CertificateLoading());

    try {
      final response = await _apiService.getBranches();

      if (response.success && response.data != null) {
        _logger.i('✅ Branches loaded successfully');
        safeEmit(BranchesLoaded(branches: response.data!));
      } else {
        _logger.e('❌ Failed to load branches: ${response.message}');
        safeEmit(CertificateError(message: response.message));
      }
    } catch (e) {
      _logger.e('💥 Error loading branches: $e');
      safeEmit(CertificateError(message: 'Failed to load branches'));
    }
  }

  // Select a service provider
  void selectServiceProvider(ServiceProvider provider) {
    if (state is ServiceProvidersLoaded) {
      final currentState = state as ServiceProvidersLoaded;
      safeEmit(currentState.copyWith(
        selectedProvider: provider,
        wantsToSkipProvider: false,
      ));
    }
  }

  // Skip service provider selection
  void skipServiceProvider() {
    if (state is ServiceProvidersLoaded) {
      final currentState = state as ServiceProvidersLoaded;
      safeEmit(currentState.copyWith(
        wantsToSkipProvider: true,
        clearSelectedProvider: true,
      ));
    }
  }

  // Proceed to installation form
  void proceedToInstallationForm({
    ServiceProvider? selectedProvider,
    required String branchId,
    List<ServiceProvider> availableProviders = const [],
  }) {
    safeEmit(CertificateInstallationForm(
      branchId: branchId,
      systemType: 'عادي', // Default system type
      area: 0.0,
      alertDevices: _getDefaultAlertDevices(),
      fireExtinguishers: _getDefaultFireExtinguishers(),
      selectedProvider: selectedProvider,
      availableProviders: availableProviders,
    ));
  }

  // Update system type
  void updateSystemType(String systemType) {
    if (state is CertificateInstallationForm) {
      final currentState = state as CertificateInstallationForm;
      safeEmit(currentState.copyWith(
        systemType: systemType,
        isFormValid:
            _validateForm(currentState.copyWith(systemType: systemType)),
      ));
    }
  }

  // Update area
  void updateArea(double area) {
    if (state is CertificateInstallationForm) {
      final currentState = state as CertificateInstallationForm;
      safeEmit(currentState.copyWith(
        area: area,
        isFormValid: _validateForm(currentState.copyWith(area: area)),
      ));
    }
  }

  // Update alert device count
  void updateAlertDeviceCount(String deviceType, int count) {
    if (state is CertificateInstallationForm) {
      final currentState = state as CertificateInstallationForm;
      final updatedDevices = currentState.alertDevices.map((device) {
        if (device.type == deviceType) {
          return AlertDevice(type: deviceType, count: count);
        }
        return device;
      }).toList();

      safeEmit(currentState.copyWith(
        alertDevices: updatedDevices,
        isFormValid:
            _validateForm(currentState.copyWith(alertDevices: updatedDevices)),
      ));
    }
  }

  // Update fire extinguisher count
  void updateFireExtinguisherCount(String extinguisherType, int count) {
    if (state is CertificateInstallationForm) {
      final currentState = state as CertificateInstallationForm;
      final updatedExtinguishers =
          currentState.fireExtinguishers.map((extinguisher) {
        if (extinguisher.type == extinguisherType) {
          return FireExtinguisher(type: extinguisherType, count: count);
        }
        return extinguisher;
      }).toList();

      safeEmit(currentState.copyWith(
        fireExtinguishers: updatedExtinguishers,
        isFormValid: _validateForm(
            currentState.copyWith(fireExtinguishers: updatedExtinguishers)),
      ));
    }
  }

  // Submit certificate installation request
  Future<void> submitCertificateRequest() async {
    if (state is CertificateInstallationForm) {
      final currentState = state as CertificateInstallationForm;

      if (!currentState.isFormValid) {
        safeEmit(CertificateError(message: 'يرجى ملء جميع الحقول المطلوبة'));
        return;
      }

      safeEmit(CertificateLoading());

      try {
        final request = CertificateInstallationRequest(
          branch: currentState.branchId,
          requestType: 'InstallationCertificate',
          providers: currentState.selectedProvider != null
              ? [ProviderSelection(provider: currentState.selectedProvider!.id)]
              : [], // Pass null if no providers available
        );

        final response =
            await _apiService.submitCertificateInstallationRequest(request);

        if (response.success && response.data != null) {
          _logger.i('✅ Certificate request submitted successfully');
          safeEmit(CertificateRequestSubmitted(
            requestId: response.data!.requestNumber,
            message: response.message,
          ));
        } else {
          _logger
              .e('❌ Failed to submit certificate request: ${response.message}');
          safeEmit(CertificateError(message: response.message));
        }
      } catch (e) {
        _logger.e('💥 Error submitting certificate request: $e');
        safeEmit(CertificateError(message: 'فشل في إرسال الطلب'));
      }
    }
  }

  // Reset to initial state
  void reset() {
    safeEmit(CertificateInitial());
  }

  // Private helper methods
  bool _validateForm(CertificateInstallationForm state) {
    return state.area > 0 &&
        state.alertDevices.any((device) => device.count > 0) &&
        state.fireExtinguishers.any((extinguisher) => extinguisher.count > 0);
  }

  List<AlertDevice> _getDefaultAlertDevices() {
    return [
      const AlertDevice(type: 'لوحة تحكم', count: 3),
      const AlertDevice(type: 'جرس إنذار', count: 2),
      const AlertDevice(type: 'كاسر زجاج', count: 4),
    ];
  }

  List<FireExtinguisher> _getDefaultFireExtinguishers() {
    return [
      const FireExtinguisher(type: 'صندوق حريق', count: 3),
      const FireExtinguisher(type: 'رشاش آلي', count: 2),
      const FireExtinguisher(type: 'مضخات حريق', count: 4),
    ];
  }
}
