class SupplierProduct {
  final int? id;
  final int supplierId;
  final int productId;
  final double supplyPrice;
  final String? lastSupplyDate;

  // Joined fields (not stored in DB)
  final String? supplierName;
  final String? productName;

  SupplierProduct({
    this.id,
    required this.supplierId,
    required this.productId,
    required this.supplyPrice,
    this.lastSupplyDate,
    this.supplierName,
    this.productName,
  });

  factory SupplierProduct.fromMap(Map<String, dynamic> map) {
    return SupplierProduct(
      id: map['id'] as int?,
      supplierId: map['supplier_id'] as int? ?? 0,
      productId: map['product_id'] as int? ?? 0,
      supplyPrice: (map['supply_price'] as num?)?.toDouble() ?? 0.0,
      lastSupplyDate: map['last_supply_date'] as String?,
      supplierName: map['supplier_name'] as String?,
      productName: map['product_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'supplier_id': supplierId,
      'product_id': productId,
      'supply_price': supplyPrice,
      'last_supply_date': lastSupplyDate,
    };
  }
}
