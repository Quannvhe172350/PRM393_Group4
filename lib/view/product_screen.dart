import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../models/product.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = AppDatabase.instance.getProducts();
  }

  Future<void> _refresh() async {
    setState(_loadProducts);
    await _productsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm nào'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.shopping_bag, color: Colors.white),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Giá: ${product.price.toStringAsFixed(0)}đ"),
                        Text("Tồn kho: ${product.quantity}"),
                        if (product.categoryName != null)
                          Text("Danh mục: ${product.categoryName}"),
                      ],
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Add"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${product.name} added to cart"),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
