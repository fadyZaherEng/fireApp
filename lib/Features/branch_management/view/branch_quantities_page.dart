import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/constants/branch_colors.dart';
import '../../../core/widgets/branch_widgets.dart';
import '../models/branch_data.dart';
import '../viewmodel/branch_quantities_viewmodel.dart';
import 'widgets/product_group_widget.dart';

class BranchQuantitiesPage extends StatelessWidget {
  final String? systemType;
  final BranchData? branchData;

  const BranchQuantitiesPage({
    super.key,
    this.systemType,
    this.branchData,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BranchQuantitiesViewModel(
        systemType: systemType,
        branchData: branchData,
      ),
      child: const BranchQuantitiesView(),
    );
  }
}

class BranchQuantitiesView extends StatelessWidget {
  const BranchQuantitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BranchQuantitiesViewModel>(context);
    final localizations = AppLocalizations.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: BranchColors.lightBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, localizations, isRTL),
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildProductList(context, viewModel, localizations, isRTL),
            ),
            _buildBottomButton(context, viewModel, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLocalizations localizations, bool isRTL) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 8.h,
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
          ),
          child: Text(
            localizations.translate('addYourBranches'),
            style: TextStyle(
              fontFamily: 'Almarai',
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              height: 22 / 24,
              letterSpacing: 0,
              color: BranchColors.primaryBlue,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 8.h,
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
          ),
          child: Text(
            localizations.translate('enterAvailableQuantities'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: isRTL ? 'Almarai' : 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList(
    BuildContext context,
    BranchQuantitiesViewModel viewModel,
    AppLocalizations localizations,
    bool isRTL,
  ) {
    return ListView.builder(
      controller: viewModel.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: viewModel.getUniqueProductTypes().length,
      itemBuilder: (context, index) {
        final productType = viewModel.getUniqueProductTypes()[index];
        final sameTypeProducts = viewModel.products
            .where((p) => p.type.id == productType.id)
            .toList();

        final variants = viewModel.variantsCache[productType.nameKey] ?? [];
        final isLoadingVariants =
            viewModel.loadingVariants[productType.nameKey] == true;
        final hasLoadedVariants =
            viewModel.variantsCache.containsKey(productType.nameKey);

        List<String> variantNames = _getVariantNames(
          isLoadingVariants,
          hasLoadedVariants,
          variants,
        );

        return ProductGroupWidget(
          productType: productType,
          products: sameTypeProducts,
          variantNames: variantNames,
          isLoadingVariants: isLoadingVariants,
          hasLoadedVariants: hasLoadedVariants,
          onVariantChanged: (variant) {
            for (var product in sameTypeProducts) {
              final index = viewModel.products.indexOf(product);
              if (index != -1) {
                viewModel.handleVariantSelection(
                  variant,
                  index,
                  product,
                  variants,
                );
              }
            }
          },
          onQuantityChanged: (quantity) {
            if (sameTypeProducts.isNotEmpty) {
              final index = viewModel.products.indexOf(sameTypeProducts.first);
              if (index != -1) {
                viewModel.updateQuantity(
                  index,
                  sameTypeProducts.first,
                  quantity,
                );
              }
            }
          },
          onDropdownOpened: () =>
              viewModel.loadVariantsForType(productType.nameKey),
          onAddMore: () => viewModel.addMoreProduct(productType),
          localizations: localizations,
          isRTL: isRTL,
        );
      },
    );
  }

  List<String> _getVariantNames(
    bool isLoadingVariants,
    bool hasLoadedVariants,
    List<dynamic> variants,
  ) {
    if (isLoadingVariants) {
      return ['Loading...'];
    } else if (hasLoadedVariants && variants.isEmpty) {
      return ['No variants available'];
    } else if (hasLoadedVariants && variants.isNotEmpty) {
      return variants
          .map((item) => item.itemName.toString())
          .toSet()
          .toList()
          .cast<String>();
    }
    return [];
  }

  Widget _buildBottomButton(
    BuildContext context,
    BranchQuantitiesViewModel viewModel,
    AppLocalizations localizations,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: PrimaryButton(
            text: localizations.translate('confirm'),
            onPressed: () => viewModel.submitQuantities(context),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
