import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safetyZone/Features/card_payment/card_payment_screen.dart';
import '../../receive_offers_feature/data/models/accept_offer_models.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_states.dart';

class PaymentView extends StatelessWidget {
  final Invoice invoice;

  const PaymentView({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentCubit()..setInvoiceData(invoice),
      child: PaymentContent(invoice: invoice),
    );
  }
}

class PaymentContent extends StatelessWidget {
  final Invoice invoice;

  const PaymentContent({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8EAF0),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'تعميد الطلب',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2196F3),
            fontFamily: 'Almarai',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF2196F3),
              size: 24.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back to home or offers page
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.settings,
                      color: const Color(0xFFE53935).withOpacity(.5),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'طلب خدم من مقدم الخدمة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE53935),
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h), // Price section
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceButton(
                        '${invoice.price.toInt()} ${invoice.currency}',
                        null,
                        isRed: true,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildPriceButton(
                        'قيمة العقد',
                        Icons.description,
                        isRed: false,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildPriceButton(
                        '${invoice.fees.toInt()}  ${invoice.currency}',
                        null,
                        isRed: true,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildPriceButton(
                        'العمولة',
                        Icons.percent,
                        isRed: false,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40.h),

                // Payment methods section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payment,
                            color: const Color(0xFFE53935),
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'وسائل الدفع',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE53935),
                              fontFamily: 'Almarai',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Payment method options
                      _buildPaymentMethodTile(
                        context,
                        PaymentMethod.visa,
                        'Visa',
                        'assets/images/visa_logo.png',
                        state,
                      ),
                      SizedBox(height: 16.h),
                      _buildPaymentMethodTile(
                        context,
                        PaymentMethod.mastercard,
                        'Mastercard',
                        'assets/images/mastercard_logo.png',
                        state,
                      ),
                      SizedBox(height: 16.h),
                      _buildPaymentMethodTile(
                        context,
                        PaymentMethod.paypal,
                        'Paypal',
                        'assets/images/paypal_logo.png',
                        state,
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceButton(String text, IconData? icon, {required bool isRed}) {
    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
          color: Color(isRed ? 0xFFE53935 : 0xFF2196F3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Color(isRed ? 0xFFE53935 : 0xFF2196F3),
                size: 10.sp,
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Color(isRed ? 0xFFE53935 : 0xFF2196F3),
                fontFamily: 'Almarai',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    BuildContext context,
    PaymentMethod method,
    String name,
    String assetPath,
    PaymentState state,
  ) {
    final cubit = context.read<PaymentCubit>();
    final isSelected = cubit.selectedPaymentMethod == method;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardPaymentScreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Payment method logo placeholder
            Image.asset(
              assetPath,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12.w),
            Text(
              name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
                fontFamily: 'Almarai',
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                cubit.selectPaymentMethod(method);
              },
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
