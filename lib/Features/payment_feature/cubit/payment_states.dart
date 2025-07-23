abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String message;

  PaymentSuccess(this.message);
}

class PaymentError extends PaymentState {
  final String message;

  PaymentError(this.message);
}

enum PaymentMethod { visa, mastercard, paypal }

class PaymentMethodSelected extends PaymentState {
  final PaymentMethod method;

  PaymentMethodSelected(this.method);
}
