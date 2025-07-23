class ProductItemResponse {
  final List<ProductItem> result;
  final int count;

  ProductItemResponse({
    required this.result,
    required this.count,
  });

  factory ProductItemResponse.fromJson(Map<String, dynamic> json) {
    return ProductItemResponse(
      result: (json['result'] as List<dynamic>?)
              ?.map(
                  (item) => ProductItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.map((item) => item.toJson()).toList(),
      'count': count,
    };
  }
}

class ProductItem {
  final String id;
  final String itemName;
  final String itemCode;
  final String image;
  final String supplierName;
  final double supplyPrice;
  final bool isDeleted;
  final String admin;
  final String type;
  final String alarmType;
  final String subCategory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  ProductItem({
    required this.id,
    required this.itemName,
    required this.itemCode,
    required this.image,
    required this.supplierName,
    required this.supplyPrice,
    required this.isDeleted,
    required this.admin,
    required this.type,
    required this.alarmType,
    required this.subCategory,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['_id'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      itemCode: json['itemCode'] as String? ?? '',
      image: json['image'] as String? ?? '',
      supplierName: json['supplierName'] as String? ?? '',
      supplyPrice: (json['supplyPrice'] as num?)?.toDouble() ?? 0.0,
      isDeleted: json['isDeleted'] as bool? ?? false,
      admin: json['admin'] as String? ?? '',
      type: json['type'] as String? ?? '',
      alarmType: json['alarmType'] as String? ?? '',
      subCategory: json['subCategory'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      version: json['__v'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'itemName': itemName,
      'itemCode': itemCode,
      'image': image,
      'supplierName': supplierName,
      'supplyPrice': supplyPrice,
      'isDeleted': isDeleted,
      'admin': admin,
      'type': type,
      'alarmType': alarmType,
      'subCategory': subCategory,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}
