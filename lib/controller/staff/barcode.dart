import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:supermarket_project_prm392_group4/view/staff/print_receipt_screen.dart';
import '../../db/app_database.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';

class BarcodeController extends ChangeNotifier {
  // Giỏ hàng lưu trữ Sản phẩm và Số lượng
  Map<Product, int> cart = {};

  // Controller cho ô nhập mã vạch thủ công
  final TextEditingController barcodeController = TextEditingController();

  // Sử dụng Singleton instance duy nhất từ AppDatabase
  final AppDatabase _db = AppDatabase.instance;

  // Tính tổng tiền trong giỏ hàng
  double get total =>
      cart.entries.fold(0, (sum, item) => sum + (item.key.price * item.value));

  // ══════════════════════════════════════════════════════════════════════════
  // 1. XỬ LÝ QUÉT MÃ (CAMERA & NHẬP TAY)
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> scanBarcode(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiBarcodeScanner(
          canPop: true,
          onScan: (String value) async {
            barcodeController.text = value;
            await handleInput(value, context);
            if (context.mounted) Navigator.of(context).pop();
          },
          onDispose: () => debugPrint("Barcode scanner closed."),
        ),
      ),
    );
  }

  Future<void> handleInput(String barcode, BuildContext context) async {
    String code = barcode.trim();
    if (code.isEmpty) return;

    try {
      // Tìm sản phẩm trong SQLite theo barcode
      final Product? product = await _db.getProductByBarcode(code);

      if (product != null) {
        _checkAndAddToCart(product, context);
        barcodeController.clear();
      } else {
        _showSnackBar(context, "Mã '$code' không tồn tại trong hệ thống!", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar(context, "Lỗi truy vấn Database: $e", Colors.red);
    }
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. QUẢN LÝ GIỎ HÀNG & KIỂM TRA TỒN KHO
  // ══════════════════════════════════════════════════════════════════════════

  void _checkAndAddToCart(Product product, BuildContext context) {
    // So sánh theo ID để tránh lỗi trùng lặp đối tượng
    Product? existing = cart.keys.cast<Product?>().firstWhere(
            (p) => p?.id == product.id, orElse: () => null);

    int currentInCart = existing != null ? cart[existing]! : 0;

    // Kiểm tra: Số lượng yêu cầu thêm (current + 1) có vượt quá kho không
    if (currentInCart + 1 <= product.quantity) {
      if (existing != null) {
        cart[existing] = cart[existing]! + 1;
      } else {
        cart[product] = 1;
      }
    } else {
      _showSnackBar(context, "Kho không đủ! Hiện có: ${product.quantity}", Colors.orange);
    }
  }

  void increase(Product p, BuildContext context) {
    if ((cart[p] ?? 0) + 1 <= p.quantity) {
      cart[p] = (cart[p] ?? 0) + 1;
      notifyListeners();
    } else {
      _showSnackBar(context, "Đã đạt giới hạn tồn kho (${p.quantity})", Colors.orange);
    }
  }

  void decrease(Product p, BuildContext context) {
    if (!cart.containsKey(p)) return;

    if (cart[p]! > 1) {
      // Nếu số lượng > 1: Giảm bình thường
      cart[p] = cart[p]! - 1;
      notifyListeners();
    } else {
      // Nếu số lượng = 1: Hiện Dialog KIỂM TRA LẠI lần nữa trước khi xóa
      _showDeleteConfirmDialog(context, p);
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, Product p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn muốn bỏ '${p.name}' khỏi đơn hàng này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              cart.remove(p);
              Navigator.pop(ctx);
              notifyListeners();
            },
            child: const Text("Xác nhận xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. XỬ LÝ THANH TOÁN & TRỪ KHO THỰC TẾ
  // ══════════════════════════════════════════════════════════════════════════

  // Logic cho nút Tiền Mặt
  void confirmCashPayment(BuildContext context) {
    _showConfirmDialog(
        context,
        "Xác nhận Thu Tiền Mặt",
        "Tổng tiền: ${total.toStringAsFixed(0)}đ. Đã nhận đủ tiền khách đưa?",
            () => _onPaymentSuccess(context)
    );
  }

  // Logic cho nút QR Code
  void generatePaymentQR(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Quét mã QR"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 150, color: Colors.blue),
            SizedBox(height: 10),
            Text("Yêu cầu khách quét mã chuyển khoản."),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _onPaymentSuccess(context);
              },
              child: const Text("Xác nhận đã chuyển")
          ),
        ],
      ),
    );
  }

  // HÀM QUAN TRỌNG NHẤT: Trừ kho và hoàn tất đơn hàng
  Future<void> _onPaymentSuccess(BuildContext context) async {
    try {
      // 1. Lưu lại thông tin giỏ hàng và tổng tiền trước khi xóa để in hóa đơn
      final Map<Product, int> finalizedCart = Map.from(cart);
      final double finalizedTotal = total;

      // 2. Lặp qua giỏ hàng để trừ kho thực tế trong SQLite
      for (var entry in cart.entries) {
        await _db.decreaseProductStock(
            int.parse(entry.key.id.toString()),
            entry.value
        );
      }

      // 3. Tạo Đơn hàng và lưu vào Database để Manager có thể xem
      final newOrder = Order(
        totalAmount: finalizedTotal,
        status: 'completed',
        orderDate: DateTime.now().toIso8601String(),
      );

      final orderItems = finalizedCart.entries.map((entry) {
        return OrderItem(
          productId: int.parse(entry.key.id.toString()),
          quantity: entry.value,
          unitPrice: entry.key.price,
          subtotal: entry.key.price * entry.value,
        );
      }).toList();

      await _db.createOrder(newOrder, orderItems);

      if (context.mounted) {
        // 4. Thông báo thành công
        _showSnackBar(context, "Thanh toán thành công!", Colors.green);

        // 5. RESET DỮ LIỆU NGAY (Để màn hình chính trống)
        cart.clear();
        barcodeController.clear();
        notifyListeners();

        // 6. CHUYỂN SANG MÀN HÌNH HÓA ĐƠN
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptScreen(
              cart: finalizedCart,
              total: finalizedTotal,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) _showSnackBar(context, "Lỗi khi trừ kho: $e", Colors.red);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HÀM PHỤ TRỢ
  // ══════════════════════════════════════════════════════════════════════════

  void _showSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 1)),
    );
  }

  void _showConfirmDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onConfirm();
              },
              child: const Text("Xác nhận")
          ),
        ],
      ),
    );
  }
  void confirmRemove(Product p, BuildContext context) {
    _showDeleteConfirmDialog(context, p);
  }
  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }
}