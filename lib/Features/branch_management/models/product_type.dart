class ProductType {
  final String id;
  final String nameKey;
  final String imagePath;
  final String? type;
  final String? subCategory;
  final String? alarmType;
  final String? madeIn;

  ProductType({
    required this.id,
    required this.nameKey,
    required this.imagePath,
    this.type,
    this.subCategory,
    this.alarmType,
    this.madeIn,
  });

  ProductType copy() {
    return ProductType(
      id: id,
      nameKey: nameKey,
      imagePath: imagePath,
      type: type,
      subCategory: subCategory,
      alarmType: alarmType,
      madeIn: madeIn,
    );
  }

}
