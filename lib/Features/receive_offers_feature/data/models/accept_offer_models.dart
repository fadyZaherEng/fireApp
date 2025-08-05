class AcceptOfferResponse {
  final AcceptedOffer result;
  final Invoice invoice;

  AcceptOfferResponse({
    required this.result,
    required this.invoice,
  });

  factory AcceptOfferResponse.fromJson(Map<String, dynamic> json) {
    return AcceptOfferResponse(
      result: AcceptedOffer.fromJson(json['result']),
      invoice: Invoice.fromJson(json['invoice']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.toJson(),
      'invoice': invoice.toJson(),
    };
  }
}

class AcceptedOffer {
  final String id;
  final String provider;
  final String consumerRequest;
  final double price;
  final String status;
  final String responsibleEmployee;
  final int createdAt;
  final int visitPrice;
  final int emergencyVisitPrice;
  final int v;

  AcceptedOffer({
    required this.id,
    required this.provider,
    required this.consumerRequest,
    required this.price,
    required this.status,
    required this.responsibleEmployee,
    required this.createdAt,
    required this.v,
    required this.visitPrice,
    required this.emergencyVisitPrice,
  });

  factory AcceptedOffer.fromJson(Map<String, dynamic> json) {
    return AcceptedOffer(
      id: json['_id'] ?? '',
      provider: json['provider'] ?? '',
      consumerRequest: json['consumerRequest'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      responsibleEmployee: json['responsibleEmployee'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      v: json['__v'] ?? 0,
      visitPrice: json['visitPrice'] ?? 0,
      emergencyVisitPrice: json['emergencyVisitPrice'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'provider': provider,
      'consumerRequest': consumerRequest,
      'price': price,
      'status': status,
      'responsibleEmployee': responsibleEmployee,
      'createdAt': createdAt,
      '__v': v,
    };
  }
}

class Invoice {
  final String id;
  final String provider;
  final String consumer;
  final String branch;
  final String offer;
  final String currency;
  final double price;
  final double fees;
  final String status;
  final int createdAt;
  final int v;

  Invoice({
    required this.id,
    required this.provider,
    required this.consumer,
    required this.branch,
    required this.offer,
    required this.currency,
    required this.price,
    required this.fees,
    required this.status,
    required this.createdAt,
    required this.v,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['_id'] ?? '',
      provider: json['provider'] ?? '',
      consumer: json['consumer'] ?? '',
      branch: json['branch'] ?? '',
      offer: json['offer'] ?? '',
      currency: json['currency'] ?? 'SAR',
      price: (json['price'] ?? 0).toDouble(),
      fees: (json['fees'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'provider': provider,
      'consumer': consumer,
      'branch': branch,
      'offer': offer,
      'currency': currency,
      'price': price,
      'fees': fees,
      'status': status,
      'createdAt': createdAt,
      '__v': v,
    };
  }

  double get totalAmount => price + fees;
}
