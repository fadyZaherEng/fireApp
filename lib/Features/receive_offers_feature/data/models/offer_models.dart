class OfferResponse {
  final List<OfferRequest> result;
  final int count;

  OfferResponse({
    required this.result,
    required this.count,
  });

  factory OfferResponse.fromJson(Map<String, dynamic> json) {
    return OfferResponse(
      result: (json['result'] as List<dynamic>)
          .map((item) => OfferRequest.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int,
    );
  }
}

class OfferRequest {
  final String id;
  final Consumer consumer;
  final Branch branch;
  final String requestNumber;
  final String requestType;
  final String status;
  final int createdAt;
  final List<Offer> offers;

  OfferRequest({
    required this.id,
    required this.consumer,
    required this.branch,
    required this.requestNumber,
    required this.requestType,
    required this.status,
    required this.createdAt,
    required this.offers,
    });

  factory OfferRequest.fromJson(Map<String, dynamic> json) {
    return OfferRequest(
      id: json['_id'] as String,
      consumer: Consumer.fromJson(json['consumer'] as Map<String, dynamic>),
      branch: Branch.fromJson(json['branch'] as Map<String, dynamic>),
      requestNumber: json['requestNumber'] as String,
      requestType: json['requestType'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as int,
      offers: (json['offers'] as List<dynamic>)
          .map((item) => Offer.fromJson(item as Map<String, dynamic>))
          .toList(),

    );
  }

  String get requestTypeDisplay {
    switch (requestType) {
      case 'InstallationCertificate':
        return 'طلب دار رخص فورية';
      case 'FireExtinguisher':
        return 'طفايات حريق';
      case 'FireAlarm':
        return 'أجهزة إنذار حريق';
      case 'MaintenanceContract':
        return 'عقد صيانة';
      default:
        return requestType;
    }
  }

  DateTime get createdDate => DateTime.fromMillisecondsSinceEpoch(createdAt);

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdDate);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }
}

class Consumer {
  final String id;

  Consumer({required this.id});

  factory Consumer.fromJson(Map<String, dynamic> json) {
    return Consumer(
      id: json['_id'] as String,
    );
  }
}

class Branch {
  final Location location;
  final String id;
  final String branchName;
  final Employee employee;
  final String address;

  Branch({
    required this.location,
    required this.id,
    required this.branchName,
    required this.employee,
    required this.address,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      id: json['_id'] as String,
      branchName: json['branchName'] as String,
      employee: Employee.fromJson(json['employee'] as Map<String, dynamic>),
      address: json['address'] as String,
    );
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

class Employee {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String profileImage;
  final String employeeType;

  Employee({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.profileImage,
    required this.employeeType,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      profileImage: json['profileImage'] as String,
      employeeType: json['employeeType'] as String,
    );
  }
}

class Offer {
  final String id;
  final Provider provider;
  final double price;
  final int createdAt;
  final bool is_Primary;


  Offer({
    required this.id,
    required this.provider,
    required this.price,
    required this.createdAt,
    required this.is_Primary,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'] as String,
      provider: Provider.fromJson(json['provider'] as Map<String, dynamic>),
      price: (json['price'] as num).toDouble(),
      createdAt: json['createdAt'] as int,
      is_Primary: json['is_Primary'] as bool,
    );
  }

  DateTime get createdDate => DateTime.fromMillisecondsSinceEpoch(createdAt);

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdDate);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }
}

class Provider {
  final String id;
  final String companyName;
  final String image;
  final String phoneNumber;

  Provider({
    required this.id,
    required this.companyName,
    required this.image,
    required this.phoneNumber,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['_id'] as String,
      companyName: json['companyName'] as String,
      image: json['image'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}
