class ProductModel {
  final String id;
  final String name;
  final double price;
  final double discount;
  final double vat;
  final String sku;
  final String category;
  int stock;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.discount,
    required this.vat,
    required this.sku,
    required this.category,
    required this.stock,
    required this.imageUrl,
  });

  double get finalPrice => (price - discount) * (1 + vat);

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? discount,
    double? vat,
    String? sku,
    String? category,
    int? stock,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      vat: vat ?? this.vat,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
