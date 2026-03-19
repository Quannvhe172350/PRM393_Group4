import 'package:flutter/material.dart';
import 'package:supermarket_project_prm392_group4/models/product.dart';
import 'package:supermarket_project_prm392_group4/view/staff/print_receipt_screen.dart';

class BarcodeController extends ChangeNotifier {
  Map<Product, int> cart = {};
  final TextEditingController barcodeController = TextEditingController();

  // Dữ liệu mẫu
  final List<Product> _mockProducts = [
    Product(
      id: "P001",
      barcode: "8934673123456",
      name: "Sữa tươi Vinamilk 1L",
      price: 32000,
      quantity: 50,
      imageUrl: "https://via.placeholder.com/150",
    ),
    Product(
      id: "P002",
      barcode: "8934673999999",
      name: "Bánh mì gối Kinh Đô",
      price: 25000,
      quantity: 20,
      imageUrl: "https://via.placeholder.com/150",
    ),
  ];

  BarcodeController() {
    _initDemoCart();
  }

  void _initDemoCart() {
    if (_mockProducts.isNotEmpty) {
      cart[_mockProducts[0]] = 2;
      cart[_mockProducts[1]] = 1;
      notifyListeners();
    }
  }

  double get total =>
      cart.entries.fold(0, (sum, item) => sum + (item.key.price * item.value));

  // ===== QUẢN LÝ GIỎ HÀNG =====
  void handleManualInput(String barcode, BuildContext context) {
    if (barcode.trim().isEmpty) return;
    try {
      final product = _mockProducts.firstWhere(
        (p) => p.barcode == barcode.trim(),
      );
      _addToCart(product);
      barcodeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mã vạch '$barcode' không tồn tại!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _addToCart(Product product) {
    final existingProduct = cart.keys.firstWhere(
      (p) => p.id == product.id,
      orElse: () => product,
    );
    if (cart.containsKey(existingProduct)) {
      cart[existingProduct] = cart[existingProduct]! + 1;
    } else {
      cart[product] = 1;
    }
    notifyListeners();
  }

  void increase(Product p) => {cart[p] = (cart[p] ?? 0) + 1, notifyListeners()};
  void decrease(Product p) => {
    if (cart[p]! > 1) cart[p] = cart[p]! - 1 else cart.remove(p),
    notifyListeners(),
  };
  void removeFromCart(Product p) => {cart.remove(p), notifyListeners()};

  // ===== LOGIC THANH TOÁN & IN BIÊN LAI =====

  void confirmCashPayment(BuildContext context) {
    if (cart.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận tiền mặt"),
        content: Text("Xác nhận đã thu ${total.toStringAsFixed(0)} đ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _processPaymentSuccess(context);
            },
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  void generatePaymentQR(BuildContext context) {
    if (cart.isEmpty) return;
    String qrUrl =
        "https://img.vietqr.io/image/MB-0123456789-compact2.png?amount=${total.toInt()}&addInfo=THANHTOAN";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Quét mã QR"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${total.toStringAsFixed(0)} đ",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Image.network(qrUrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _processPaymentSuccess(context);
            },
            child: const Text("Đã nhận tiền"),
          ),
        ],
      ),
    );
  }

  // 2. HÀM NÀY ĐÃ ĐƯỢC SỬA ĐỂ CHUYỂN TRANG
  void _processPaymentSuccess(BuildContext context) {
    // Bước A: Sao lưu dữ liệu sang một Map mới (Bản sao độc lập)
    final finalizedCart = Map<Product, int>.from(cart);
    final finalizedTotal = total;

    // Bước B: Thông báo cho Staff
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Thanh toán thành công!"),
        backgroundColor: Colors.green,
      ),
    );

    // Bước C: Chuyển trang sang ReceiptScreen TRƯỚC khi xóa giỏ hàng ở UI chính
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReceiptScreen(cart: finalizedCart, total: finalizedTotal),
      ),
    );

    // Bước D: Reset dữ liệu màn hình quét cho khách tiếp theo
    cart.clear();
    barcodeController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }
}
