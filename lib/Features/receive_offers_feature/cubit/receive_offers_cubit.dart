import 'package:logger/logger.dart';
import '../../../core/base/base_cubit.dart';
import '../data/models/offer_models.dart';
 import '../data/services/receive_offers_api_service.dart';
import 'receive_offers_states.dart';

class ReceiveOffersCubit extends BaseCubit<ReceiveOffersState> {
  final ReceiveOffersApiService _apiService;
  final Logger _logger = Logger();

  List<OfferRequest> _offers = [];

  ReceiveOffersCubit(this._apiService) : super(ReceiveOffersInitial());

  List<OfferRequest> get offers => _offers;
  Future<void> fetchOffers() async {
    try {
      emit(ReceiveOffersLoading());
      _logger.i('Fetching offers...');

      final response = await _apiService.getOffers();
      _offers = response.result;

      _logger.i('Successfully fetched ${_offers.length} offers');
      emit(ReceiveOffersSuccess(_offers));
    } catch (e) {
      _logger.e('Error fetching offers: $e');
      String errorMessage = 'حدث خطأ أثناء جلب العروض';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        errorMessage = 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى';
      } else if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        errorMessage = 'انتهت صلاحية جلستك، يرجى تسجيل الدخول مرة أخرى';
      } else if (e.toString().contains('500')) {
        errorMessage = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
      }

      emit(ReceiveOffersError(errorMessage));
    }
  }

  Future<void> acceptOffer(String offerId,bool isNavigate) async {
    if (isClosed) return;

    try {
      emit(OfferActionLoading(offerId));
      _logger.i('Accepting offer: $offerId');

      final response = await _apiService.acceptOffer(offerId);
      if (isClosed) return;

      _logger.i('Successfully accepted offer: $offerId');

      // Navigate to payment instead of showing success message
      if (!isClosed&&isNavigate) {
        emit(OfferAcceptedNavigateToPayment(response.invoice));
      }else{
        emit(OfferActionSuccess('تم قبول العرض بنجاح'));
      }
    } catch (e) {
      _logger.e('Error accepting offer: $e');
      String errorMessage = 'حدث خطأ أثناء قبول العرض';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        errorMessage = 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى';
      } else if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        errorMessage = 'انتهت صلاحية جلستك، يرجى تسجيل الدخول مرة أخرى';
      } else if (e.toString().contains('500')) {
        errorMessage = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
      }

      if (!isClosed) {
        emit(OfferActionError(errorMessage));
      }
    }
  }

  Future<void> rejectOffer(String offerId) async {
    if (isClosed) return;

    try {
      emit(OfferActionLoading(offerId));
      _logger.i('Rejecting offer: $offerId');

      await _apiService.rejectOffer(offerId);
      if (isClosed) return;

      _logger.i('Successfully rejected offer: $offerId');
      if (!isClosed) {
        emit(OfferActionSuccess('تم رفض العرض'));
      }

      // Refresh offers after action
      await fetchOffers();
    } catch (e) {
      _logger.e('Error rejecting offer: $e');
      String errorMessage = 'حدث خطأ أثناء رفض العرض';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        errorMessage = 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى';
      } else if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        errorMessage = 'انتهت صلاحية جلستك، يرجى تسجيل الدخول مرة أخرى';
      } else if (e.toString().contains('500')) {
        errorMessage = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
      }

      if (!isClosed) {
        emit(OfferActionError(errorMessage));
      }
    }
  }

  void clearActionState() {
    if (!isClosed &&
        (state is OfferActionSuccess || state is OfferActionError)) {
      emit(ReceiveOffersSuccess(_offers));
    }
  }
}
