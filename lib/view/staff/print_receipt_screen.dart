import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart'; // Đảm bảo đường dẫn này đúng

class ReceiptScreen extends StatelessWidget {
  // 1. Sửa dynamic thành Product để truy cập được các trường dữ liệu
  final Map<Product, int> cart;
  final double total;

  const ReceiptScreen({super.key, required this.cart, required this.total});

  @override
  Widget build(BuildContext context) {
    // Định dạng tiền tệ VNĐ
    final formatCurrency = NumberFormat("#,###", "vi_VN");

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Biên lai thanh toán"),
        backgroundColor: Colors.green,
        // 2. Thêm nút X để đóng nhanh trang biên lai
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                // Răng cưa giả lập (Top)
                _buildZigZagDivider(),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        "SUPERMARKET GROUP 4",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Text("123 Street, Hanoi, Vietnam"),
                      const Text("Hotline: 1900 1234"),
                      const SizedBox(height: 15),
                      const Text(
                        "HÓA ĐƠN BÁN LẺ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}",
                      ),
                      const Divider(thickness: 1, height: 30),

                      // Danh sách sản phẩm
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          final product = cart.keys.elementAt(index);
                          final qty = cart[product]!;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "$qty x ${formatCurrency.format(product.price)}",
                                    ),
                                    Text(
                                      "${formatCurrency.format(product.price * qty)} đ",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const Divider(thickness: 1, height: 30),

                      // Tổng tiền
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "TỔNG TIỀN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "${formatCurrency.format(total)} đ",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      const Text(
                        "Cảm ơn Quý khách!",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const Text("Hẹn gặp lại quý khách"),
                      const SizedBox(height: 20),

                      // Mã QR giả để scan (Tùy chọn)
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),

                // Răng cưa giả lập (Bottom)
                _buildZigZagDivider(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: () {
            // Hiển thị thông báo in thành công và quay lại
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Đang gửi lệnh in đến máy in K80..."),
              ),
            );
            Navigator.pop(context); // Quay về màn hình bán hàng
          },
          icon: const Icon(Icons.local_printshop),
          label: const Text("XÁC NHẬN IN & HOÀN TẤT"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // Widget vẽ đường răng cưa cho đẹp
  Widget _buildZigZagDivider() {
    return Container(
      height: 10,
      width: double.infinity,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) =>
            const Icon(Icons.change_history, size: 12, color: Colors.grey),
      ),
    );
  }
}
