import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import '../../db/app_database.dart';
import 'supplier_detail_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final AppDatabase _db = AppDatabase.instance;
  List<Supplier> _suppliers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoading = true);
    final data = await _db.getSuppliers();
    setState(() {
      _suppliers = data;
      _isLoading = false;
    });
  }

  Future<void> _onSearch(String query) async {
    setState(() => _searchQuery = query);
    final all = await _db.getSuppliers();
    setState(() {
      _suppliers = all.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Nhà cung cấp', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadSuppliers();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang làm mới dữ liệu...'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.redAccent,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                : _suppliers.isEmpty
                    ? const Center(child: Text('Không tìm thấy nhà cung cấp nào.'))
                    : ListView.builder(
                        itemCount: _suppliers.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final supplier = _suppliers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.business, color: Colors.white)),
                              title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(supplier.email),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SupplierDetailScreen(supplier: supplier)),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
