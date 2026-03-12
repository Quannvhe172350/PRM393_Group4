class CatalogItem {
  final String sku;
  final String productName;
  double wholesalePrice;
  bool available;

  CatalogItem({
    required this.sku,
    required this.productName,
    required this.wholesalePrice,
    this.available = true,
  });

  CatalogItem copyWith({
    String? sku,
    String? productName,
    double? wholesalePrice,
    bool? available,
  }) {
    return CatalogItem(
      sku: sku ?? this.sku,
      productName: productName ?? this.productName,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      available: available ?? this.available,
    );
  }
}

class Supplier {
  final String id;
  String name;
  String email;
  String phone;
  String address;
  List<CatalogItem> catalogItems;

  Supplier({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    List<CatalogItem>? catalogItems,
  }) : catalogItems = catalogItems ?? [];
}
