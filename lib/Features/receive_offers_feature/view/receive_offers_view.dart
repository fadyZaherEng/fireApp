import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
 import 'package:safetyZone/Features/success/success_screen.dart';
import '../../../core/localization/app_localizations.dart';
import '../cubit/receive_offers_cubit.dart';
import '../cubit/receive_offers_states.dart';
import '../data/models/offer_models.dart';
import '../data/services/receive_offers_api_service.dart';
import '../../payment_feature/view/payment_view.dart';

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

class ReceiveOffersContent extends StatelessWidget {
  const ReceiveOffersContent({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
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
      ),
      body: BlocConsumer<ReceiveOffersCubit, ReceiveOffersState>(
        listener: (context, state) {
          if (state is OfferActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<ReceiveOffersCubit>().clearActionState();
          } else if (state is OfferActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            context.read<ReceiveOffersCubit>().clearActionState();
          } else if (state is OfferAcceptedNavigateToPayment) {
            // Navigate to payment page
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => PaymentView(invoice: state.invoice),
              ),
            )
                .then((_) {
              // Refresh offers when coming back from payment
              context.read<ReceiveOffersCubit>().fetchOffers();
            });
          }
        },
        builder: (context, state) {
          final localizations = AppLocalizations.of(context);

          if (state is ReceiveOffersLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2196F3),
              ),
            );
          } else if (state is ReceiveOffersError) {
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
                    state.message,
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
          } else if (state is ReceiveOffersSuccess) {
            final offers = context.read<ReceiveOffersCubit>().offers;

            if (offers.isEmpty) {
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

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ReceiveOffersCubit>().fetchOffers();
              },
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: ListView.builder(
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offerRequest = offers[index];
                    return _buildOfferRequestCard(context, offerRequest);
                  },
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
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
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow(localizations.translate('facilityNameLabel'),
                  offerRequest.branch.employee.fullName, isArabic),
              SizedBox(height: 8.h),
              _buildDetailRow(localizations.translate('branchNameLabel'),
                  offerRequest.branch.branchName, isArabic),
              SizedBox(height: 8.h),
              _buildDetailRow(localizations.translate('requestTypeLabel'),
                  offerRequest.requestTypeDisplay, isArabic),
              SizedBox(height: 8.h),
              _buildDetailRow(localizations.translate('requestNumberLabel'),
                  offerRequest.requestNumber, isArabic),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Offers for this request
        ...offerRequest.offers.map((offer) => Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Company name and rating row
                  Row(
                    textDirection:
                        isArabic ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Expanded(
                        child: Text(
                          offer.provider.companyName,
                          textAlign:
                              isArabic ? TextAlign.right : TextAlign.left,
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                            fontFamily: 'Almarai',
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
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

                  SizedBox(height: 16.h),

                  // Info items row
                  Row(
                    textDirection:
                        isArabic ? TextDirection.rtl : TextDirection.ltr,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildInfoItem(Icons.schedule, offer.timeAgo, isArabic),
                      _buildInfoItem(Icons.print,
                          localizations.translate('print'), isArabic),
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
                  SizedBox(height: 16.h),
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
                              height: 40.h,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFE53935)),
                                borderRadius: BorderRadius.circular(20.r),
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
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xFFE53935)),
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
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Container(
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (offerRequest.is_Primary) {
                                          ///Navigate to success
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SuccessScreen())).then(
                                              (value) => context
                                                  .read<ReceiveOffersCubit>()
                                                  .fetchOffers());
                                        } else {
                                          context
                                              .read<ReceiveOffersCubit>()
                                              .acceptOffer(offer.id);
                                        }
                                      },
                                child: isLoading
                                    ? SizedBox(
                                        width: 16.w,
                                        height: 16.h,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
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
            )),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isArabic) {
    return Row(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
            fontFamily: 'Almarai',
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            textAlign: isArabic ? TextAlign.left : TextAlign.right,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF666666),
              fontFamily: 'Almarai',
            ),
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
}
