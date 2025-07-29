import 'package:flutter/material.dart';
import '../../../core/routing/routes.dart';
import '../data/services/product_api_service.dart';
import '../data/services/branch_api_service.dart';
import '../data/models/product_item_model.dart';
import '../data/models/branch_model.dart';
import '../models/product_data.dart';
import '../models/product_type.dart';
import '../models/branch_data.dart';

class BranchQuantitiesViewModel extends ChangeNotifier {
  final ProductApiService _productApiService = ProductApiService();
  final BranchApiService _branchApiService = BranchApiService();
  final ScrollController scrollController = ScrollController();

  late String _systemType;
  BranchData? _branchData;

  List<List<ProductData>> _products = [];
  final Map<String, bool> _loadingVariants = {};
  final Map<String, List<ProductItem>> _variantsCache = {};
  bool _isLoading = false;

  List<List<ProductData>> get products => _products;

  String get systemType => _systemType;

  BranchData? get branchData => _branchData;

  bool get isLoading => _isLoading;

  BranchQuantitiesViewModel({String? systemType, BranchData? branchData}) {
    _systemType = systemType ?? 'zone';
    _branchData = branchData;
    _initializeProducts();
  }

  void updateSystemType(String newSystemType) {
    if (_systemType != newSystemType) {
      _systemType = newSystemType;
      for (int i = 0; i < _products.length; i++) {
        for (int j = 0; j < _products[i].length; j++) {
          _products[i][j] = _products[i][j].copyWith(
            selectedVariant: null,
            selectedVariantItem: null,
            quantity: null,
          );
        }
      }
      notifyListeners();
    }
  }

  void _initializeProducts() {
    final productTypes = [
      ProductType(
        id: 'control_panel',
        nameKey: 'control panel',
        imagePath: 'assets/images/lo7a.png',
        type: 'alarm-item',
        subCategory: 'control panel',
        alarmType: 'fire alarm',
      ),
      ProductType(
        id: 'smoke_detector',
        nameKey: 'fire detector',
        imagePath: 'assets/images/kashefDokhan.png',
        type: 'alarm-item',
        subCategory: 'fire detector',
        alarmType: 'smoke detection',
      ),
      ProductType(
        id: 'fire_bell',
        nameKey: 'alarm bell',
        imagePath: 'assets/images/alarmBell.png',
        type: 'alarm-item',
        subCategory: 'alarm bell',
        alarmType: 'sound alarm',
      ),
      ProductType(
        id: 'manual_call_point',
        nameKey: 'glass breaker',
        imagePath: 'assets/images/glassBreaker.png',
        type: 'alarm-item',
        subCategory: 'glass breaker',
        alarmType: 'manual trigger',
      ),
      ProductType(
        id: 'emergency_light',
        nameKey: 'Emergency Lighting',
        imagePath: 'assets/images/spareLight.png',
        type: 'alarm-item',
        subCategory: 'Emergency Lighting',
        alarmType: 'visual indicator',
      ),
      ProductType(
        id: 'emergency_exit',
        nameKey: 'Emergency Exit',
        imagePath: 'assets/images/emergency_exit.png',
        type: 'alarm-item',
        subCategory: 'Emergency Exit',
        alarmType: 'exit guidance',
      ),

      // Fire system items
      ProductType(
        id: 'fire_pumps',
        nameKey: 'Fire pumps',
        imagePath: 'assets/images/fire_pump.png',
        type: 'fire-system-item',
        subCategory: 'Fire pumps',
        madeIn: 'Germany',
      ),
      ProductType(
        id: 'automatic_sprinklers',
        nameKey: 'Automatic Sprinklers',
        imagePath: 'assets/images/sprinklers.png',
        type: 'fire-system-item',
        subCategory: 'Automatic Sprinklers',
        madeIn: 'USA',
      ),
      ProductType(
        id: 'fire_cabinets',
        nameKey: 'Fire Cabinets',
        imagePath: 'assets/images/fire_cabinet.png',
        type: 'fire-system-item',
        subCategory: 'Fire Cabinets',
        madeIn: 'UAE',
      ),
      ProductType(
        id: 'fire_extinguisher_maintenance',
        nameKey: 'Fire extinguisher maintenance',
        imagePath: 'assets/images/maintenance.png',
        type: 'fire-system-item',
        subCategory: 'Fire extinguisher maintenance',
        madeIn: 'Local',
      ),
    ];

    _products = List.generate(
      productTypes.length,
      (index) => [
        ProductData(
          id: '${productTypes[index].id}_1',
          type: productTypes[index],
          selectedVariant: null,
          selectedVariantItem: null,
          quantity: 10,
        )
      ],
    );
    notifyListeners();
  }

