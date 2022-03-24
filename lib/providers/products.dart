import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_04_shop/models/http_exception.dart';
import 'package:flutter_04_shop/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  final String? authToken;
  final String? userId;

  List<Product> _items = [];

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product prod) async {
    final url = Uri.https(
        'flutter-shop-app-fb14d-default-rtdb.europe-west1.firebasedatabase.app',
        '/products.json',
        {'auth': '$authToken'});
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': prod.title,
            'description': prod.description,
            'imageUrl': prod.imageUrl,
            'price': prod.price,
            'creatorId': userId,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: prod.title,
          description: prod.description,
          price: prod.price,
          imageUrl: prod.imageUrl);

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
          'flutter-shop-app-fb14d-default-rtdb.europe-west1.firebasedatabase.app',
          '/products/$id.json',
          {'auth': '$authToken'});
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));

      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https(
        'flutter-shop-app-fb14d-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/$id.json',
        {'auth': '$authToken'});
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser
        ? {
            'auth': '$authToken',
            'orderBy': '"creatorId"',
            'equalTo': '"$userId"'
          }
        : {
            'auth': '$authToken',
          };
    var url = Uri.https(
        'flutter-shop-app-fb14d-default-rtdb.europe-west1.firebasedatabase.app',
        '/products.json',
        filterString);

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null) return;

      url = Uri.https(
          'flutter-shop-app-fb14d-default-rtdb.europe-west1.firebasedatabase.app',
          'userFavorites/$userId.json',
          {'auth': '$authToken'});
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProduct = [];
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
