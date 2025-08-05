import '../data/models/offer_models.dart';
import '../data/models/accept_offer_models.dart';

abstract class ReceiveOffersState {}

class ReceiveOffersInitial extends ReceiveOffersState {}

class ReceiveOffersLoading extends ReceiveOffersState {}

class ReceiveOffersSuccess extends ReceiveOffersState {
  final List<OfferRequest> offers;

  ReceiveOffersSuccess(this.offers);
}

class ReceiveOffersError extends ReceiveOffersState {
  final String message;

  ReceiveOffersError(this.message);
}

class OfferActionLoading extends ReceiveOffersState {
  final String offerId;

  OfferActionLoading(this.offerId);
}

class OfferActionSuccess extends ReceiveOffersState {
  final String message;

  OfferActionSuccess(this.message);
}

class OfferActionError extends ReceiveOffersState {
  final String message;

  OfferActionError(this.message);
}

class OfferAcceptedNavigateToPayment extends ReceiveOffersState {
  final Invoice invoice;

  final int visitPrice;
  final int emergencyVisitPrice;
  OfferAcceptedNavigateToPayment(this.invoice, this.visitPrice, this.emergencyVisitPrice);
}
