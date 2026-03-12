import '../models/supplier.dart';

class SupplierRepository {
  // Singleton pattern
  static final SupplierRepository _instance = SupplierRepository._internal();
  factory SupplierRepository() => _instance;
  SupplierRepository._internal();

  // Mock data
  final List<Supplier> _suppliers = [
    Supplier(
      id: 'S001',
      name: 'Fresh Farm Co.',
      email: 'contact@freshfarm.com',
      phone: '0901234567',
      address: '123 Nguyen Van Linh, Q7, Ho Chi Minh City',
      catalogItems: [
        CatalogItem(sku: 'FF001', productName: 'Organic Milk 1L', wholesalePrice: 18000),
        CatalogItem(sku: 'FF002', productName: 'Free-range Eggs (10pcs)', wholesalePrice: 35000),
        CatalogItem(sku: 'FF003', productName: 'Butter 200g', wholesalePrice: 45000),
      ],
    ),
    Supplier(
      id: 'S002',
      name: 'Green Valley Produce',
      email: 'sales@greenvalley.vn',
      phone: '0912345678',
      address: '45 Tran Hung Dao, Q1, Ho Chi Minh City',
      catalogItems: [
        CatalogItem(sku: 'GV001', productName: 'Apple Fuji 1kg', wholesalePrice: 55000),
        CatalogItem(sku: 'GV002', productName: 'Orange Valencia 1kg', wholesalePrice: 40000),
        CatalogItem(sku: 'GV003', productName: 'Banana 1kg', wholesalePrice: 20000),
        CatalogItem(sku: 'GV004', productName: 'Mango Xoai Cat 1kg', wholesalePrice: 60000, available: false),
      ],
    ),
    Supplier(
      id: 'S003',
      name: 'Sunrise Bakery',
      email: 'order@sunrisebakery.vn',
      phone: '0923456789',
      address: '78 Le Loi, Q3, Ho Chi Minh City',
      catalogItems: [
        CatalogItem(sku: 'SB001', productName: 'White Bread Loaf', wholesalePrice: 22000),
        CatalogItem(sku: 'SB002', productName: 'Whole Wheat Bread', wholesalePrice: 28000),
      ],
    ),
  ];

  List<Supplier> getAll() => List.unmodifiable(_suppliers);

  Supplier? getById(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateCatalogItem(String supplierId, String sku, {double? price, bool? available}) {
    final supplier = getById(supplierId);
    if (supplier == null) return;
    final idx = supplier.catalogItems.indexWhere((c) => c.sku == sku);
    if (idx == -1) return;
    final old = supplier.catalogItems[idx];
    supplier.catalogItems[idx] = old.copyWith(
      wholesalePrice: price ?? old.wholesalePrice,
      available: available ?? old.available,
    );
  }
}