  List<ProductType> getUniqueProductTypes() {
    final uniqueTypes = <String, ProductType>{};
    for (final group in _products) {
      for (final product in group) {
        uniqueTypes[product.type.id] = product.type;
      }
    }
    return uniqueTypes.values.toList();
  }

  Future<void> loadVariantsForType(String nameKey) async {
    if (_loadingVariants[nameKey] == true ||
        _variantsCache.containsKey(nameKey)) {
      return;
    }

    _loadingVariants[nameKey] = true;
    notifyListeners();

    try {
      // String productType = 'alarm-item';
      for (final group in _products) {
        for (final product in group) {
          // if (product.type.nameKey == nameKey) {
          //   productType = product.type.type ?? 'alarm-item';
          //   break;
          // }
          final nameKey = product.type.nameKey;
          final type = product.type.type;
          final response = await _productApiService.getProductItems(
            nameKey: nameKey,
            type: _systemType,
            itemType: type.toString(),
            page: 1,
            limit: 20,
          );

          _variantsCache[nameKey] = response.result;
          _loadingVariants[nameKey] = false;
          _updateProductSelections(nameKey, response.result);
          notifyListeners();
        }
      }


    } catch (e) {
      _loadingVariants[nameKey] = false;
      _variantsCache[nameKey] = [];
      _clearInvalidSelections(nameKey);
      notifyListeners();
    }
  }

  void _updateProductSelections(String nameKey, List<ProductItem> variants) {
    for (int i = 0; i < _products.length; i++) {
      for (int j = 0; j < _products[i].length; j++) {
        if (_products[i][j].type.nameKey == nameKey) {
          final current = _products[i][j].selectedVariant;
          if (_shouldClearSelection(current, variants)) {
            _products[i][j] = _products[i][j].copyWith(
              selectedVariant: null,
              selectedVariantItem: null,
            );
          }
        }
      }
    }
  }

  bool _shouldClearSelection(
      String? currentSelection, List<ProductItem> variants) {
    return currentSelection == 'Loading...' ||
        currentSelection == 'No variants available' ||
        (currentSelection != null &&
            !variants.any((v) => v.itemName == currentSelection));
  }

  void _clearInvalidSelections(String nameKey) {
    for (int i = 0; i < _products.length; i++) {
      for (int j = 0; j < _products[i].length; j++) {
        if (_products[i][j].type.nameKey == nameKey &&
            (_products[i][j].selectedVariant == 'Loading...' ||
                _products[i][j].selectedVariant == 'No variants available')) {
          _products[i][j] = _products[i][j].copyWith(
            selectedVariant: null,
            selectedVariantItem: null,
          );
        }
      }
    }
  }

  void addMoreProduct(ProductType type) {
    final newId = '${type.id}_${DateTime.now().millisecondsSinceEpoch}';

    int insertIndex = _products.length;
    for (int i = _products.length - 1; i >= 0; i--) {
      if (_products[i].isNotEmpty && _products[i][0].type.id == type.id) {
        insertIndex = i + 1;
        break;
      }
    }

    _products.insert(
      insertIndex,
      [
        ProductData(
          id: newId,
          type: type,
          selectedVariant: null,
          selectedVariantItem: null,
          quantity: null,
        )
      ],
    );
    notifyListeners();
  }

