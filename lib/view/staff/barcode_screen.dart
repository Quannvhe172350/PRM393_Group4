import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supermarket_project_prm392_group4/controller/staff/barcode.dart';

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
          title: const Text("BarcodeScreen"),
          backgroundColor: Colors.green,
          centerTitle: true,
          elevation: 0,
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
                                decoration: const InputDecoration(
                                  hintText: "Ví dụ: 8934673...",
                                  prefixIcon: Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.green,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                onSubmitted: (val) =>
                                    controller.handleManualInput(val, context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              // Sửa lỗi ở đây: Sử dụng RoundedRectangleBorder chuẩn
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(15),
                            ),
                            onPressed: () => controller.handleManualInput(
                              controller.barcodeController.text,
                              context,
                            ),
                            child: const Icon(Icons.add_shopping_cart),
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
                                      child: product.imageUrl.isNotEmpty
                                          ? Image.network(
                                              product.imageUrl,
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
                                              // Nút xóa (Icon Thùng rác)
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Colors.redAccent,
                                                  size: 22,
                                                ),
                                                onPressed: () => controller
                                                    .removeFromCart(product),
                                                constraints:
                                                    const BoxConstraints(),
                                                padding: EdgeInsets.zero,
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
                                    _buildQtyController(
                                      controller,
                                      product,
                                      qty,
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

  // Widget điều khiển số lượng
  Widget _buildQtyController(
    BarcodeController controller,
    var product,
    int qty,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => controller.decrease(product),
            icon: const Icon(
              Icons.remove_circle,
              color: Colors.redAccent,
              size: 24,
            ),
          ),
          Text(
            "$qty",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => controller.increase(product),
            icon: const Icon(Icons.add_circle, color: Colors.green, size: 24),
          ),
        ],
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
                      ? null
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
