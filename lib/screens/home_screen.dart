import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để format tiền tệ VND
import '../models/user.dart';
import '../models/product.dart';
import '../db/database_helper.dart';

class HomeScreen extends StatefulWidget {
  final User user; // Nhận thông tin user đã đăng nhập từ LoginScreen

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Hàm format tiền tệ (VD: 500000 -> 500.000 đ)
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    // Khởi tạo TabController với 2 tab
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Widget hiển thị danh sách sản phẩm dạng lưới (Grid)
  Widget _buildProductGrid(String type) {
    return FutureBuilder<List<Product>>(
      // Gọi Query vào SQLite để lấy sản phẩm theo Type
      future: DatabaseHelper.instance.getProductsByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Chưa có sản phẩm nào."));
        }

        final products = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cột
            childAspectRatio: 0.75, // Tỷ lệ khung hình của mỗi thẻ sản phẩm
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () {
                  // TODO: Chuyển sang màn hình Chi tiết sản phẩm
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Bạn đã chọn: ${product.name}"))
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hình ảnh (Tạm thời dùng Icon placeholder nếu chưa có ảnh thật)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                    // Thông tin sản phẩm
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency.format(product.price),
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("BeautyEyes", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
                "Xin chào, ${widget.user.fullName}!",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // TODO: Mở màn hình giỏ hàng
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          tabs: const [
            Tab(text: "KÍNH CÓ SẴN", icon: Icon(Icons.face)),
            Tab(text: "GỌNG KÍNH", icon: Icon(Icons.remove_red_eye_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Kính có sẵn (READY)
          _buildProductGrid('READY'),
          // Tab 2: Gọng kính (FRAME)
          _buildProductGrid('FRAME'),
        ],
      ),
    );
  }
}