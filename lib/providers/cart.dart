import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(this.id, this.title, this.price, this.quantity);
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existing) => CartItem(
                existing.id,
                existing.title,
                existing.price,
                existing.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(productId,
          () => CartItem(DateTime.now().toString(), title, price, 1));
    }
    notifyListeners();
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void removeSingleItem(String id) {
    if (!_items.containsKey(id)) return;
    if (_items[id]!.quantity > 1) {
      _items.update(id,
          (old) => CartItem(old.id, old.title, old.price, old.quantity - 1));
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
