import 'package:equatable/equatable.dart';

class HomeServiceModel extends Equatable {
  final String id;
  final String title;
  final String titleAr;
  final String image;
  final String? description;
  final String? descriptionAr;
  final bool isFeatured;
  final bool isActive;
  final int order;

  const HomeServiceModel({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.image,
    this.description,
    this.descriptionAr,
    this.isFeatured = false,
    this.isActive = true,
    this.order = 0,
  });

  factory HomeServiceModel.fromJson(Map<String, dynamic> json) {
    return HomeServiceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleAr: json['title_ar'] ?? '',
      image: json['image'] ?? '',
      description: json['description'],
      descriptionAr: json['description_ar'],
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'image': image,
      'description': description,
      'description_ar': descriptionAr,
      'is_featured': isFeatured,
      'is_active': isActive,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleAr,
        image,
        description,
        descriptionAr,
        isFeatured,
        isActive,
        order,
      ];
}

class UserModel extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String email;
  final String? phone;
  final String? profileImage;

  const UserModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.email,
    this.phone,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        email,
        phone,
        profileImage,
      ];
}
