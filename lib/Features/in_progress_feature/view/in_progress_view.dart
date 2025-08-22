import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safetyZone/Features/receive_offers_feature/cubit/receive_offers_cubit.dart';
import 'package:safetyZone/Features/receive_offers_feature/cubit/receive_offers_states.dart';
import 'package:safetyZone/Features/receive_offers_feature/data/models/offer_models.dart';
import 'package:safetyZone/Features/receive_offers_feature/data/services/receive_offers_api_service.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:safetyZone/core/services/shared_pref/pref_keys.dart';
import 'package:safetyZone/core/services/shared_pref/shared_pref.dart';
import 'package:safetyZone/core/utils/constants/colors.dart';

class InProgressView extends StatelessWidget {
  const InProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ReceiveOffersCubit(ReceiveOffersApiService())..fetchOffers(),
      child: const InProgressViewContent(),
    );
  }
}

class InProgressViewContent extends StatefulWidget {
  const InProgressViewContent({super.key});

  @override
  State<InProgressViewContent> createState() => _InProgressViewContentState();
}

class _InProgressViewContentState extends State<InProgressViewContent> {
  int page = 1;
  int limit = 10;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<OfferPricing> priceOffers = [];

  @override
  void initState() {
    context.read<ReceiveOffersCubit>().fetchPriceOffers(
          page: page,
          limit: limit,
          isStart: true, // لبدء التحميل من الصفحة الأولى
          statusFlag: false,
        );
    super.initState();
    // _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _isLoadingMore = true;
        page += 1; // ✅ مش page += limit
        context
            .read<ReceiveOffersCubit>()
            .fetchPriceOffers(
              page: page,
              limit: limit,
              statusFlag: false,
            )
            .then((_) {
          _isLoadingMore = false;
          if (context.read<ReceiveOffersCubit>().priceOffers.isEmpty) {
            _hasMore = false;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: BlocConsumer<ReceiveOffersCubit, ReceiveOffersState>(
        listener: (context, state) {
          final localizations = AppLocalizations.of(context);

          if (state is CancelPriceOffersSuccess) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(localizations.translate('success')),
                content: Text(state.message),
                actions: [
                  TextButton(
                    child: Text(localizations.translate('ok')),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
            // Reset the page and isHaveMore when switching tabs
            context.read<ReceiveOffersCubit>().fetchPriceOffers(
                  page: page,
                  limit: limit,
                  statusFlag: false,
                );
          } else if (state is CancelPriceOffersError) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(localizations.translate('error')),
                content: Text(state.message),
                actions: [
                  TextButton(
                    child: Text(localizations.translate('ok')),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          // appBar: AppBar(
          //    elevation: 0,
          //   backgroundColor: const Color(0xFFF5F5F5),
          //   // title: Text(
          //   //   localizations.translate('pricingRequests'),
          //   //   style: TextStyle(
          //   //     fontSize: 20.sp,
          //   //     fontWeight: FontWeight.bold,
          //   //     color: const Color(0xFF2196F3),
          //   //     fontFamily: 'Almarai',
          //   //   ),
          //   // ),
          //   centerTitle: true,
          // ),
          body: SafeArea(
            child: BlocBuilder<ReceiveOffersCubit, ReceiveOffersState>(
              builder: (context, state) {
                final localizations = AppLocalizations.of(context);
            
                List<OfferPricing> priceOffers = context
                    .watch<ReceiveOffersCubit>()
                    .priceOffers; // قائمة الأسعار
                final isLoadingPriceOffers = state
                    is ReceivePriceOffersLoading; // حالة التحميل لطلبات الأسعار
                final isErrorPriceOffers =
                    state is ReceivePriceOffersError; // حالة الخطأ لطلبات الأسعار
            
                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        page = 1;
                        _hasMore = true;
                        priceOffers.clear();
                        await context.read<ReceiveOffersCubit>().fetchPriceOffers(
                              page: page,
                              limit: limit,
                              isStart: true,
                              statusFlag: false,
                            );
                      },
                      child: Builder(
                        builder: (_) {
                          // 1) Loading => ListView قابلة للسحب
                          if (isLoadingPriceOffers) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 200),
                                Center(
                                    child: SpinKitDoubleBounce(
                                        color: Color(0xFF2196F3))),
                                SizedBox(height: 600),
                                // يضمن سحب للأسفل على أي حال
                              ],
                            );
                          }
            
                          // 2) Error => برضه داخل ListView قابلة للسحب
                          if (isErrorPriceOffers) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.all(16.w),
                              children: [
                                _buildErrorDialog(
                                    context,
                                    (state as ReceivePriceOffersError).message,
                                    localizations),
                              ],
                            );
                          }
            
                          // 3) Empty
                          if (priceOffers.isEmpty && !isLoadingPriceOffers) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.all(16.w),
                              children: [
                                _buildNoOffersDialog(context, localizations),
                              ],
                            );
                          }
            
                          // 4) Success + بيانات
                          return ListView.builder(
                            controller: _scrollController,
                            // ✅ لازم علشان onScroll تشتغل
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: priceOffers.length,
                            // + (_hasMore ? 1 : 0),
                            // ✅
                            itemBuilder: (context, index) {
                              // if (index == priceOffers.length) {
                              //   return Padding(
                              //     padding:
                              //         EdgeInsets.symmetric(vertical: 16.h),
                              //     child: Center(
                              //       child: SpinKitDoubleBounce(
                              //           color: Color(0xFF2196F3)),
                              //     ),
                              //   );
                              // }
            
                              final offerRequest = priceOffers[index];
                              return _buildPriceOfferRequestCard(
                                context,
                                offerRequest,
                                localizations.isArabic(),
                                localizations,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (isLoadingPriceOffers)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withOpacity(0.8),
                          child: Center(
                            child: SpinKitDoubleBounce(
                              color: Color(0xFF2196F3),
                              size: 40.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: CColors.secondary,
            fontFamily: 'Almarai',
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF666666),
            fontFamily: 'Almarai',
          ),
        ),
      ],
    );
  }

  _buildErrorDialog(
      BuildContext context, String message, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.sp,
            color: const Color(0xFFE53935),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF666666),
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<ReceiveOffersCubit>().fetchOffers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              localizations.translate('retryAttempt'),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontFamily: 'Almarai',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoOffersDialog(
      BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80.sp,
            color: const Color(0xFF4CAF50),
          ),
          SizedBox(height: 16.h),
          Text(
            localizations.translate('noOffersAvailable'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF666666),
              fontFamily: 'Almarai',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceOfferRequestCard(
      BuildContext context,
      OfferPricing offerRequest,
      bool isArabic,
      AppLocalizations localizations) {
    return Column(
      children: [
        // Request details card
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailRow(localizations.translate('facilityNameLabel'),
                      offerRequest.companyName, isArabic),
                  SizedBox(width: 8.w),
                  Container(
                    decoration: BoxDecoration(
                      //yellow
                      color: offerRequest.status == 'pending'
                          ? const Color(0xFFFBC02D)
                          : offerRequest.status == 'completed'
                              ? const Color(0xFF4CAF50)
                              : offerRequest.status == 'cancel'
                                  ? const Color(0xFFE53935)
                                  : offerRequest.status == "inProgress"
                                      ? const Color(0xFF2196F3)
                                      : const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/hour.svg',
                            width: 16.w,
                            height: 16.h,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            SharedPref.preferences
                                        .getString(PrefKeys.languageCode) ==
                                    'ar'
                                ? getRequestStatus(offerRequest.status)
                                : offerRequest.status.trim().toUpperCase(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Almarai',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              _buildDetailRow(localizations.translate('branchNameLabel'),
                  offerRequest.branchName, isArabic),
              SizedBox(height: 8.h),
              _buildDetailRow(localizations.translate('requestTypeLabel'),
                  _getRequestsType(offerRequest.requestType), isArabic),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailRow(localizations.translate('requestNumberLabel'),
                      offerRequest.requestNumber, isArabic),
                  SizedBox(width: 8.w),
                  // Spacer(),
                  // //button cancel request
                  // ElevatedButton(
                  //   onPressed: () {
                  //     if (offerRequest.status == 'pending') {
                  //       context
                  //           .read<ReceiveOffersCubit>()
                  //           .cancelPriceOffer(offerRequest.id);
                  //     }
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: offerRequest.status != 'pending'
                  //         ? Colors.grey
                  //         : Colors.white,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8.r),
                  //     ),
                  //   ),
                  //   child: Text(
                  //     localizations.translate('cancelRequest'),
                  //     style: TextStyle(
                  //       fontSize: 12.sp,
                  //       color: offerRequest.status != 'pending'
                  //           ? Colors.white
                  //           : Colors.red,
                  //       fontFamily: 'Almarai',
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getRequestsType(requestType) {
    switch (requestType) {
      case 'InstallationCertificate':
        return 'طلب دار رخص فورية';
      case 'FireExtinguisher':
        return 'طفايات حريق';
      case 'FireAlarm':
        return 'أجهزة إنذار حريق';
      case 'MaintenanceContract':
        return 'عقد صيانة';
      case 'EngineeringInspection':
        if (SharedPref.preferences.getString(PrefKeys.languageCode) == 'ar') {
          return 'فحص هندسي';
        } else {
          return 'Engineering Inspection';
        }
      default:
        return requestType;
    }
  }

  String getRequestStatus(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'inProgress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
