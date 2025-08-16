import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:safetyZone/Features/contract/contract_screen.dart';
import 'package:safetyZone/Features/success/success_screen.dart';
import 'package:safetyZone/core/services/shared_pref/pref_keys.dart';
import 'package:safetyZone/core/services/shared_pref/shared_pref.dart';
import 'package:safetyZone/core/utils/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../cubit/receive_offers_cubit.dart';
import '../cubit/receive_offers_states.dart';
import '../data/models/offer_models.dart';
import '../data/services/receive_offers_api_service.dart';

class ReceiveOffersView extends StatelessWidget {
  const ReceiveOffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ReceiveOffersCubit(ReceiveOffersApiService())..fetchOffers(),
      child: const ReceiveOffersContent(),
    );
  }
}

class ReceiveOffersContent extends StatefulWidget {
  const ReceiveOffersContent({super.key});

  @override
  State<ReceiveOffersContent> createState() => _ReceiveOffersContentState();
}

class _ReceiveOffersContentState extends State<ReceiveOffersContent> {
  List<OfferRequest> offerRequests = [];
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
        );
    super.initState();
    _scrollController.addListener(_onScroll);
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
        builder: (context, state) => DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                localizations.translate('receiveOffers'),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2196F3),
                  fontFamily: 'Almarai',
                ),
              ),
              centerTitle: true,
              bottom: TabBar(
                onTap: (int index) {
                  if (index == 0) {
                    context.read<ReceiveOffersCubit>().fetchOffers();
                  } else if (index == 1) {
                    // Reset the page and isHaveMore when switching tabs
                    context.read<ReceiveOffersCubit>().fetchPriceOffers(
                          page: page,
                          limit: limit,
                        );
                  }
                },
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF4A4A4A),
                indicator: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Almarai',
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(localizations.translate('receiveOffers')),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            context
                                .read<ReceiveOffersCubit>()
                                .offers
                                .length
                                .toString(), // عداد الطلبات
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.sp),
                          ),
                        )
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(localizations.translate('pricingRequests')),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            context
                                .read<ReceiveOffersCubit>()
                                .priceOffers
                                .length
                                .toString(), // عداد الاستلام
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.sp),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: BlocBuilder<ReceiveOffersCubit, ReceiveOffersState>(
              builder: (context, state) {
                final localizations = AppLocalizations.of(context);
                final isLoading = state is ReceiveOffersLoading;
                final isError = state is ReceiveOffersError;
                final offers = context
                    .watch<ReceiveOffersCubit>()
                    .offers; // القائمة الحالية
                List<OfferPricing> priceOffers = context
                    .watch<ReceiveOffersCubit>()
                    .priceOffers; // قائمة الأسعار
                final isLoadingPriceOffers = state
                    is ReceivePriceOffersLoading; // حالة التحميل لطلبات الأسعار
                final isErrorPriceOffers = state
                    is ReceivePriceOffersError; // حالة الخطأ لطلبات الأسعار
                // if (state is ReceivePriceOffersSuccess) {
                //   if (page == 1) {
                //     priceOffers.clear(); // إذا كانت الصفحة الأولى، نبدأ من جديد
                //   }
                //   priceOffers.addAll(state.offersPrices);
                //   _isLoadingMore = false;
                //   _hasMore = state.offersPrices.length ==
                //       limit; // أقل من pageSize يعني مفيش بيانات تانية
                // }

                return Stack(
                  children: [
                    TabBarView(
                      children: [
                        // تبويب "استلام العروض"
                        RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<ReceiveOffersCubit>()
                                .fetchOffers();
                          },
                          child: Builder(
                            builder: (_) {
                              // 1) Loading => ListView قابلة للسحب
                              if (isLoading) {
                                return ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
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
                              if (isError) {
                                return ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(16.w),
                                  children: [
                                    _buildErrorDialog(
                                        context,
                                        (state as ReceiveOffersError).message,
                                        localizations),
                                  ],
                                );
                              }

                              // 3) Empty
                              if (offers.isEmpty && !isLoading && !isError) {
                                return ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(16.w),
                                  children: [
                                    _buildNoOffersDialog(
                                      context,
                                      localizations,
                                    ),
                                  ],
                                );
                              }

                              // 4) Success + بيانات
                              return ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: offers.length,
                                itemBuilder: (context, index) {
                                  final offerRequest = offers[index];
                                  return _buildOfferRequestCard(
                                    context,
                                    offerRequest,
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        RefreshIndicator(
                          onRefresh: () async {
                            page = 1;
                            _hasMore = true;
                            priceOffers.clear();
                            await context
                                .read<ReceiveOffersCubit>()
                                .fetchPriceOffers(
                                  page: page,
                                  limit: limit,
                                  isStart: true,
                                );
                          },
                          child: Builder(
                            builder: (_) {
                              // 1) Loading => ListView قابلة للسحب
                              if (isLoadingPriceOffers) {
                                return ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
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
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(16.w),
                                  children: [
                                    _buildErrorDialog(
                                        context,
                                        (state as ReceivePriceOffersError)
                                            .message,
                                        localizations),
                                  ],
                                );
                              }

                              // 3) Empty
                              if (priceOffers.isEmpty &&
                                  !isLoadingPriceOffers) {
                                return ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(16.w),
                                  children: [
                                    _buildNoOffersDialog(
                                        context, localizations),
                                  ],
                                );
                              }

                              // 4) Success + بيانات
                              return ListView.builder(
                                controller: _scrollController,
                                // ✅ لازم علشان onScroll تشتغل
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount:
                                    priceOffers.length + (_hasMore ? 1 : 0),
                                // ✅
                                itemBuilder: (context, index) {
                                  if (index == priceOffers.length) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.h),
                                      child: Center(
                                        child: SpinKitDoubleBounce(
                                            color: Color(0xFF2196F3)),
                                      ),
                                    );
                                  }

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
                      ],
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

  Widget _buildOfferRequestCard(
      BuildContext context, OfferRequest offerRequest) {
    final localizations = AppLocalizations.of(context);
    final isArabic = localizations.isArabic();

    return Column(
      children: [
        // Request details card
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),

            iconColor: const Color(0xFF4CAF50),
            collapsedIconColor: Colors.grey,
            // tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            childrenPadding: EdgeInsets.symmetric(horizontal: 8.w),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildDetailRow(localizations.translate('facilityNameLabel'),
                    offerRequest.branch.employee.fullName, isArabic),
                SizedBox(height: 2.h),
                _buildDetailRow(localizations.translate('branchNameLabel'),
                    offerRequest.branch.branchName, isArabic),
                SizedBox(height: 2.h),
                _buildDetailRow(localizations.translate('requestTypeLabel'),
                    _getRequestType(offerRequest.requestTypeDisplay), isArabic),
                SizedBox(height: 2.h),
                _buildDetailRow(localizations.translate('requestNumberLabel'),
                    offerRequest.requestNumber, isArabic),
              ],
            ),
            children: offerRequest.offers.map((offer) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6.h),
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    // Company name and rating row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            offer.provider.companyName,
                            textAlign:
                                isArabic ? TextAlign.right : TextAlign.left,
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                              fontFamily: 'Almarai',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: const Color(0xFFFFA726),
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '4.9',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF333333),
                                  fontFamily: 'Almarai',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    // Info items row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildInfoItem(Icons.schedule, offer.timeAgo, isArabic),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContractScreen(),
                              ),
                            );
                          },
                          child: _buildInfoItem(Icons.print,
                              localizations.translate('print'), isArabic),
                        ),
                        Row(
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/money.svg',
                              width: 16.w,
                              height: 16.h,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${offer.price}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: 'Almarai',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    BlocBuilder<ReceiveOffersCubit, ReceiveOffersState>(
                      builder: (context, state) {
                        final isLoading = state is OfferActionLoading &&
                            state.offerId == offer.id;

                        return Row(
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Expanded(
                              child: Container(
                                height: 36.h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFE53935)),
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          context
                                              .read<ReceiveOffersCubit>()
                                              .rejectOffer(offer.id);
                                        },
                                  child: isLoading
                                      ? SizedBox(
                                          width: 16.w,
                                          height: 16.h,
                                          child: const SpinKitDoubleBounce(
                                            color: Color(0xFFE53935),
                                          ),
                                        )
                                      : Text(
                                          localizations.translate('reject'),
                                          textAlign: TextAlign.center,
                                          textDirection: isArabic
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFFE53935),
                                            fontFamily: 'Almarai',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(width: 24.w),
                            Expanded(
                              child: Container(
                                height: 36.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (offerRequest.offers.isNotEmpty &&
                                              offerRequest
                                                  .offers.first.is_Primary) {
                                            ///Navigate to success
                                            Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SuccessScreen()))
                                                .then((value) {
                                              context
                                                  .read<ReceiveOffersCubit>()
                                                  .acceptOffer(offer.id, false);
                                            });
                                          } else {
                                            context
                                                .read<ReceiveOffersCubit>()
                                                .acceptOffer(offer.id, true);
                                          }
                                        },
                                  child: isLoading
                                      ? SizedBox(
                                          width: 16.w,
                                          height: 16.h,
                                          child: const SpinKitDoubleBounce(
                                              color: Colors.white),
                                        )
                                      : Text(
                                          localizations.translate('accept'),
                                          textAlign: TextAlign.center,
                                          textDirection: isArabic
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.white,
                                            fontFamily: 'Almarai',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 8.h),
      ],
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

  Widget _buildInfoItem(IconData icon, String text, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF666666),
            size: 16.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF666666),
              fontFamily: 'Almarai',
            ),
          ),
        ],
      ),
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
                      color: const Color(0xFFFBC02D),
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
                  Spacer(),
                  //button cancel request
                  ElevatedButton(
                    onPressed: () {
                      if (offerRequest.status == 'pending') {
                        context.read<ReceiveOffersCubit>().cancelPriceOffer();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: offerRequest.status != 'pending'
                          ? Colors.grey
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      localizations.translate('cancelRequest'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: offerRequest.status != 'pending'
                            ? Colors.white
                            : Colors.red,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ),
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

  String _getRequestType(String requestTypeDisplay) {
    if (requestTypeDisplay == 'EngineeringInspection') {
      if (SharedPref.preferences.getString(PrefKeys.languageCode) == 'ar') {
        return 'فحص هندسي';
      } else {
        return 'Engineering Inspection';
      }
    }
    return requestTypeDisplay;
  }

  // export enum RequestStatusEnum {
  // Pending = 'pending',
  // InProgress = "inProgress",
  // Completed = 'completed',
  // Cancelled = 'cancelled'
  // }
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
