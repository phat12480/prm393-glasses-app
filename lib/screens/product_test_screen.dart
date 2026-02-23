import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product.dart';

class ProductTestScreen extends StatefulWidget {
  const ProductTestScreen({super.key});

  @override
  State<ProductTestScreen> createState() => _ProductTestScreenState();
}

class _ProductTestScreenState extends State<ProductTestScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  String _currentFilter = 'All'; // Để hiển thị trạng thái lọc hiện tại
  final List<String> _types = ['FRAME', 'LENS', 'READY'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // --- CÁC HÀM LOAD DATA (READ) ---

  Future<void> _loadProducts() async {
    final list = await _productService.getAllProducts();
    setState(() {
      _products = list;
      _currentFilter = 'All Products';
    });
  }

  Future<void> _loadFrames() async {
    final list = await _productService.getFrames();
    setState(() {
      _products = list;
      _currentFilter = 'Frames Only';
    });
  }

  Future<void> _loadLenses() async {
    final list = await _productService.getLenses();
    setState(() {
      _products = list;
      _currentFilter = 'Lenses Only';
    });
  }

  Future<void> _loadReadyMade() async {
    final list = await _productService.getReadyMadeGlasses();
    setState(() {
      _products = list;
      _currentFilter = 'Ready Made Only';
    });
  }

  // --- FORM NHẬP TAY (CREATE / UPDATE) ---
  Future<void> _openProductForm({Product? product}) async {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final priceCtrl = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final stockCtrl = TextEditingController(
      text: product?.stock.toString() ?? '',
    );
    final imageCtrl = TextEditingController(text: product?.imageUrl ?? '');
    final statusCtrl = TextEditingController(text: product?.status ?? 'ACTIVE');
    final specsCtrl = TextEditingController(text: product?.specs ?? '');

    // Mặc định loại dựa vào filter hiện tại (nếu đang filter) hoặc FRAME
    String selectedType = _types.contains(_currentFilter.toUpperCase())
        ? _currentFilter.toUpperCase()
        : _types.first;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Loại (FRAME / LENS / READY)',
                ),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) selectedType = v;
                },
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 2,
              ),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'Giá (VND)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockCtrl,
                decoration: const InputDecoration(labelText: 'Tồn kho'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              TextField(
                controller: statusCtrl,
                decoration: const InputDecoration(
                  labelText: 'Status (ACTIVE/INACTIVE)',
                ),
              ),
              TextField(
                controller: specsCtrl,
                decoration: const InputDecoration(labelText: 'Specs (JSON)'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final desc = descCtrl.text.trim();
                    final image = imageCtrl.text.trim();
                    final status = statusCtrl.text.trim().isEmpty
                        ? 'ACTIVE'
                        : statusCtrl.text.trim();
                    final specs = specsCtrl.text.trim().isEmpty
                        ? null
                        : specsCtrl.text.trim();
                    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                    final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;

                    final payload = Product(
                      id: product?.id,
                      categoryId:
                          product?.categoryId ?? 0, // sẽ được set theo type
                      name: name,
                      description: desc,
                      price: price,
                      imageUrl: image,
                      stock: stock,
                      status: status,
                      specs: specs,
                    );

                    try {
                      if (product == null) {
                        await _createByType(selectedType, payload);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã thêm sản phẩm')),
                          );
                        }
                      } else {
                        await _updateByType(selectedType, payload);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã cập nhật sản phẩm'),
                            ),
                          );
                        }
                      }
                      await _loadProducts();
                      if (mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                      }
                    }
                  },
                  child: Text(product == null ? 'Thêm' : 'Lưu'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createByType(String type, Product payload) async {
    switch (type) {
      case 'FRAME':
        await _productService.createFrameProduct(payload);
        break;
      case 'LENS':
        await _productService.createLensProduct(payload);
        break;
      case 'READY':
      default:
        await _productService.createReadyProduct(payload);
        break;
    }
  }

  Future<void> _updateByType(String type, Product payload) async {
    switch (type) {
      case 'FRAME':
        await _productService.updateFrameProduct(payload);
        break;
      case 'LENS':
        await _productService.updateLensProduct(payload);
        break;
      case 'READY':
      default:
        await _productService.updateReadyProduct(payload);
        break;
    }
  }

  // Xóa sản phẩm
  Future<void> _deleteProduct(int id) async {
    await _productService.deleteProduct(id);
    _loadProducts();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa sản phẩm!')));
    }
  }

  // Update sản phẩm (Ví dụ đổi tên)
  Future<void> _updateProduct(Product product) async {
    final updatedProduct = product.copyWith(
      name: '${product.name} (Updated)',
      price: product.price + 50000,
    );
    await _productService.updateProduct(updatedProduct);
    _loadProducts();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật sản phẩm!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test CRUD Product'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Khu vực điều khiển
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                ElevatedButton(
                  onPressed: _loadProducts,
                  child: const Text('All'),
                ),
                ElevatedButton(
                  onPressed: _loadFrames,
                  child: const Text('Frames'),
                ),
                ElevatedButton(
                  onPressed: _loadLenses,
                  child: const Text('Lenses'),
                ),
                ElevatedButton(
                  onPressed: _loadReadyMade,
                  child: const Text('Ready'),
                ),
                ElevatedButton(
                  onPressed: () => _openProductForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('+ Add Product'),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            width: double.infinity,
            child: Text(
              'Current View: $_currentFilter (${_products.length} items)',
            ),
          ),

          // Danh sách sản phẩm
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(product.id.toString()),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price: ${product.price} - Stock: ${product.stock}',
                        ),
                        Text(
                          'Specs: ${product.specs ?? "N/A"}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _openProductForm(product: product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(product.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
