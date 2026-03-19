import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/manager.dart';
import '../../models/cashier.dart';
import '../../providers/staff_provider.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().loadStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = Provider.of<StaffProvider>(context);
    final staffList = staffProvider.searchStaff(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nhân viên'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.purple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nhân viên...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Summary bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${staffList.length} nhân viên',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                Text(
                  'Tổng lương: ${_formatPrice(staffProvider.totalSalary)}đ',
                  style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),

          // Staff list
          Expanded(
            child: staffProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : staffList.isEmpty
                    ? const Center(child: Text('Không tìm thấy nhân viên', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: staffList.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final staff = staffList[index];
                          if (staff is Manager) {
                            return _buildManagerCard(context, staff, staffProvider);
                          } else if (staff is Cashier) {
                            return _buildCashierCard(context, staff, staffProvider);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffDialog(context, staffProvider),
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Thêm NV', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildManagerCard(BuildContext context, Manager manager, StaffProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.purple.withValues(alpha: 0.1),
              child: Text(
                manager.name.isNotEmpty ? manager.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(manager.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(manager.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Quản lý${manager.department != null ? ' - ${manager.department}' : ''}',
                          style: const TextStyle(fontSize: 11, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      if (manager.salary != null)
                        Text('${_formatPrice(manager.salary!)}đ',
                          style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditManagerDialog(context, provider, manager);
                } else if (value == 'delete') {
                  _showDeleteDialog(context, manager.name, () => provider.deleteManager(manager.id!));
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Sửa')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashierCard(BuildContext context, Cashier cashier, StaffProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: Text(
                cashier.name.isNotEmpty ? cashier.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cashier.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(cashier.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Thu ngân • Quầy ${cashier.counterNumber ?? '-'} • Ca ${_getShiftText(cashier.shift)}',
                          style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (cashier.salary != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('${_formatPrice(cashier.salary!)}đ',
                        style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditCashierDialog(context, provider, cashier);
                } else if (value == 'delete') {
                  _showDeleteDialog(context, cashier.name, () => provider.deleteCashier(cashier.id!));
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Sửa')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context, StaffProvider provider) {
    String staffType = 'cashier';
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final salaryController = TextEditingController();
    final passwordController = TextEditingController(text: '123456');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Thêm nhân viên'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: staffType,
                  decoration: InputDecoration(labelText: 'Loại NV', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: const [
                    DropdownMenuItem(value: 'cashier', child: Text('Thu ngân')),
                    DropdownMenuItem(value: 'manager', child: Text('Quản lý')),
                  ],
                  onChanged: (v) => setDialogState(() => staffType = v ?? staffType),
                ),
                const SizedBox(height: 10),
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Họ tên *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'SĐT *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                TextField(controller: salaryController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Lương (VNĐ)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () async {
                if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty || phoneController.text.trim().isEmpty) return;

                if (staffType == 'manager') {
                  await provider.addManager(Manager(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    password: passwordController.text.trim(),
                    salary: double.tryParse(salaryController.text.trim()),
                  ));
                } else {
                  await provider.addCashier(Cashier(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    password: passwordController.text.trim(),
                    salary: double.tryParse(salaryController.text.trim()),
                  ));
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Thêm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditManagerDialog(BuildContext context, StaffProvider provider, Manager manager) {
    final nameController = TextEditingController(text: manager.name);
    final emailController = TextEditingController(text: manager.email);
    final phoneController = TextEditingController(text: manager.phone);
    final salaryController = TextEditingController(text: manager.salary?.toString() ?? '');
    final deptController = TextEditingController(text: manager.department ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sửa Quản lý'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Họ tên', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: 'SĐT', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: deptController, decoration: InputDecoration(labelText: 'Bộ phận', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: salaryController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Lương', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () async {
              await provider.updateManager(manager.copyWith(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
                department: deptController.text.trim(),
                salary: double.tryParse(salaryController.text.trim()),
              ));
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditCashierDialog(BuildContext context, StaffProvider provider, Cashier cashier) {
    final nameController = TextEditingController(text: cashier.name);
    final emailController = TextEditingController(text: cashier.email);
    final phoneController = TextEditingController(text: cashier.phone);
    final salaryController = TextEditingController(text: cashier.salary?.toString() ?? '');
    String shift = cashier.shift;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Sửa Thu ngân'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Họ tên', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                TextField(controller: phoneController, decoration: InputDecoration(labelText: 'SĐT', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: shift,
                  decoration: InputDecoration(labelText: 'Ca làm', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: const [
                    DropdownMenuItem(value: 'morning', child: Text('Ca sáng')),
                    DropdownMenuItem(value: 'afternoon', child: Text('Ca chiều')),
                    DropdownMenuItem(value: 'evening', child: Text('Ca tối')),
                  ],
                  onChanged: (v) => setDialogState(() => shift = v ?? shift),
                ),
                const SizedBox(height: 10),
                TextField(controller: salaryController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Lương', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () async {
                await provider.updateCashier(cashier.copyWith(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                  shift: shift,
                  salary: double.tryParse(salaryController.text.trim()),
                ));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String name, Future<void> Function() onDelete) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa nhân viên'),
        content: Text('Bạn có chắc muốn xóa "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              await onDelete();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa "$name"'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getShiftText(String shift) {
    switch (shift) {
      case 'morning': return 'sáng';
      case 'afternoon': return 'chiều';
      case 'evening': return 'tối';
      default: return shift;
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
