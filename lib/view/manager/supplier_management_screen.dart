import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/supplier.dart';
import '../../providers/supplier_provider.dart';

class SupplierManagementScreen extends StatefulWidget {
  const SupplierManagementScreen({super.key});
  @override
  State<SupplierManagementScreen> createState() => _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends State<SupplierManagementScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SupplierProvider>().loadSuppliers());
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<SupplierProvider>(context);
    final list = prov.searchSuppliers(_searchQuery);
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Nhà cung cấp'), backgroundColor: Colors.red, foregroundColor: Colors.white),
      body: Column(children: [
        Container(
          color: Colors.red, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...', hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true, fillColor: Colors.white24,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.all(16), child: Align(alignment: Alignment.centerLeft, child: Text('${list.length} nhà cung cấp', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)))),
        Expanded(
          child: prov.isLoading ? const Center(child: CircularProgressIndicator())
            : list.isEmpty ? const Center(child: Text('Không tìm thấy', style: TextStyle(color: Colors.grey)))
            : ListView.builder(itemCount: list.length, padding: const EdgeInsets.symmetric(horizontal: 16), itemBuilder: (ctx, i) => _card(ctx, list[i], prov)),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _dialog(context, prov), backgroundColor: Colors.red, icon: const Icon(Icons.add, color: Colors.white), label: const Text('Thêm NCC', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _card(BuildContext ctx, Supplier s, SupplierProvider prov) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(backgroundColor: Colors.red.withValues(alpha: 0.1), child: Text(s.name.isNotEmpty ? s.name[0] : '?', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (s.email != null && s.email!.isNotEmpty) Text(s.email!, style: const TextStyle(fontSize: 12)),
          if (s.phone != null && s.phone!.isNotEmpty) Text('📞 ${s.phone}', style: const TextStyle(fontSize: 12)),
          if (s.address != null && s.address!.isNotEmpty) Text('📍 ${s.address}', style: const TextStyle(fontSize: 11)),
        ]),
        trailing: PopupMenuButton<String>(
          onSelected: (v) { if (v == 'edit') _dialog(ctx, prov, supplier: s); else if (v == 'delete') _del(ctx, s, prov); },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Sửa')),
            const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  void _dialog(BuildContext ctx, SupplierProvider prov, {Supplier? supplier}) {
    final e = supplier != null;
    final nc = TextEditingController(text: supplier?.name ?? '');
    final ec = TextEditingController(text: supplier?.email ?? '');
    final pc = TextEditingController(text: supplier?.phone ?? '');
    final ac = TextEditingController(text: supplier?.address ?? '');
    showDialog(context: ctx, builder: (dc) => AlertDialog(
      title: Text(e ? 'Sửa NCC' : 'Thêm NCC'), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nc, decoration: InputDecoration(labelText: 'Tên *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 10),
        TextField(controller: ec, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 10),
        TextField(controller: pc, decoration: InputDecoration(labelText: 'SĐT', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 10),
        TextField(controller: ac, maxLines: 2, decoration: InputDecoration(labelText: 'Địa chỉ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc), child: const Text('Hủy')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async {
          if (nc.text.trim().isEmpty) return;
          final s = Supplier(id: e ? supplier?.id : null, name: nc.text.trim(), email: ec.text.trim().isEmpty ? null : ec.text.trim(), phone: pc.text.trim().isEmpty ? null : pc.text.trim(), address: ac.text.trim().isEmpty ? null : ac.text.trim());
          if (e) { await prov.updateSupplier(s); } else { await prov.addSupplier(s); }
          if (dc.mounted) Navigator.pop(dc);
        }, child: Text(e ? 'Cập nhật' : 'Thêm', style: const TextStyle(color: Colors.white))),
      ],
    ));
  }

  void _del(BuildContext ctx, Supplier s, SupplierProvider prov) {
    showDialog(context: ctx, builder: (dc) => AlertDialog(
      title: const Text('Xóa NCC'), content: Text('Xóa "${s.name}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc), child: const Text('Hủy')),
        TextButton(onPressed: () async { await prov.deleteSupplier(s.id!); if (dc.mounted) Navigator.pop(dc); }, child: const Text('Xóa', style: TextStyle(color: Colors.red))),
      ],
    ));
  }
}
