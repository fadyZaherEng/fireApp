import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_states.dart';
import '../../receive_offers_feature/data/models/accept_offer_models.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  Invoice? _currentInvoice;
  PaymentMethod? _selectedPaymentMethod;

  Invoice? get currentInvoice => _currentInvoice;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;

  void setInvoiceData(Invoice invoice) {
    if (isClosed) return;
    _currentInvoice = invoice;
    emit(PaymentInitial());
  }

  void selectPaymentMethod(PaymentMethod method) {
    if (isClosed) return;
    _selectedPaymentMethod = method;
    emit(PaymentMethodSelected(method));
  }

  Future<void> processPayment() async {
    if (isClosed) return;

    if (_selectedPaymentMethod == null) {
      if (!isClosed) {
        emit(PaymentError('يرجى اختيار طريقة الدفع'));
      }
      return;
    }

    if (_currentInvoice == null) {
      if (!isClosed) {
        emit(PaymentError('لا توجد فاتورة للدفع'));
      }
      return;
    }

    try {
      emit(PaymentLoading());

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      if (isClosed) return;

      // Here you would integrate with actual payment gateway
      // For now, we'll simulate a successful payment

      if (!isClosed) {
        emit(PaymentSuccess('تم الدفع بنجاح'));
      }
    } catch (e) {
      if (!isClosed) {
        emit(PaymentError('فشل في عملية الدفع: ${e.toString()}'));
      }
    }
  }

  String getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.visa:
        return 'Visa';
      case PaymentMethod.mastercard:
        return 'Mastercard';
      case PaymentMethod.paypal:
        return 'Paypal';
    }
  }

  String getPaymentMethodAsset(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.visa:
        return 'assets/images/visa.png';
      case PaymentMethod.mastercard:
        return 'assets/images/mastercard.png';
      case PaymentMethod.paypal:
        return 'assets/images/paypal.png';
    }
  }
}
