class SupplierProduct {
  final int? id;
  final int supplierId;
  final int productId;
  final double supplyPrice;
  final int supplierQuantity;
  final String? lastSupplyDate;

  // Joined fields (not stored in DB)
  final String? supplierName;
  final String? productName;
  final String? productDescription;
  final int? productQuantity;

  SupplierProduct({
    this.id,
    required this.supplierId,
    required this.productId,
    required this.supplyPrice,
    this.supplierQuantity = 0,
    this.lastSupplyDate,
    this.supplierName,
    this.productName,
    this.productDescription,
    this.productQuantity,
  });

  factory SupplierProduct.fromMap(Map<String, dynamic> map) {
    return SupplierProduct(
      id: map['id'] as int?,
      supplierId: map['supplier_id'] as int? ?? 0,
      productId: map['product_id'] as int? ?? 0,
      supplyPrice: (map['supply_price'] as num?)?.toDouble() ?? 0.0,
      supplierQuantity: (map['supplier_quantity'] as num?)?.toInt() ?? 0,
      lastSupplyDate: map['last_supply_date'] as String?,
      supplierName: map['supplier_name'] as String?,
      productName: map['product_name'] as String?,
      productDescription: map['product_description'] as String?,
      productQuantity: (map['product_quantity'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'supplier_id': supplierId,
      'product_id': productId,
      'supply_price': supplyPrice,
      'supplier_quantity': supplierQuantity,
      'last_supply_date': lastSupplyDate,
    };
  }
}
