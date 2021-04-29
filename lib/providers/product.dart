import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final double price;
  final String description;
  final String imageUrl;
  bool isFavorite; //not final because it can be changed

  Product({
    @required this.description,
    @required this.id,
    @required this.imageUrl,
    this.isFavorite = false, //assigning default value
    @required this.price,
    @required this.title,
  });

  Future<void> toggleFavorite(String token,String uid) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    var url = 'https://flutter-shopapp-e8823.firebaseio.com/userFavorites/$uid/$id.json?auth=$token';
    try {
      final response = await http.put(url,
          body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
