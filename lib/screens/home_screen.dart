import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../presenters/home_presenter.dart'; // Import Presenter
import 'product_detail_screen.dart'; // Import trang Chi tiết sản phẩm
import 'custom_combo_screen.dart'; // Import trang chọn kính theo yêu cầu
import 'profile_screen.dart'; // Import trang profile
import 'cart_screen.dart'; // Import trang giỏ hàng

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Ký hợp đồng implements HomeView
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin implements HomeView {
  late TabController _tabController;
  late HomePresenter _presenter; // Khai báo Presenter

  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  // Biến lưu trữ dữ liệu sản phẩm
  bool _isLoading = true;
  int _cartItemCount = 0; // THÊM BIẾN LƯU SỐ LƯỢNG GIỎ HÀNG
  Map<String, List<Product>> _productsMap = {
    'READY': [],
    'FRAME': [],
    'LENS': [],
  };

  final List<String> imgList = [
    'https://images.unsplash.com/photo-1511499767150-a48a237f0083?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1574258495973-f010dfbb5371?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509695507497-903c140c43b0?q=80&w=1000&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Khởi tạo Presenter và gọi hàm tải dữ liệu ngay lập tức
    _presenter = HomePresenter(this);
    _presenter.loadAllProducts(); // Bảo presenter tải các product lên
    _presenter.loadCartCount(widget.user.id!); // BẢO PRESENTER ĐẾM GIỎ HÀNG KHI MỞ APP
  }

  // ==========================================================
  // THỰC THI HỢP ĐỒNG MVP
  // ==========================================================
  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onLoadProductsSuccess(Map<String, List<Product>> categorizedProducts) {
    setState(() {
      _productsMap = categorizedProducts;
    });
  }

  @override
  void onLoadError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }
  // ==========================================================

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // THÊM HÀM NÀY VÀO ĐỂ NHẬN SỐ ĐẾM TỪ PRESENTER
  @override
  void onUpdateCartCount(int count) {
    setState(() {
      _cartItemCount = count;
    });
  }

  // Section 1: Widget banner
  Widget _buildHeroBanner() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180.0, autoPlay: true, autoPlayInterval: const Duration(seconds: 3),
        enlargeCenterPage: true, viewportFraction: 0.9,
      ),
      items: imgList.map((item) => Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
          image: DecorationImage(image: NetworkImage(item), fit: BoxFit.cover),
        ),
      )).toList(),
    );
  }

  // Section 2: Widget giới thiệu thương hiệu
  Widget _buildBrandIntro() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
        ),
        child: Column(
          children: [
            const Text("Về BeautyEyes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 8),
            const Text("Chúng tôi mang đến những chiếc kính không chỉ để nhìn rõ thế giới, mà còn để thế giới nhìn rõ phong cách của bạn. Tự tin, thanh lịch và hiện đại.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1556306535-0f09a536f0bl?q=80&w=1000&auto=format&fit=crop',
                height: 100, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(height: 100, color: Colors.blue[50], child: const Icon(Icons.storefront, size: 40, color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section 3: Widget danh sách sản phẩm
  Widget _buildProductGrid(String type) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final products = _productsMap[type] ?? [];

    if (products.isEmpty) {
      return const Center(child: Text("Chưa có sản phẩm nào.", style: TextStyle(color: Colors.grey)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product, user: widget.user),
                ),
              );
              // Bắt buộc đếm lại giỏ hàng khi thoát trang chi tiết
              _presenter.loadCartCount(widget.user.id!);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F6F8), borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: product.imageUrl.isNotEmpty
                        ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(product.imageUrl, fit: BoxFit.cover)
                    )
                        : const Icon(Icons.remove_red_eye, size: 40, color: Colors.blueGrey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(formatCurrency.format(product.price), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Section 4: Widget chọn kính theo yêu cầu
  Widget _buildCustomComboTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 60, color: Colors.orangeAccent),
            const SizedBox(height: 16),
            const Text("Tạo Kính Phù Hợp Với Bạn", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Chọn gọng kính yêu thích và ghép nối với loại tròng kính phù hợp với độ cận của bạn.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text("Bắt đầu chọn Gọng", style: TextStyle(fontSize: 16)),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomComboScreen(user: widget.user),
                  ),
                );
                // Bắt buộc đếm lại giỏ hàng khi thoát màn hình Combo
                _presenter.loadCartCount(widget.user.id!);
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color skyBlue = Color(0xFF56CCF2);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: skyBlue, expandedHeight: 60.0, floating: true, pinned: true, elevation: 0,
              title: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(user: widget.user))),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.white, radius: 16, child: Icon(Icons.person, size: 20, color: skyBlue)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Xin chào,", style: TextStyle(fontSize: 12, color: Colors.white70)),
                        Text(widget.user.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                // Bọc IconButton trong Widget Badge
                Badge(
                  label: Text('$_cartItemCount', style: const TextStyle(color: Colors.white)),
                  isLabelVisible: _cartItemCount > 0, // Chỉ hiện nốt đỏ nếu có hàng
                  backgroundColor: Colors.redAccent,
                  offset: const Offset(-5, 5), // Chỉnh vị trí dấu chấm đỏ lệch vào trong 1 xíu
                  child: IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: () async {
                        // Dùng await để app chờ bạn đi chợ (vào màn hình Cart)
                        await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartScreen(user: widget.user))
                        );
                        // KHI QUAY LẠI TRANG CHỦ, BẢO PRESENTER ĐẾM LẠI GIỎ HÀNG!
                        _presenter.loadCartCount(widget.user.id!);
                      }
                  ),
                ),
                const SizedBox(width: 10), // Cách lề phải một chút cho đẹp
              ],
            ),
            SliverToBoxAdapter(
              child: Column(children: [_buildHeroBanner(), _buildBrandIntro(), const SizedBox(height: 10)]),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController, isScrollable: true, labelColor: Colors.blueAccent, unselectedLabelColor: Colors.grey, indicatorColor: Colors.blueAccent, indicatorWeight: 3, labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [Tab(text: "KÍNH CÓ SẴN"), Tab(text: "GỌNG KÍNH"), Tab(text: "TRÒNG KÍNH"), Tab(text: "MUA THEO NHU CẦU")],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductGrid('READY'),
            _buildProductGrid('FRAME'),
            _buildProductGrid('LENS'),
            _buildCustomComboTab(),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: Colors.white, child: _tabBar);
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
