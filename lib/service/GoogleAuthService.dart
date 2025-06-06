import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleAuthService {
  final String baseUrl = 'https://aiproject-todolist-huq1.onrender.com/api';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '829233786035-d9n64nblh3je4te5tjj9ltt9iv952sr4.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('Iniciando login com Google...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Login cancelado pelo usuário');
        return {
          'success': false,
          'error': 'Login cancelado pelo usuário',
        };
      }

      print('Usuário Google obtido: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        print('Erro: ID Token nulo');
        return {
          'success': false,
          'error': 'Erro ao obter token do Google',
        };
      }

      print('Token obtido: ${idToken.substring(0, 50)}...');
      print('Enviando para backend: $baseUrl/users/google');

      // 3. Enviar token para seu backend Java Spring Boot
      final response = await http.post(
        Uri.parse('$baseUrl/users/google'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': idToken, // Seu backend espera 'token'
        }),
      );

      print('Status da resposta: ${response.statusCode}');
      print('Corpo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'success': true,
          'token': responseData['token'], // JWT do seu backend
          'user': responseData['user'],
          'message': responseData['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Erro no servidor',
        };
      }
    } catch (e) {
      print('Erro no login Google: $e');
      return {
        'success': false,
        'error': 'Erro interno: $e',
      };
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
