import 'package:ShopApp/models/http_exception.dart';
import 'package:ShopApp/providers/product.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductProvider with ChangeNotifier {
  List<Product> items = [];

  var favoriteOnly = false;
  final String token;
  final String userId;
  ProductProvider(this.token, this.items, this.userId);

  List<Product> get get_items {
    // if (favoriteOnly) {
    //   return items.where((element) => element.isFavorite == true).toList();
    // } else {
    return [...items];
  }

  List<Product> get getFavoriteItems {
    return items.where((element) => element.isFavorite == true).toList();
  }
  // void showAll() {
  //   favoriteOnly = false;
  //   notifyListeners();
  // }

  // void showOnlyFavorites() {
  //   favoriteOnly = true;
  //   notifyListeners();
  // }

  Future<void> addProduct(Product product) async {
    var url =
        'https://flutter-shopapp-e8823.firebaseio.com/products.json?auth=$token';
    try {
      var response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          }));
      Product newProduct = Product(
        description: product.description,
        id: json.decode(response.body)['name'],
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
      );
      items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Product findById(String id) {
    return items.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      var url =
          'https://flutter-shopapp-e8823.firebaseio.com/products/$id.json?auth=$token';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> fetchData([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://flutter-shopapp-e8823.firebaseio.com/products.json?auth=$token&$filterString';
    try {
      var response = await http.get(url);
      var extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      var urlnew =
          'https://flutter-shopapp-e8823.firebaseio.com/userFavorites/$userId.json?auth=$token';
      final favoriteResponse = await http.get(urlnew);
      final favoriteData = json.decode(favoriteResponse.body);
      List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          description: prodData['description'],
          price: prodData['price'],
          title: prodData['title'],
          imageUrl: prodData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    var url =
        'https://flutter-shopapp-e8823.firebaseio.com/products/$id.json?auth=$token';
    var existingProductIndex = items.indexWhere((element) => element.id == id);
    Product existingProduct = items[existingProductIndex];
    items.removeWhere((element) => element.id == id);
    notifyListeners();
    var response = await http.delete(url);
    if (response.statusCode >= 400) {
      items.insert(existingProductIndex, existingProduct);
      notifyListeners();

      throw HttpException('Could not delete product');
    }
    existingProductIndex = null;
  }
}
