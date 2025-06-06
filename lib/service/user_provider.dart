import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:i/service/GoogleAuthService.dart'; // Importe o serviço

class UserProvider with ChangeNotifier {
  String _userId = "";
  String _userName = "";
  String _userEmail = "";
  String _token = "";
  bool _isLoading = false;

  final GoogleAuthService _googleAuthService = GoogleAuthService();

  // Getters
  String get userId => _userId;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get token => _token;
  bool get isLoading => _isLoading;

  void setUser(String userId, String name, String email, String token) async {
    _userId = userId;
    _userName = name;
    _userEmail = email;
    _token = token;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('token', token);

    notifyListeners();
  }

  // Novo método para login com Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _googleAuthService.signInWithGoogle();

      if (result != null && result['success'] == true) {
        final user = result['user'];

        // Salvar dados do usuário
        setUser(
          user['id'].toString(),
          user['name'] ?? '',
          user['email'] ?? '',
          result['token'],
        );

        _isLoading = false;
        notifyListeners();

        return {
          'success': true,
          'message': result['message'],
        };
      } else {
        _isLoading = false;
        notifyListeners();

        return {
          'success': false,
          'error': result?['error'] ?? 'Erro desconhecido',
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return {
        'success': false,
        'error': 'Erro interno: $e',
      };
    }
  }

  Future<void> signOut() async {
    await _googleAuthService.signOut();
    await clearUser();
  }

  static UserProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<UserProvider>(context, listen: listen);
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? "";
    _userName = prefs.getString('userName') ?? "";
    _userEmail = prefs.getString('userEmail') ?? "";
    _token = prefs.getString('token') ?? "";

    notifyListeners();
  }

  Future<void> clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('token');

    _userId = "";
    _userName = "";
    _userEmail = "";
    _token = "";

    notifyListeners();
  }

  // Verificar se está logado
  bool get isLoggedIn => _token.isNotEmpty && _userId.isNotEmpty;
}
