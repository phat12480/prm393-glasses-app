import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Import thư viện Slider
import '../models/user.dart';
import '../models/product.dart';
import '../db/database_helper.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  // Danh sách ảnh mẫu cho Hero Banner (Có thể thay bằng link ảnh của bạn)
  final List<String> imgList = [
    'https://images.unsplash.com/photo-1511499767150-a48a237f0083?q=80&w=1000&auto=format&fit=crop', // Ảnh cô gái đeo kính
    'https://images.unsplash.com/photo-1574258495973-f010dfbb5371?q=80&w=1000&auto=format&fit=crop', // Ảnh kính mát
    'https://images.unsplash.com/photo-1509695507497-903c140c43b0?q=80&w=1000&auto=format&fit=crop', // Ảnh thời trang
  ];

  @override
  void initState() {
    super.initState();
    // Khởi tạo 4 Tab như yêu cầu
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- WIDGET: HERO BANNER (SWIPER) ---
  Widget _buildHeroBanner() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3), // Chạy 3s/ảnh
        enlargeCenterPage: true, // Hiệu ứng phóng to ảnh ở giữa
        viewportFraction: 0.9,
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

  // --- WIDGET: GIỚI THIỆU THƯƠNG HIỆU ---
  Widget _buildBrandIntro() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
        ),
        child: Column(
          children: [
            const Text(
              "Về BeautyEyes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 8),
            const Text(
              "Chúng tôi mang đến những chiếc kính không chỉ để nhìn rõ thế giới, mà còn để thế giới nhìn rõ phong cách của bạn. Tự tin, thanh lịch và hiện đại.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1556306535-0f09a536f0bl?q=80&w=1000&auto=format&fit=crop',
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                // Xử lý lỗi nếu link ảnh hỏng
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100, color: Colors.blue[50],
                  child: const Icon(Icons.storefront, size: 40, color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: DANH SÁCH SẢN PHẨM ---
  Widget _buildProductGrid(String type) {
    return FutureBuilder<List<Product>>(
      future: DatabaseHelper.instance.getProductsByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Chưa có sản phẩm nào.", style: TextStyle(color: Colors.grey)));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          // Không cho GridView tự cuộn, để NestedScrollView quản lý cuộn
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final product = snapshot.data![index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Chọn: ${product.name}")));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F6F8), // Màu nền xám xanh nhạt mềm mại
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: const Icon(Icons.remove_red_eye, size: 40, color: Colors.blueGrey),
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
      },
    );
  }

  // --- WIDGET: TAB MUA THEO NHU CẦU (CUSTOM KÍNH) ---
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
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text("Bắt đầu chọn Gọng", style: TextStyle(fontSize: 16)),
              onPressed: () {
                // TODO: Chuyển sang luồng chọn Custom Kính
                _tabController.animateTo(1); // Tạm thời chuyển sang tab Gọng
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Màu Blue Sky chủ đạo
    const Color skyBlue = Color(0xFF56CCF2);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Nền xám rất nhạt cho toàn app
      // NestedScrollView giúp cuộn mượt mà cả Header và List
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // AppBar (Header)
            SliverAppBar(
              backgroundColor: skyBlue,
              expandedHeight: 60.0,
              floating: true,
              pinned: true, // Ghim thanh AppBar ở trên cùng
              elevation: 0,
              title: GestureDetector(
                onTap: () {
                  // Chuyển sang trang Profile khi bấm vào tên
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(user: widget.user)));
                },
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(Icons.person, size: 20, color: skyBlue),
                    ),
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
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),

            // Phần Body phía trên TabBar (Hero + Intro)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeroBanner(),
                  _buildBrandIntro(),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // Dải TabBar (Sẽ dính chặt lên trên khi cuộn xuống qua phần Hero)
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true, // Cho phép vuốt ngang nếu text quá dài
                  labelColor: Colors.blueAccent,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blueAccent,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "KÍNH CÓ SẴN"),
                    Tab(text: "GỌNG KÍNH"),
                    Tab(text: "TRÒNG KÍNH"),
                    Tab(text: "MUA THEO NHU CẦU"),
                  ],
                ),
              ),
            ),
          ];
        },

        // Nội dung của từng Tab
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

// --- CLASS HỖ TRỢ ĐỂ GHIM TABBAR LÊN TOP KHI CUỘN ---
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // Nền trắng cho thanh Tab để dễ đọc
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// --- TRANG PROFILE (TẠM THỜI ĐỂ TRÁNH LỖI KHI BẤM VÀO TÊN) ---
class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hồ sơ của tôi"), backgroundColor: const Color(0xFF56CCF2)),
      body: Center(
        child: Text("Thông tin của: ${user.fullName}\nEmail: ${user.email}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}