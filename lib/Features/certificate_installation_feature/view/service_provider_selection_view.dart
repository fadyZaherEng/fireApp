import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../data/models/certificate_models.dart';
import '../data/services/certificate_api_service.dart';
import 'widgets/certificate_installation_form.dart';
import 'widgets/success_dialog.dart';

class ServiceProviderSelectionView extends StatefulWidget {
  const ServiceProviderSelectionView({super.key});

  @override
  State<ServiceProviderSelectionView> createState() =>
      _ServiceProviderSelectionViewState();
}

class _ServiceProviderSelectionViewState
    extends State<ServiceProviderSelectionView> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  final _certificateApiService = CertificateApiService();

  // Form state variables
  String _systemType = 'عادي';
  String _selectedBranch = '';
  ServiceProvider? _selectedProvider;
  bool _wantsProvider = false;
  bool _showProviderSelection = false;
  bool _isLoadingBranches = false;
  bool _isLoadingProviders = false;
  bool _isLoadingBranchDetails = false;
  List<Branch> _branches = [];
  List<ServiceProvider> _providers = [];
  List<AlertDevice> _alertDevices = [];
  List<FireExtinguisher> _fireExtinguishers = [];
  bool _systemTypeEnabled = true;
  bool _areaEnabled = true;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
    // Auto-show provider selection after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showProviderSelection = true;
        });
      }
    });
  }

  Future<void> _fetchBranches() async {
    setState(() {
      _isLoadingBranches = true;
    });

    try {
      final response = await _certificateApiService.getBranches();
      if (response.success && response.data != null) {
        setState(() {
          _branches = response.data!;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message,
                style: const TextStyle(fontFamily: 'Almarai'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading branches: $e',
              style: const TextStyle(fontFamily: 'Almarai'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingBranches = false;
      });
    }
  }

  Future<void> _fetchNearbyProviders(Branch branch) async {
    if (_isLoadingProviders) return;

    setState(() {
      _isLoadingProviders = true;
      _providers.clear();
      _selectedProvider = null;
    });

    try {
      final response =
          await _certificateApiService.getServiceProviders(branch: branch);
      if (response.success && response.data != null) {
        setState(() {
          _providers = response.data!;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message,
                style: const TextStyle(fontFamily: 'Almarai'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading service providers: $e',
              style: const TextStyle(fontFamily: 'Almarai'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingProviders = false;
      });
    }
  }

  Future<void> _fetchBranchDetails(
      String branchId, AppLocalizations localizations) async {
    if (_isLoadingBranchDetails) return;

    setState(() {
      _isLoadingBranchDetails = true;
      _alertDevices.clear();
      _fireExtinguishers.clear();
    });

    try {
      final response = await _certificateApiService.getBranchDetails(branchId);
      if (response.success && response.data != null) {
        final branchDetails = response.data!;

        // Convert items to alert devices and fire extinguishers
        List<AlertDevice> alertDevices = branchDetails.alarmItem.map((item) {
          return AlertDevice(
            type: item.itemDetails.itemName,
            count: item.quantity,
          );
        }).toList();
        List<FireExtinguisher> fireExtinguishers = branchDetails.fireSystemItem.map((item) {
          return FireExtinguisher(
            type: item.itemDetails.itemName,
            count: item.quantity,
          );
        }).toList();

        // for (final item in branchDetails.items) {
        //   final itemType = item.itemDetails.type;
        //   final itemName = item.itemDetails.itemName;
        //   final quantity = item.quantity;
        //
        //   // Categorize items based on type and subcategory
        //   if (itemType == 'alarm-item') {
        //     // Map alarm items to alert devices
        //     String deviceType = itemName;
        //
        //     // Use the actual itemName for display, but try to map to localized categories for grouping
        //     deviceType = itemName; // Use the actual item name for display
        //
        //     alertDevices.add(AlertDevice(type: deviceType, count: quantity));
        //   } else if (itemType == 'fire-item' ||
        //       itemName.contains('حريق') ||
        //       itemName.contains('إطفاء')) {
        //     // Map fire items to fire extinguishers
        //     String extinguisherType =
        //         itemName; // Use the actual item name for display
        //
        //     fireExtinguishers
        //         .add(FireExtinguisher(type: extinguisherType, count: quantity));
        //   }
        // }

        setState(() {
          _alertDevices = alertDevices;
          _fireExtinguishers = fireExtinguishers;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message,
                style: const TextStyle(fontFamily: 'Almarai'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading branch details: $e',
              style: const TextStyle(fontFamily: 'Almarai'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingBranchDetails = false;
      });
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    bool arab = localizations.isArabic();
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDF2FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: arab == false
            ? IconButton(
                icon: Icon(
                  isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  color: AppColors.primaryBlue,
                  size: 20.sp,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          if (arab == true)
            IconButton(
              icon: Icon(
                isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                color: AppColors.primaryBlue,
                size: 20.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
        ],
        title: Text(
          localizations.translate('certificateInstallationTitle'),
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 18.sp,
            color: AppColors.primaryBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingBranches || _isLoadingBranchDetails
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            )
          : _showProviderSelection
              ? _buildCompleteForm(context, isRTL, localizations)
              : const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryRed,
                  ),
                ),
    );
  }

  Widget _buildCompleteForm(
    BuildContext context,
    bool isRTL,
    AppLocalizations localizations,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CertificateInstallationForm(
            formKey: _formKey,
            areaController: _areaController,
            branches: _branches,
            selectedBranch: _selectedBranch,
            selectedSystemType: _systemType,
            alertDevices: _alertDevices,
            fireExtinguishers: _fireExtinguishers,
            wantsProvider: _wantsProvider,
            selectedProvider: _selectedProvider,
            providers: _providers,
            systemTypeEnabled: _systemTypeEnabled,
            areaEnabled: _areaEnabled,
            onBranchChanged: (value) {
              if (value != null && value.isNotEmpty) {
                // Find the selected branch to get its details
                final selectedBranch = _branches.firstWhere(
                  (branch) => branch.id == value,
                  orElse: () => throw Exception('Branch not found'),
                );

                // Update state with branch information
                setState(() {
                  _selectedBranch = value;
                  _systemType =
                      selectedBranch.systemType; // Set system type from branch
                  _areaController.text =
                      selectedBranch.space.toString(); // Set area from branch
                  _systemTypeEnabled = false; // Disable system type editing
                  _areaEnabled = false; // Disable area editing
                });

                // Fetch providers and branch details
                _fetchNearbyProviders(selectedBranch);
                _fetchBranchDetails(value, localizations);
              } else {
                // If branch is deselected, reset and enable fields
                setState(() {
                  _selectedBranch = '';
                  _systemType = 'عادي'; // Default system type
                  _areaController.clear(); // Clear area
                  _systemTypeEnabled = true; // Enable system type editing
                  _areaEnabled = true; // Enable area editing
                  _providers.clear(); // Clear providers list
                  _selectedProvider = null;
                });
              }
            },
            onSystemTypeChanged: (value) {
              if (value != null) {
                setState(() {
                  _systemType = value;
                });
              }
            },
            onProviderChoiceChanged: (wantsProvider) {
              setState(() {
                _wantsProvider = wantsProvider;
                if (!wantsProvider) {
                  _selectedProvider = null;
                }
              });
            },
            onProviderChanged: (provider) {
              setState(() {
                _selectedProvider = provider;
              });
            },
            onSubmit: () => _handleSubmit(localizations),
            localizations: localizations,
            isLoadingProviders: _isLoadingProviders,
          ),
        ],
      ),
    );
  }

  void _handleSubmit(AppLocalizations localizations) async {
    if (_formKey.currentState?.validate() == true) {
      final area = double.tryParse(_areaController.text) ?? 0.0;
      final hasDevices = _alertDevices.any((device) => device.count > 0) ||
          _fireExtinguishers.any((extinguisher) => extinguisher.count > 0);

      if (_selectedBranch.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.translate('branchRequired'),
              style: const TextStyle(fontFamily: 'Almarai'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (area > 0 && hasDevices) {
        // Create the request
        final request = CertificateInstallationRequest(
          branch: _selectedBranch,
          requestType: 'InstallationCertificate',
          providers: _selectedProvider != null
              ? [ProviderSelection(provider: _selectedProvider!.id)]
              : _providers.isNotEmpty
                  ? _providers
                      .map((provider) =>
                          ProviderSelection(provider: provider.id))
                      .toList()
                  : null, // Pass null if no providers available
        );

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryRed,
            ),
          ),
        );

        try {
          // Submit the request
          final response = await _certificateApiService
              .submitCertificateInstallationRequest(request);

          // Hide loading indicator
          Navigator.of(context).pop();

          if (response.success && response.data != null) {
            // Show success dialog
            SuccessDialog.show(
              context,
              localizations,
              () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home
              },
            );
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.message,
                  style: const TextStyle(fontFamily: 'Almarai'),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          // Hide loading indicator
          Navigator.of(context).pop();

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error submitting request: $e',
                style: const TextStyle(fontFamily: 'Almarai'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.translate('fillAllFields'),
              style: const TextStyle(fontFamily: 'Almarai'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
