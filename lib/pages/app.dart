import 'package:flutter/material.dart';
import 'package:app_teste4/pages/home.dart';

import 'login.page.dart';
import 'register.page.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(
        useMaterial3: false,
        // primarySwatch: Colors.blue,
      ),
      routes: {
        "/login": (context) =>  LoginPage(),
        "/home" : (context) =>  Home(context: context,),
        "/register": (context) => RegisterPage(),
      },
      initialRoute: '/login',
    );
  }
}