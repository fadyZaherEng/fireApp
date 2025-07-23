class Mall {
  final String id;
  final String name;
  final String address;
  final LocationData? location;

  Mall({
    required this.id,
    required this.name,
    required this.address,
    this.location,
  });

  factory Mall.fromJson(Map<String, dynamic> json) {
    return Mall(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      location: json['location'] != null
          ? LocationData.fromJson(json['location'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'location': location?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mall &&
        other.id == id &&
        other.name == name &&
        other.address == address;
  }

  @override
  int get hashCode => Object.hash(id, name, address);
}

class LocationData {
  final String type;
  final List<double> coordinates;

  LocationData({
    required this.type,
    required this.coordinates,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      type: json['type'] ?? 'Point',
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.type == type &&
        other.coordinates.toString() == coordinates.toString();
  }

  @override
  int get hashCode => Object.hash(type, coordinates.toString());
}

class MallListResponse {
  final List<Mall> malls;
  final int count;

  MallListResponse({
    required this.malls,
    required this.count,
  });

  factory MallListResponse.fromJson(Map<String, dynamic> json) {
    return MallListResponse(
      malls: (json['result'] as List<dynamic>?)
              ?.map((item) => Mall.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': malls.map((mall) => mall.toJson()).toList(),
      'count': count,
    };
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });
}
