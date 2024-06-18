import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_teste4/components/my_button.dart';
import 'package:app_teste4/components/my_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  void _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        usernameController.text = prefs.getString('user_email') ?? '';
        passwordController.text = prefs.getString('user_password') ?? '';
      }
    });
  }

  void _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('remember_me', _rememberMe);
  }

  void signUserIn(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: usernameController.text, password: passwordController.text);

      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user_email', usernameController.text);
        prefs.setString('user_password', passwordController.text);
      } else {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('user_email');
        prefs.remove('user_password');
      }

      Navigator.pushReplacementNamed(context, "/home");
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Erro ao fazer login";
      if (e.code == 'user-not-found') {
        errorMessage = 'Usuário não encontrado';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const SizedBox(height: 50),
                  const Text(
                    'Olá! Seja bem Vindo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Digite seu E-mail',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Digite sua senha',
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                              _saveRememberMe();
                            });
                          },
                          side: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        const Text(
                          'Manter Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  MyButton(
                    onPressed: () => {signUserIn(context)},
                    buttonText: 'Logar',
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Não possui conta?",
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/register');
                        },
                        child: const Text(
                          "Cadastre-se agora",
                          style: TextStyle(
                            color: Color.fromARGB(255, 227, 100, 2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
