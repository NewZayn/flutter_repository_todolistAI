import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:i/service/userservice.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final UserService apiService = UserService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        '829233786035-d9n64nblh3je4te5tjj9ltt9iv952sr4.apps.googleusercontent.com',
  );

  void _register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    bool success = await apiService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        errorMessage = 'Erro ao registrar. Tente novamente.';
      });
    }
  }

  void _registerWithGoogle() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          errorMessage = 'Registro com Google cancelado.';
          isLoading = false;
        });
        return;
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        setState(() {
          errorMessage = 'Não foi possível obter o token do Google.';
          isLoading = false;
        });
        return;
      }
      final result = null;
      setState(() => isLoading = false);
      if (result != null) {
        Navigator.pushReplacementNamed(context, '/home_page');
      } else {
        setState(() => errorMessage = 'Erro no registro com Google.');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro no registro com Google: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register, child: Text('Registrar')),
            SizedBox(height: 20),
            isLoading
                ? Container()
                : ElevatedButton.icon(
                    onPressed: _registerWithGoogle,
                    icon: Icon(Icons.login),
                    label: Text('Registrar com Google'),
                  ),
          ],
        ),
      ),
    );
  }
}
