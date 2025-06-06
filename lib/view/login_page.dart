import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i/service/userservice.dart';
import 'package:i/view/regiser_page.dart';
import 'package:provider/provider.dart';
import 'package:i/service/user_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UserService apiService = UserService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  void _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    var user = await apiService.login(
      emailController.text,
      passwordController.text,
      context,
    );

    setState(() {
      isLoading = false;
    });

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home_page');
    } else {
      setState(() {
        errorMessage = 'Login falhou. Verifique suas credenciais.';
      });
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final result = await userProvider.signInWithGoogle();

      setState(() {
        isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(result['message'] ?? 'Login realizado com sucesso!')),
        );

        // Navegar para home
        Navigator.pushReplacementNamed(context, '/home_page');
      } else {
        setState(() {
          errorMessage = 'Erro no login com Google: ${result['error']}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro no login com Google: $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login',
            style: GoogleFonts.lato(
                color: Color.fromARGB(255, 40, 33, 145),
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 60),
            child: Icon(
              Icons.grid_goldenratio_outlined,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage()),
              );
            },
            child: Text(
              'Registre-se',
              style: GoogleFonts.lato(
                  color: Color.fromARGB(255, 40, 33, 145),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Campo Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: 'e-mail',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  hintText: 'Digite seu email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.black),
                  )),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.black),
              cursorHeight: 20,
              cursorWidth: 2,
              cursorColor: Colors.black,
              cursorRadius: const Radius.circular(50),
            ),
            const SizedBox(height: 16),

            // Campo Senha
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'password',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.black),
                  )),
              obscureText: true,
              style: const TextStyle(color: Colors.black),
              cursorHeight: 20,
              cursorWidth: 2,
              cursorColor: Colors.black,
              cursorRadius: const Radius.circular(50),
            ),

            // Mensagem de erro
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24),

            // Botão Login Normal
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF319795),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 72,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

            const SizedBox(height: 20),

            // Divisor
            Text(
              'Or try logging in with',
              style: TextStyle(color: Color(0xFF319795)),
            ),
            const SizedBox(height: 20),

            // Botão Google Sign-In
            isLoading
                ? Container()
                : ElevatedButton.icon(
                    onPressed: _loginWithGoogle,
                    icon: Icon(Icons.login, color: Colors.white),
                    label: Text('Entrar com Google',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
