import 'package:flutter/material.dart';
import 'package:safetyZone/Features/branches/branches_screen.dart'as branch;
import 'package:safetyZone/core/localization/app_localizations.dart';
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

  List<ProductData> _products = [];
  final Map<String, List<ProductItem>> _variantsCache = {};
  final Map<String, bool> _loadingVariants = {};
  bool _isLoading = false;

  List<ProductData> get products => _products;

  bool get isLoading => _isLoading;

  String get systemType => _systemType;

  BranchData? get branchData => _branchData;

  Map<String, List<ProductItem>> get variantsCache => _variantsCache;

  Map<String, bool> get loadingVariants => _loadingVariants;

  BranchQuantitiesViewModel({
    String? systemType,
    BranchData? branchData,
    branch.Branch? branch,
  }) {
    print("=-=-=-=- $systemType");
    _systemType = systemType ?? 'zone'; // Default to 'zone' if null
    _branchData = branchData;
    _initializeProducts(branch);
  }

  /// Update the system type dynamically and reload variants if needed
  void updateSystemType(String newSystemType) {
    if (_systemType != newSystemType) {
      _systemType = newSystemType;
      print("System type updated to: $_systemType");

      // Clear cached variants since they depend on system type
      _variantsCache.clear();
      _loadingVariants.clear();

      // Reset product selections since variants may have changed
      for (int i = 0; i < _products.length; i++) {
        _products[i] = _products[i].copyWith(
          selectedVariant: null,
          selectedVariantItem: null,
          quantity: null,
        );
      }

      notifyListeners();
    }
  }

  void _initializeProducts(branch.Branch? branch) {
    final productTypes = [
      ProductType(
        id: 'control_panel',
        nameKey: 'control panel',
        imagePath: 'assets/images/1.png',
        type: 'alarm-item',
        subCategory: 'control panel',
        alarmType: 'fire alarm',
      ),
      ProductType(
        id: 'smoke_detector',
        nameKey: 'fire detector',
        imagePath: 'assets/images/2.png',
        type: 'alarm-item',
        subCategory: 'fire detector',
        alarmType: 'smoke detection',
      ),
      ProductType(
        id: 'fire_bell',
        nameKey: 'alarm bell',
        imagePath: 'assets/images/3.png',
        type: 'alarm-item',
        subCategory: 'alarm bell',
        alarmType: 'sound alarm',
      ),
      ProductType(
        id: 'manual_call_point',
        nameKey: 'glass breaker',
        imagePath: 'assets/images/4.png',
        type: 'alarm-item',
        subCategory: 'glass breaker',
        alarmType: 'manual trigger',
      ),
      ProductType(
        id: 'emergency_light',
        nameKey: 'Emergency Lighting',
        imagePath: 'assets/images/5.png',
        type: 'alarm-item',
        subCategory: 'Emergency Lighting',
        alarmType: 'visual indicator',
      ),
      ProductType(
        id: 'emergency_exit',
        nameKey: 'Emergency Exit',
        imagePath: 'assets/images/6.png',
        type: 'alarm-item',
        subCategory: 'Emergency Exit',
        alarmType: 'exit guidance',
      ),

      // Fire system items
      ProductType(
        id: 'fire_pumps',
        nameKey: 'Fire pumps',
        imagePath: 'assets/images/7.png',
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
        imagePath: 'assets/images/9.png',
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

    _products = productTypes
        .map((type) => ProductData(
              id: '${type.id}_1',
              type: type,
              selectedVariant: null,
              selectedVariantItem: null,
              quantity: 1,
            ))
        .toList();
    // ✅ لو في branchData (يعني وضع تعديل)
    if (branch != null) {
      _prefillProductsFromBranch(branch);
    }
    notifyListeners();
  }
  void _prefillProductsFromBranch(branch.Branch? branch) {
    final lang = "en"; // أو استبدلها بالـ SharedPref().getString(PrefKeys.languageCode)
     void updateProducts( branchItems, String type) {
      for (final branchItem in branchItems) {
        for (int i = 0; i < _products.length; i++) {
          final product = _products[i];

          // if (product.type.type == type &&
          //     product.type.subCategory.toLowerCase() ==
          //         branchItem.item.subCategory.toLowerCase()) {
            // ✅ لو الـ id متساوي
          print("Branch item ID: ${branchItem.itemId}, Product selectedVariantItem ID: ${product.selectedVariantItem?.id}");
            if (branchItem.itemId == product.selectedVariantItem?.id ||
                product.selectedVariantItem == null) {
              _products[i] = product.copyWith(
                selectedVariant:
                lang == "en" ? product.selectedVariantItem?.itemName.en : product.selectedVariantItem?.itemName.ar,
                selectedVariantItem: ProductItem(
                  id: product.selectedVariantItem?.id??"",
                  itemName: product.selectedVariantItem?.itemName??ItemName(en: '', ar: ''),
                  type: product.selectedVariantItem?.type??"",
                  subCategory: product.selectedVariantItem?.subCategory??"",
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  admin: product.selectedVariantItem?.admin??"",
                  alarmType: product.selectedVariantItem?.alarmType??"",
                  image: product.selectedVariantItem?.image??"",
                  isDeleted: product.selectedVariantItem?.isDeleted??false,
                  itemCode: product.selectedVariantItem?.itemCode??"",
                  supplierName: product.selectedVariantItem?.supplierName??"",
                  supplyPrice: product.selectedVariantItem?.supplyPrice??0,
                  version: product.selectedVariantItem?.version??0,
                ),
                quantity: branchItem.quantity,
              );
            // }
          }
        }
      }
    }

    // ✅ طبق على كل نوع
    updateProducts(branch?.alarmItem??[], "alarm-item");
    updateProducts(branch?.fireSystemItem??[], "fire-system-item");
    updateProducts(branch?.fireExtinguisherItem??[], "fire-system-item");
  }


  List<ProductType> getUniqueProductTypes() {
    final uniqueTypes = <String, ProductType>{};
    for (final product in _products) {
      uniqueTypes[product.type.id] = product.type;
    }
    return uniqueTypes.values.toList();
  }

  Future<void> loadVariantsForType(String nameKey) async {
    print('Loading variants for nameKey: $nameKey');
    if (_loadingVariants[nameKey] == true ||
        _variantsCache.containsKey(nameKey)) {
      return;
    }

    _loadingVariants[nameKey] = true;
    notifyListeners();

    try {
      // Find the product type for this nameKey
      String productType = 'alarm-item'; // Default fallback
      for (final product in _products) {
        if (product.type.nameKey == nameKey) {
          productType = product.type.type ?? 'alarm-item';
          break;
        }
      }

      final response = await _productApiService.getProductItems(
        nameKey: nameKey,
        type: _systemType,
        itemType: productType,
        page: 1,
        limit: 20,
      );
      print(
          'Loading variants for nameKey: $nameKey, systemType: $_systemType, itemType: $productType');
      print('Variants response: ${response.result}');
      _variantsCache[nameKey] = response.result;
      _loadingVariants[nameKey] = false;

      _updateProductSelections(nameKey, response.result);
      notifyListeners();
    } catch (e) {
      _loadingVariants[nameKey] = false;
      _variantsCache[nameKey] = [];
      _clearInvalidSelections(nameKey);
      notifyListeners();
      print('Error loading variants for $nameKey: $e');
    }
  }

  void _updateProductSelections(String nameKey, List<ProductItem> variants) {
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].type.nameKey == nameKey) {
        final currentSelection = _products[i].selectedVariant;
        if (_shouldClearSelection(currentSelection, variants)) {
          _products[i] = _products[i].copyWith(
            selectedVariant: null,
            selectedVariantItem: null,
          );
        }
      }
    }
  }

  bool _shouldClearSelection(
      String? currentSelection, List<ProductItem> variants) {
    return currentSelection == 'Loading...' ||
        currentSelection == 'No variants available' ||
        (currentSelection != null &&
            !variants.any((item) =>
                item.itemName.en == currentSelection ||
                item.itemName.ar == currentSelection));
  }

  void _clearInvalidSelections(String nameKey) {
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].type.nameKey == nameKey &&
          (_products[i].selectedVariant == 'Loading...' ||
              _products[i].selectedVariant == 'No variants available')) {
        _products[i] = _products[i].copyWith(
          selectedVariant: null,
          selectedVariantItem: null,
        );
      }
    }
  }

  void addMoreProduct(ProductType type, context) {
    final newId = '${type.id}_${DateTime.now().millisecondsSinceEpoch}';
    int insertIndex = _products.length;

    for (int i = _products.length - 1; i >= 0; i--) {
      if (_products[i].type.id == type.id) {
        insertIndex = i + 1;
        break;
      }
    }

    _products.insert(
      insertIndex,
      ProductData(
        id: newId,
        type: type,
        selectedVariant: null,
        selectedVariantItem: null,
        quantity: null,
      ),
    );
    notifyListeners();
  }

  void handleVariantSelection(
    String? variant,
    int productIndex,
    ProductData productData,
    List<ProductItem> variants,
    BuildContext context, // 👈 أضفنا الـ context عشان نعرض الرسالة
  ) {
    if (variant == 'Loading...' || variant == 'No variants available') {
      return;
    }

    ProductItem? selectedItem;
    if (variant != null && variants.isNotEmpty) {
      try {
        selectedItem = variants.firstWhere(
          (item) => item.itemName.en == variant || item.itemName.ar == variant,
        );
        final isDuplicate = _products.any((p) =>
            p.selectedVariantItem?.id == selectedItem!.id &&
            p.id != productData.id);

        if (isDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)
                  .translate("This item is already added!")),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        selectedItem = null;
        variant = null;
      }
    }
    print('Selected variant: $variant');
    print('Selected item: $productIndex');
    _products[productIndex] = productData.copyWith(
      selectedVariant: variant,
      selectedVariantItem: selectedItem,
    );
    notifyListeners();
  }

  // void handleVariantSelection(
  //     String? variant,
  //     int productIndex,
  //     ProductData productData,
  //     List<ProductItem> variants,
  //     BuildContext context, // 👈 أضفنا الـ context عشان نعرض الرسالة
  //     ) {
  //   if (variant == 'Loading...' || variant == 'No variants available') {
  //     return;
  //   }
  //
  //   ProductItem? selectedItem;
  //   if (variant != null && variants.isNotEmpty) {
  //     try {
  //       selectedItem = variants.firstWhere(
  //             (item) => item.itemName.en == variant || item.itemName.ar == variant,
  //       );
  //
  //       // ✅ تحقق لو العنصر دا مستخدم بالفعل في منتجات أخرى
  //       final isDuplicate = _products.any((p) =>
  //       p.selectedVariantItem?.id == selectedItem!.id &&
  //           p.id != productData.id);
  //
  //       if (isDuplicate) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('This item is already added!'),
  //             backgroundColor: Colors.orange,
  //           ),
  //         );
  //         return; // وقف الاختيار
  //       }
  //     } catch (e) {
  //       selectedItem = null;
  //       variant = null;
  //     }
  //   }
  //
  //   print('Selected variant: $variant');
  //   print('Selected item: $productIndex');
  //   _products[productIndex] = productData.copyWith(
  //     selectedVariant: variant,
  //     selectedVariantItem: selectedItem,
  //   );
  //   notifyListeners();
  // }
  // void handleVariantSelection(
  //   String? variant,
  //   int productIndex,
  //   ProductData productData,
  //   List<ProductItem> variants,
  //   BuildContext context,
  // ) {
  //   if (variant == 'Loading...' || variant == 'No variants available') {
  //     return;
  //   }
  //
  //   ProductItem? selectedItem;
  //   if (variant != null && variants.isNotEmpty) {
  //     try {
  //       selectedItem = variants.firstWhere(
  //         (item) => item.itemName.en == variant || item.itemName.ar == variant,
  //       );
  //
  //       // ✅ التشيك للتكرار
  //       final isDuplicate = _products.any((p) =>
  //           p.selectedVariantItem?.id == selectedItem!.id &&
  //           p.id != productData.id);
  //
  //       if (isDuplicate) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(AppLocalizations.of(context)
  //                 .translate("This item is already added!")),
  //             backgroundColor: Colors.orange,
  //           ),
  //         );
  //
  //         // 👇 مهم: رجّع القيمة القديمة (ما تغيرش)
  //         notifyListeners();
  //         return;
  //       }
  //     } catch (e) {
  //       selectedItem = null;
  //       variant = null;
  //     }
  //   }
  //
  //   // ✅ تحديث عادي لو مش مكرر
  //   _products[productIndex] = productData.copyWith(
  //     selectedVariant: variant,
  //     selectedVariantItem: selectedItem,
  //   );
  //   notifyListeners();
  // }
  // bool handleVariantSelection(
  //   String? variant,
  //   int productIndex,
  //   ProductData productData,
  //   List<ProductItem> variants,
  //   BuildContext context,
  // ) {
  //   if (variant == 'Loading...' || variant == 'No variants available') {
  //     return false;
  //   }
  //
  //   ProductItem? selectedItem;
  //   if (variant != null && variants.isNotEmpty) {
  //     try {
  //       selectedItem = variants.firstWhere(
  //         (item) => item.itemName.en == variant || item.itemName.ar == variant,
  //       );
  //
  //       final isDuplicate = _products.any((p) =>
  //           p.selectedVariantItem?.id == selectedItem!.id &&
  //           p.id != productData.id);
  //
  //       if (isDuplicate) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(AppLocalizations.of(context)
  //                 .translate("This item is already added!")),
  //             backgroundColor: Colors.orange,
  //           ),
  //         );
  //
  //         _products[productIndex] = productData.copyWith(
  //           selectedVariant: variant,
  //           selectedVariantItem: selectedItem,
  //         );
  //         return false; // 👈 مرفوض
  //       }
  //     } catch (e) {
  //       selectedItem = null;
  //       variant = null;
  //     }
  //   }
  //
  //   _products[productIndex] = productData.copyWith(
  //     selectedVariant: variant,
  //     selectedVariantItem: selectedItem,
  //   );
  //   notifyListeners();
  //   return true; // 👈 مقبول
  // }

  void updateQuantity(int productIndex, ProductData productData, int quantity) {
    _products[productIndex] = productData.copyWith(quantity: quantity);
    notifyListeners();
  }

  bool _hasDuplicateVariants() {
    final seen = <String>{};

    for (final p in products) {
      if (p.selectedVariantItem == null) continue;

      final id = p.selectedVariantItem!.id;

      if (seen.contains(id)) {
        return true; // ✅ لقيت مكرر
      }
      seen.add(id);
    }

    return false; // ✅ كله تمام
  }

  Future<void> submitQuantities(
      BuildContext context, final bool isEditing,String branchId) async {
    // ✅ check quantities
    if (!_validateQuantities()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .translate("Please enter at least one product quantity"),
          ),
        ),
      );
      return;
    }

    // ✅ check duplicates
    if (_hasDuplicateVariants()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate("thereAreRepeatedItems")),
        ),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();
    print("Submitting quantities...");
    try {
      final branchResponse = await _createBranch(isEditing,branchId);
      await _addItemsToBranch(isEditing?branchId:branchResponse.id, isEditing);

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        _showSuccessMessage(context, isEditing: isEditing);
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home,
          (route) => false,
        );
      }
    } catch (e) {
      _handleSubmissionError(e, context);
    }
  }

  bool _validateQuantities() {
    return _products.any((product) =>
        product.selectedVariant != null &&
        product.selectedVariantItem != null &&
        product.quantity != null &&
        product.quantity! > 0);
  }

  Future<dynamic> _createBranch(final bool isEditing,String branchID) async {
    // Use actual branch data if available, otherwise use defaults
    final branchName = _branchData?.branchName ?? "Default Branch";
    final employeeId = _branchData?.employeeId ?? "";
    final latitude = _branchData?.latitude ?? 30.123456;
    final longitude = _branchData?.longitude ?? -97.654321;
    final address = _branchData?.address ?? "Default Address";
    final mallName = _branchData?.mallName;
    final space = _branchData?.space ?? 50.0;

    // Convert working days data
    final workingDays = _branchData?.workingDays
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
            endMinute: 30,
          ),
        ];

    final createBranchRequest = CreateBranchRequest(
      branchName: branchName,
      employee: employeeId,
      location: BranchLocation(
        type: "Point",
        coordinates: [longitude,latitude],
      ),
      address: address,
      mall: mallName ?? "No Mall",
      space: space.toInt(),
      systemType: _systemType,
      workingDays: workingDays,
      status: isEditing,
    );
    print("===================================");
    print("Create branch request: ${createBranchRequest.toJson()}");

    print("Creating branch with data:");
    print("Branch Name: $branchName");
    print("Employee ID: $employeeId");
    print("Location: $latitude, $longitude");
    print("Address: $address");
    print("Mall: $mallName");
    print("Space: $space");
    print("System Type: $_systemType");

    return await _branchApiService.createBranch(createBranchRequest, isEditing,branchID);
  }

  /// Helper method to capitalize day names
  String _capitalizeDay(String day) {
    if (day.isEmpty) return day;
    return day[0].toUpperCase() + day.substring(1).toLowerCase();
  }

  Future<void> _addItemsToBranch(String branchId,bool isEditing) async {
    List<ProductData> validProducts = _products
        .where((product) =>
            product.selectedVariant != null &&
            product.selectedVariantItem != null &&
            product.quantity != null &&
            product.quantity! > 0)
        .toList();

    if (validProducts.isNotEmpty) {
      final List<BranchItem> alarmItems = validProducts
          .where((product) => product.type.type == 'alarm-item')
          .map((product) => BranchItem(
                itemId: product.selectedVariantItem!.id,
                quantity: product.quantity!,
              ))
          .toList();
      final List<BranchItem> fireSystemItems = validProducts
          .where((product) =>
              product.type.type == 'fire-system-item' &&
              product.type.subCategory != "Fire extinguisher maintenance")
          .map((product) => BranchItem(
                itemId: product.selectedVariantItem!.id,
                quantity: product.quantity!,
              ))
          .toList();
      final List<BranchItem> fireExtinguisherItems = validProducts
          .where((product) =>
              product.type.type == 'fire-system-item' &&
              product.type.subCategory == "Fire extinguisher maintenance")
          .map((product) => BranchItem(
                itemId: product.selectedVariantItem!.id,
                quantity: product.quantity!,
              ))
          .toList();

      // final branchItems = validProducts
      //     .map((product) => BranchItem(
      //           itemId: product.selectedVariantItem!.id,
      //           quantity: product.quantity!,
      //         ))
      //     .toList();

      final addItemsRequest = AddItemsRequest(
        items: Items(
          alarmItem: alarmItems,
          fireSystemItem: fireSystemItems,
          fireExtinguisherItem: fireExtinguisherItems,
        ),
        status: isEditing,
      );

      await _branchApiService.addItemsToBranch(
          branchId, addItemsRequest, fireExtinguisherItems);
    }
  }

  void _showSuccessMessage(BuildContext context, {bool isEditing = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing
            ? 'Branch updated successfully!'
            : 'Branch created and items added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleSubmissionError(dynamic error, BuildContext context) {
    _isLoading = false;
    notifyListeners();

    print('Error in submitQuantities: $error');

    if (context.mounted) {
      print("mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
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
