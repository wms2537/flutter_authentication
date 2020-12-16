import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_authentication/env.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

final String backendUrl = environment['apiUrl'];

class Auth with ChangeNotifier {
  String _accessToken;
  String _refreshToken;
  DateTime _accessTokenExpiry;
  DateTime _refreshTokenExpiry;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_accessTokenExpiry != null &&
        _accessTokenExpiry.isAfter(DateTime.now()) &&
        _accessToken != null) {
      return _accessToken;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> login(
      String email, String password) async {
    final url =
        '$backendUrl/auth/login';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _accessToken = responseData['accessToken'];
      _refreshToken = responseData['refreshToken'];
      _userId = responseData['userId'];
      _accessTokenExpiry = DateTime.parse(responseData['accessTokenExpiry']);
      _refreshTokenExpiry = DateTime.parse(responseData['refreshTokenExpiry']);
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'accessToken': _accessToken,
          'refreshToken': _refreshToken,
          'userId': _userId,
          'accessTokenExpiry': _accessTokenExpiry.toIso8601String(),
          'refreshTokenExpiry': _refreshTokenExpiry.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password, String firstName, String lastName, String phoneNumber) async {
    final url =
        '$backendUrl/auth/signup';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      throw error;
    }
  }


  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final refreshTokenExpiry = DateTime.parse(extractedUserData['refreshTokenExpiry']);

    if (refreshTokenExpiry.isBefore(DateTime.now())) {
      return false;
    }
    _accessToken = extractedUserData['accessToken'];
    _refreshToken = extractedUserData['refreshToken'];
    _userId = extractedUserData['userId'];
    _refreshTokenExpiry = refreshTokenExpiry;
    await refreshToken();
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> refreshToken() async {
    final url =
        '$backendUrl/auth/refreshToken';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'accessToken': _accessToken,
            'refreshToken': _refreshToken,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _accessToken = responseData['token'];
      
      _accessTokenExpiry = DateTime.parse(responseData['accessTokenExpiry']);
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'accessToken': _accessToken,
          'refreshToken': _refreshToken,
          'userId': _userId,
          'accessTokenExpiry': _accessTokenExpiry.toIso8601String(),
          'refreshTokenExpiry': _refreshTokenExpiry.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _accessTokenExpiry = null;
    _refreshTokenExpiry = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _refreshTokenExpiry.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
