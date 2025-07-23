class BranchLocation {
  final String type;
  final List<double> coordinates;

  BranchLocation({
    required this.type,
    required this.coordinates,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  factory BranchLocation.fromJson(Map<String, dynamic> json) {
    return BranchLocation(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates'] ?? []),
    );
  }
}

class WorkingDay {
  final String day;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String? id;

  WorkingDay({
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    this.id,
  });
  Map<String, dynamic> toJson() {
    final json = {
      'day': day,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
    };
    if (id != null) {
      json['_id'] = id!;
    }
    return json;
  }

  factory WorkingDay.fromJson(Map<String, dynamic> json) {
    return WorkingDay(
      day: json['day'] ?? '',
      startHour: json['startHour'] ?? 0,
      startMinute: json['startMinute'] ?? 0,
      endHour: json['endHour'] ?? 0,
      endMinute: json['endMinute'] ?? 0,
      id: json['_id'],
    );
  }
}

class BranchItem {
  final String itemId;
  final int quantity;
  final String? id;

  BranchItem({
    required this.itemId,
    required this.quantity,
    this.id,
  });
  Map<String, dynamic> toJson() {
    final json = {
      'item_id': itemId,
      'quantity': quantity,
    };
    if (id != null) {
      json['_id'] = id!;
    }
    return json;
  }

  factory BranchItem.fromJson(Map<String, dynamic> json) {
    return BranchItem(
      itemId: json['item_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      id: json['_id'],
    );
  }
}

class CreateBranchRequest {
  final String branchName;
  final String employee;
  final BranchLocation location;
  final String address;
  final String mall;
  final int space;
  final String systemType;
  final List<WorkingDay> workingDays;

  CreateBranchRequest({
    required this.branchName,
    required this.employee,
    required this.location,
    required this.address,
    required this.mall,
    required this.space,
    required this.systemType,
    required this.workingDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'branchName': branchName,
      'employee': employee,
      'location': location.toJson(),
      'address': address,
      'mall': mall,
      'space': space,
      'systemType': systemType,
      'workingDays': workingDays.map((day) => day.toJson()).toList(),
    };
  }
}
class Items {
  final List<BranchItem> alarmItem;
  final List<BranchItem> fireSystemItem;
  final List<BranchItem> fireExtinguisherItem;

  Items({
    required this.alarmItem,
    required this.fireSystemItem,
    required this.fireExtinguisherItem,
  });
  //to json
  Map<String, dynamic> toJson() {
    return {
      'alarmItem': alarmItem.map((item) => item.toJson()).toList(),
      'fireSystemItem': fireSystemItem.map((item) => item.toJson()).toList(),
      'fireExtinguisherItem': fireExtinguisherItem.map((item) => item.toJson()).toList(),
    };
  }
  //from json
  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      alarmItem: List<BranchItem>.from(json['alarmItem']?.map((item) => BranchItem.fromJson(item)) ?? []),
      fireSystemItem: List<BranchItem>.from(json['fireSystemItem']?.map((item) => BranchItem.fromJson(item)) ?? []),
      fireExtinguisherItem: List<BranchItem>.from(json['fireExtinguisherItem']?.map((item) => BranchItem.fromJson(item)) ?? []),
    );
  }
}
class FireItems {
  final List<BranchItem> fireExtinguisherItem;

  FireItems({
    required this.fireExtinguisherItem,
  });
  //to json
  Map<String, dynamic> toJson() {
    return {
      'fireExtinguisherItem': fireExtinguisherItem.map((item) => item.toJson()).toList(),
    };
  }
  //from json
  factory FireItems.fromJson(Map<String, dynamic> json) {
    return FireItems(
      fireExtinguisherItem: List<BranchItem>.from(json['fireExtinguisherItem']?.map((item) => BranchItem.fromJson(item)) ?? []),
    );
  }
}
class AddItemsRequest {
  final  Items items;
  final bool status;

  AddItemsRequest({
    required this.items,
    this.status = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.toJson(),
      'status': status,
    };
  }
}
class AddFireItemsRequest {
  final  FireItems items;
  final bool status;

  AddFireItemsRequest({
    required this.items,
    this.status = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.toJson(),
      'status': status,
    };
  }
}

class BranchResponse {
  final String id;
  final String branchName;
  final String employee;
  final String address;
  final BranchLocation location;
  final String mall;
  final int space;
  final String systemType;
  final String? consumer;
  final List<WorkingDay> workingDays;
  final List<BranchItem> items;
  final int? createdAt;
  final int? v;

  BranchResponse({
    required this.id,
    required this.branchName,
    required this.employee,
    required this.address,
    required this.location,
    required this.mall,
    required this.space,
    required this.systemType,
    this.consumer,
    required this.workingDays,
    required this.items,
    this.createdAt,
    this.v,
  });

  factory BranchResponse.fromJson(Map<String, dynamic> json) {
    return BranchResponse(
      id: json['_id'] ?? '',
      branchName: json['branchName'] ?? '',
      employee: json['employee'] ?? '',
      address: json['address'] ?? '',
      location: BranchLocation.fromJson(json['location'] ?? {}),
      mall: json['mall'] ?? '',
      space: json['space'] ?? 0,
      systemType: json['systemType'] ?? '',
      consumer: json['consumer'],
      workingDays: (json['workingDays'] as List<dynamic>? ?? [])
          .map((day) => WorkingDay.fromJson(day))
          .toList(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => BranchItem.fromJson(item))
          .toList(),
      createdAt: json['createdAt'],
      v: json['__v'],
    );
  }
}
