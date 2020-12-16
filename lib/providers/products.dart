import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  // var _showFavoritesOnly = false;
  String _authToken;
  String _userId;
  void setCredentials(String authToken, String userId) {
    this._authToken = authToken;
    this._userId = userId;
  }

  // Implement other logic here i.e. fetching data with token
}
