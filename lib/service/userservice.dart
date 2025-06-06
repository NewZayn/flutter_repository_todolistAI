import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:i/service/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserService {
  final String baseUrl = 'https://aiproject-todolist-huq1.onrender.com/api';

  Future<Map<String, dynamic>?> login(
      String email, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        String token = response.body;
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken['id'];
        String name = decodedToken['name'];
        String email = decodedToken['email'];

        Provider.of<UserProvider>(context, listen: false)
            .setUser(userId, name, email, token);

        Map<String, dynamic> userData = {
          'id': userId,
          'name': name,
          'email': email,
          'token': token,
        };

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user', jsonEncode(userData));

        return {'userId': userId, 'name': name, 'email': email, 'token': token};
      } else if (response.statusCode == 401) {
        throw Exception('Credenciais inválidas');
      } else {
        throw Exception('Erro ao fazer login: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 409) {
        throw Exception('Email já está em uso');
      } else {
        throw Exception('Erro ao registrar: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no registro: $e');
      return false;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  Future<Map<String, dynamic>?> getLoggedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');

    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }
}