  void handleVariantSelection(
    String? variant,
    int i,
    int j,
    List<ProductItem> variants,
  ) {
    if (variant == 'Loading...' || variant == 'No variants available') return;

    ProductItem? selectedItem;
    try {
      selectedItem = variants.firstWhere((item) => item.itemName == variant);
    } catch (_) {
      variant = null;
    }

    _products[i][j] = _products[i][j].copyWith(
      selectedVariant: variant,
      selectedVariantItem: selectedItem,
    );
    notifyListeners();
  }

  void updateQuantity(int i, int j, int quantity) {
    _products[i][j] = _products[i][j].copyWith(quantity: quantity);
    notifyListeners();
  }

  Future<void> submitQuantities(BuildContext context) async {
    if (!_validateQuantities()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter at least one product quantity')),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final branchResponse = await _createBranch();
      await _addItemsToBranch(branchResponse.id);

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        _showSuccessMessage(context);
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.home, (route) => false);
      }
    } catch (e) {
      _handleSubmissionError(e, context);
    }
  }

  bool _validateQuantities() {
    return _products.any((group) => group.any((product) =>
        product.selectedVariant != null &&
        product.selectedVariantItem != null &&
        product.quantity != null &&
        product.quantity! > 0));
  }

  Future<dynamic> _createBranch() async {
    final branch = _branchData;
    final createBranchRequest = CreateBranchRequest(
      branchName: branch?.branchName ?? "Default Branch",
      employee: branch?.employeeId ?? "",
      location: BranchLocation(
        type: "Point",
        coordinates: [
          branch?.latitude ?? 30.123456,
          branch?.longitude ?? -97.654321
        ],
      ),
      address: branch?.address ?? "Default Address",
      mall: branch?.mallName ?? "No Mall",
      space: branch?.space?.toInt() ?? 50,
      systemType: _systemType,
      workingDays: branch?.workingDays
              .map((day) => WorkingDay(
                    day: _capitalizeDay(day.day),
                    startHour: day.startHour,
                    startMinute: day.startMinute,
                    endHour: day.endHour,
                    endMinute: day.endMinute,
                  ))
              .toList() ??
          [
            WorkingDay(
                day: "Sunday",
                startHour: 9,
                startMinute: 0,
                endHour: 17,
                endMinute: 30),
          ],
    );

    return await _branchApiService.createBranch(createBranchRequest);
  }

  String _capitalizeDay(String day) {
    if (day.isEmpty) return day;
    return day[0].toUpperCase() + day.substring(1).toLowerCase();
  }

  Future<void> _addItemsToBranch(String branchId) async {
    final validProducts = _products
        .expand((group) => group)
        .where((product) =>
            product.selectedVariant != null &&
            product.selectedVariantItem != null &&
            product.quantity != null &&
            product.quantity! > 0)
        .toList();

    final alarmItems = validProducts
        .where((p) => p.type.type == 'alarm-item')
        .map((p) => BranchItem(
            itemId: p.selectedVariantItem!.id, quantity: p.quantity!))
        .toList();

    final fireSystemItems = validProducts
        .where((p) =>
            p.type.type == 'fire-system-item' &&
            p.type.subCategory != "Fire extinguisher maintenance")
        .map((p) => BranchItem(
            itemId: p.selectedVariantItem!.id, quantity: p.quantity!))
        .toList();

    final extinguisherItems = validProducts
        .where((p) =>
            p.type.type == 'fire-system-item' &&
            p.type.subCategory == "Fire extinguisher maintenance")
        .map((p) => BranchItem(
            itemId: p.selectedVariantItem!.id, quantity: p.quantity!))
        .toList();

    final addItemsRequest = AddItemsRequest(
      items: Items(
        alarmItem: alarmItems,
        fireSystemItem: fireSystemItems,
        fireExtinguisherItem: extinguisherItems,
      ),
      status: true,
    );

    await _branchApiService.addItemsToBranch(
        branchId, addItemsRequest, extinguisherItems);
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Branch created and items added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleSubmissionError(dynamic error, BuildContext context) {
    _isLoading = false;
    notifyListeners();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
