import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Dùng để parse JSON specs
import '../models/product.dart';
import '../models/user.dart';
import '../presenters/custom_combo_presenter.dart';

class CustomComboScreen extends StatefulWidget {
  final User user;
  const CustomComboScreen({super.key, required this.user});

  @override
  State<CustomComboScreen> createState() => _CustomComboScreenState();
}

class _CustomComboScreenState extends State<CustomComboScreen> implements CustomComboView {
  late CustomComboPresenter _presenter;
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  bool _isLoading = true;
  int _currentStep = 0;

  List<Product> _frames = [];
  List<Product> _lenses = [];

  Product? _selectedFrame;
  Product? _selectedLens;
  String? _selectedColor; // Biến lưu màu gọng được chọn

  @override
  void initState() {
    super.initState();
    _presenter = CustomComboPresenter(this);
    _presenter.loadComboData();
  }

  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onLoadDataSuccess(List<Product> frames, List<Product> lenses) {
    setState(() {
      _frames = frames;
      _lenses = lenses;
    });
  }

  @override
  void onAddToCartSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thêm Combo vào giỏ hàng!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
    Navigator.pop(context);
  }

  @override
  void onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // Hàm bóc tách danh sách màu từ chuỗi JSON specs
  List<String> _getAvailableColors(Product? product) {
    if (product == null || product.specs == null || product.specs!.isEmpty) return [];
    try {
      final Map<String, dynamic> parsedSpecs = jsonDecode(product.specs!);
      if (parsedSpecs.containsKey('colors')) {
        return List<String>.from(parsedSpecs['colors']);
      }
    } catch (e) {
      print("Lỗi parse specs JSON: $e");
    }
    return [];
  }

  Widget _buildProductGrid(List<Product> products, Product? selectedProduct, Function(Product) onSelect) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final item = products[index];
        final isSelected = item.id == selectedProduct?.id;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
              border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey.shade300, width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Color(0xFFF3F6F8), borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(item.imageUrl, fit: BoxFit.cover)
                        : const Icon(Icons.remove_red_eye, color: Colors.grey, size: 40),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(formatCurrency.format(item.price), style: const TextStyle(color: Colors.blueAccent)),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget hiển thị danh sách nút chọn màu
  Widget _buildColorSelector() {
    final colors = _getAvailableColors(_selectedFrame);
    if (colors.isEmpty) return const SizedBox.shrink(); // Không có màu thì ẩn đi

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Chọn màu sắc Gọng:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: colors.map((color) {
              final isSelected = _selectedColor == color;
              return ChoiceChip(
                label: Text(color),
                selected: isSelected,
                selectedColor: Colors.blueAccent.withOpacity(0.2),
                labelStyle: TextStyle(color: isSelected ? Colors.blueAccent : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                onSelected: (selected) {
                  setState(() => _selectedColor = selected ? color : null);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    double total = (_selectedFrame?.price ?? 0) + (_selectedLens?.price ?? 0);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hóa đơn của bạn:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("1. ${_selectedFrame?.name ?? ''}"),
              subtitle: _selectedColor != null ? Text("Màu: $_selectedColor", style: const TextStyle(color: Colors.blue)) : null,
              trailing: Text(formatCurrency.format(_selectedFrame?.price ?? 0)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("2. ${_selectedLens?.name ?? ''}"),
              trailing: Text(formatCurrency.format(_selectedLens?.price ?? 0)),
            ),
            const Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TỔNG CỘNG:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                Text(formatCurrency.format(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo Kính Theo Nhu Cầu"), backgroundColor: const Color(0xFF56CCF2)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          // BẮT LỖI CHỌN GỌNG VÀ CHỌN MÀU
          if (_currentStep == 0) {
            if (_selectedFrame == null) {
              onError("Vui lòng chọn một Gọng kính trước khi tiếp tục!");
              return;
            }
            if (_getAvailableColors(_selectedFrame).isNotEmpty && _selectedColor == null) {
              onError("Vui lòng chọn màu sắc cho gọng kính!");
              return;
            }
          }
          if (_currentStep == 1 && _selectedLens == null) {
            onError("Vui lòng chọn một Tròng kính trước khi tiếp tục!");
            return;
          }

          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            // Thêm vào giỏ hàng và TRUYỀN MÀU VÀO PRESENTER
            _presenter.addComboToCart(widget.user, _selectedFrame!, _selectedLens!, _selectedColor);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            Navigator.pop(context);
          }
        },
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: isLastStep ? Colors.green : Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                    onPressed: details.onStepContinue,
                    child: Text(isLastStep ? "Thêm vào giỏ hàng" : "Tiếp tục"),
                  ),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                      onPressed: details.onStepCancel,
                      child: const Text("Quay lại"),
                    ),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text("Gọng"),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                _buildProductGrid(_frames, _selectedFrame, (product) {
                  setState(() {
                    _selectedFrame = product;
                    _selectedColor = null; // Reset màu khi chọn gọng khác
                  });
                }),
                // Hiện khung chọn màu ngay dưới danh sách nếu có chọn Gọng
                if (_selectedFrame != null) _buildColorSelector(),
              ],
            ),
          ),
          Step(
            title: const Text("Tròng"),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildProductGrid(_lenses, _selectedLens, (product) {
              setState(() => _selectedLens = product);
            }),
          ),
          Step(
            title: const Text("Tổng kết"),
            isActive: _currentStep >= 2,
            content: _buildSummary(),
          ),
        ],
      ),
    );
  }
}