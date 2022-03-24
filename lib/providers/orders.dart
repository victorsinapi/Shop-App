import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_04_shop/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(this.id, this.amount, this.products, this.dateTime);
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return _orders.toList();
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(
        'flutter-shop-app-fb14d-default-rtdb.europe-west1.firebasedatabase.app',
        '/orders/$userId.json',
        {'auth': '$authToken'});
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
            orderId,
            orderData['amount'],
            (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    item['id'],
                    item['title'],
                    item['price'],
                    item['quantity'],
                  ),
                )
                .toList(),
            DateTime.parse(orderData['dateTime'])),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
        'flutter-shop-app-fb14d-default-rtdb.europe-west1.firebasedatabase.app',
        '/orders/$userId.json',
        {'auth': '$authToken'});
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
          json.decode(response.body)['name'], total, cartProducts, timestamp),
    );
    notifyListeners();
  }
}
