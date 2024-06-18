import 'package:app_teste4/pages/message_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_teste4/components/drawer.dart';
import 'package:app_teste4/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  final BuildContext context;
  Home({super.key, required this.context});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection("Users");

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(widget.context, '/login');
  }

  void goToProfilePage() {
    // pop drawer
    Navigator.pop(widget.context);

    // go to profile page
    Navigator.push(
      widget.context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  void goToMessagePage() {
    // pop drawer
    Navigator.pop(widget.context);

    // go to message page
    Navigator.push(
      widget.context,
      MaterialPageRoute(builder: (context) => MessagePage()),
    );
  }

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: userCollection.doc(user.email).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: AppBar(
              backgroundColor: Colors.blue,
              title: Text("Bem Vindo ${user.email}"),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: AppBar(
              backgroundColor: Colors.blue,
              title: Text("Bem Vindo ${user.email}"),
            ),
            body: Center(child: Text('Erro ao carregar dados')),
          );
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final username = userData?['username'] ?? 'Usuário';
        final profilePicUrl = userData?['profile_pic_url'];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text("Página Inicial"),
          ),
          drawer: MyDrawer(
            onProfileTap: goToProfilePage,
            onMessageTap: goToMessagePage,
            onSignOut: signOut,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'BEM VINDO',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 80),
                      Text(
                        capitalize(username),
                        textAlign: TextAlign.center, // Centraliza o texto
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 40),
                      profilePicUrl != null
                          ? CircleAvatar(
                              radius: 85,  // Aumenta o tamanho da imagem
                              backgroundImage: NetworkImage(profilePicUrl),
                            )
                          : CircleAvatar(
                              radius: 70,  // Aumenta o tamanho do ícone padrão
                              child: Icon(
                                Icons.person,
                                size: 70,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
