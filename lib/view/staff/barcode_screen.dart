import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supermarket_project_prm392_group4/controller/staff/barcode.dart';
import '../login_screen.dart';

class BarcodeScreen extends StatelessWidget {
  const BarcodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BarcodeController(),
      child: Scaffold(
        // Chống đẩy giao diện khi bàn phím hiện lên
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("SUPERMAKET"),
          backgroundColor: Colors.green,
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Đăng xuất',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: Consumer<BarcodeController>(
          builder: (context, controller, _) {
            return Column(
              children: [
                // ===== PHẦN NHẬP MÃ VẠCH  =====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Nhập mã vạch sản phẩm",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: controller.barcodeController,
                                keyboardType: TextInputType.number,
                                decoration:  InputDecoration(
                                  hintText: "Ví dụ: 8934673...",
                                  prefixIcon: IconButton(
                                    // NÚT BẤM MỞ CAMERA QUÉT MÃ
                                    icon: const Icon(Icons.qr_code_scanner, color: Colors.green),
                                    onPressed: () => controller.scanBarcode(context),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                                onSubmitted: (val) => controller.handleInput(val, context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.all(15),
                            ),
                            onPressed: () => controller.handleInput(controller.barcodeController.text, context),
                            child: const Icon(Icons.add_shopping_cart, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ===== DANH SÁCH GIỎ HÀNG =====
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.list_alt_rounded, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        "Danh sách chờ thanh toán",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: controller.cart.isEmpty
                      ? _buildEmptyCart()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: controller.cart.length,
                          itemBuilder: (context, index) {
                            final product = controller.cart.keys.elementAt(
                              index,
                            );
                            final qty = controller.cart[product]!;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    // 1. Ảnh sản phẩm
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                                          ? Image.network(
                                              product.imageUrl!,
                                              width: 65,
                                              height: 65,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  _buildFallbackIcon(),
                                            )
                                          : _buildFallbackIcon(),
                                    ),
                                    const SizedBox(width: 12),

                                    // 2. Thông tin chi tiết (Tên, Giá, Tổng món)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  product.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),

                                            ],
                                          ),
                                          Text(
                                            "Đơn giá: ${product.price.toStringAsFixed(0)} đ",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Tổng giá trị sản phẩm này
                                          Text(
                                            "Thành tiền: ${(product.price * qty).toStringAsFixed(0)} đ",
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 3. Bộ tăng giảm số lượng (Trailing)
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.redAccent,
                                            size: 22,
                                          ),
                                          onPressed: () => controller.confirmRemove(product, context),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),

                                        _buildQtyController(context, controller, product, qty),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ), // ===== TỔNG TIỀN & THANH TOÁN =====
                _buildBottomCheckout(context, controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_enhance_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("Sẵn sàng quét sản phẩm", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
  // Widget hiển thị khi giỏ hàng trống
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text(
            "Chưa có sản phẩm nào",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 65,
      height: 65,
      color: Colors.green[50],
      child: const Icon(Icons.shopping_basket_outlined, color: Colors.green),
    );
  }

  Widget _buildQtyController(
      BuildContext context,
      BarcodeController controller,
      dynamic product, // Nên để dynamic hoặc Product để truy cập .quantity
      int qty,
      ) {
    final bool isMaxStock = qty >= product.quantity;

    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12), // Bo góc vuông hơn một chút cho hiện đại
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- NÚT GIẢM / XÓA ---
          _buildSmallActionBtn(
            icon: qty > 1 ? Icons.remove : Icons.delete_outline,
            color: Colors.redAccent,
            onPressed: () => controller.decrease(product, context),
          ),

          // --- SỐ LƯỢNG ---
          Container(
            constraints: const BoxConstraints(minWidth: 30),
            alignment: Alignment.center,
            child: Text(
              "$qty",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // --- NÚT TĂNG ---
          _buildSmallActionBtn(
            icon: Icons.add,
            color: isMaxStock ? Colors.grey : Colors.green,
            onPressed: isMaxStock
                ? null // Vô hiệu hóa khi hết kho
                : () => controller.increase(product, context),
          ),
        ],
      ),
    );
  }

// Widget phụ trợ để tạo nút bấm nhỏ gọn, đồng nhất
  Widget _buildSmallActionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(icon, color: color, size: 20),
        splashRadius: 18,
      ),
    );
  }

  // Widget thanh toán phía dưới
  Widget _buildBottomCheckout(
    BuildContext context,
    BarcodeController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tổng cộng:",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                "${controller.total.toStringAsFixed(0)} đ",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.cart.isEmpty
                      ? null // Vô hiệu hóa nếu giỏ hàng trống
                      : () => controller.generatePaymentQR(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text("QR CODE"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.cart.isEmpty
                      ? null
                      : () => controller.confirmCashPayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text("TIỀN MẶT"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
