import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cart_item.dart';

final cartControllerProvider = NotifierProvider<CartController, List<CartItem>>(
  CartController.new,
);

class CartController extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addReadyProduct({
    required int productId,
    required String title,
    required int unitPrice,
  }) {
    final index = state.indexWhere(
      (e) => e.itemType == 'ready' && e.productId == productId,
    );

    if (index != -1) {
      final item = state[index];
      final updated = item.copyWith(quantity: item.quantity + 1);
      final newState = [...state];
      newState[index] = updated;
      state = newState;
      return;
    }

    state = [
      ...state,
      CartItem(
        itemType: 'ready',
        productId: productId,
        title: title,
        description: '',
        unitPrice: unitPrice,
        quantity: 1,
      ),
    ];
  }

  void updateQty(int index, int qty) {
    if (qty <= 0) {
      removeAt(index);
      return;
    }
    final item = state[index];
    final newState = [...state];
    newState[index] = item.copyWith(quantity: qty);
    state = newState;
  }

  void removeAt(int index) {
    state = [...state]..removeAt(index);
  }

  void clear() {
    state = [];
  }

  int get total => state.fold(0, (sum, e) => sum + e.subtotal);
}
