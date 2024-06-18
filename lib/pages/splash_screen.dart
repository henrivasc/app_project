import 'package:app_teste4/pages/login.page.dart';
import 'package:app_teste4/pages/register.page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final String initialRoute;
  const SplashScreen({super.key, required this.initialRoute});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToInitialRoute();
  }

  void _navigateToInitialRoute() async {
    await Future.delayed(const Duration(seconds: 3)); // Adiciona um atraso de 3 segundos
    Navigator.pushReplacementNamed(context, widget.initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100), // Adiciona espaço acima do texto "Bem Vindo"
            const Text(
              'Bem Vindo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 50), // Espaço entre o texto e os botões
            SizedBox(
              width: 200, // Largura dos botões aumentada
              height: 50, // Altura dos botões aumentada
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Cor azul para o botão
                ),
                child: const Text('Faça seu login'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200, // Largura dos botões aumentada
              height: 50, // Altura dos botões aumentada
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Cor laranja para o botão
                ),
                child: const Text('Faça seu cadastro'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
