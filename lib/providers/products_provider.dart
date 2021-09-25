import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/models/http_exception.dart';
import 'package:shopping_app/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsProvider with ChangeNotifier {
  final String authToken;
  final String userId;
  ProductsProvider(this.authToken, this.userId, this._items);

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favorite {
    return _items.where((fav) => fav.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts() async {
    var url =
        'https://flutter-shopping-6c95a-default-rtdb.firebaseio.com/products.json?auth=$authToken&orderBy="creatorId"&equalTo="$userId"';
    try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    url =
        'https://flutter-shopping-6c95a-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

    final favoriteResponse = await http.get(Uri.parse(url));
    final favoriteData = json.decode(favoriteResponse.body);
    final List<Product> loadedProducts = [];

    extractedData.forEach((productId, productData) {
      loadedProducts.add(
        Product(
          id: productId,
          title: productData['title'],
          description: productData['description'].toString(),
          price: productData['price'],
          imageUrl: productData['imageUrl'].toString(),
          isFavorite:
              favoriteData == null ? false : favoriteData[productId] ?? false,
        ),
      );
    });
    _items = loadedProducts;
    notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-shopping-6c95a-default-rtdb.firebaseio.com/products.json?auth=$authToken';

    try {
      //http post request => save data to web server firebase
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-shopping-6c95a-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-shopping-6c95a-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      throw HttpException('Could not delete product');
    }
    existingProduct = null as Product;
    _items.insert(existingProductIndex, existingProduct);

    notifyListeners();
  }
}
