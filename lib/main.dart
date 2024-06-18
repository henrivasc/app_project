import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_teste4/pages/login.page.dart';
import 'package:app_teste4/pages/register.page.dart';
import 'package:app_teste4/pages/home.dart';
import 'package:app_teste4/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyCrlxkYp0vmXhI6Ve5WRM03pdASw1TLdiw",
  authDomain: "teste1-6829a.firebaseapp.com",
  projectId: "teste1-6829a",
  storageBucket: "teste1-6829a.appspot.com",
  messagingSenderId: "208845841849",
  appId: "1:208845841849:web:18ed8f9253e082eb268268",
  measurementId: "G-1LXXGBFPLQ",
);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: firebaseConfig);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late FirebaseMessaging _firebaseMessaging;
  String initialRoute = '/splash';

  @override
  void initState() {
    super.initState();
    _firebaseMessaging = FirebaseMessaging.instance;

    _firebaseMessaging.requestPermission();

    _firebaseMessaging.getToken().then((token) {
      print("Device Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Mensagem recebida: ${message.notification?.title}");
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Mensagem aberta: ${message.notification?.title}");
      _navigateToScreen(message.data);
    });

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final password = prefs.getString('user_password');

    if (email != null && password != null) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: password);
        setState(() {
          initialRoute = '/home';
        });
      } catch (e) {
        setState(() {
          initialRoute = '/login';
        });
      }
    } else {
      setState(() {
        initialRoute = '/login';
      });
    }
  }

  void _showNotification(RemoteMessage message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message.notification?.title ?? 'Notificação'),
          content: Text(message.notification?.body ?? 'Você recebeu uma nova notificação.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToScreen(Map<String, dynamic> data) {
    Navigator.pushNamed(context, '/home', arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => Home(context: context,),
        '/register': (context) => RegisterPage(),
        '/splash': (context) => SplashScreen(initialRoute: initialRoute),
      },
      initialRoute: initialRoute,
    );
  }
}
