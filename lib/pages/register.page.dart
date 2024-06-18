import 'dart:io';
import 'package:app_teste4/helper/helper_function.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_teste4/components/my_button.dart';
import 'package:app_teste4/components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controlador do Editor de Texto
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPwController = TextEditingController();
  File? _imageFile;

  // Método para selecionar imagem da galeria
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Método para fazer upload da imagem para o Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_pics/${emailController.text.split('@')[0]}.jpg');
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  // Método de Registrar o Usuário
  Future<void> registerUserIn(BuildContext context) async {
    // mostrar círculo de carregamento
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // certificar de que as senhas coincidem
    if (passwordController.text != confirmPwController.text) {
      // pop loading circle
      Navigator.pop(context);

      // show error message to user
      displayMessageToUser("As senhas não correspondem", context);
      return;
    }

    try {
      var credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      String? profilePicUrl;
      if (_imageFile != null) {
        profilePicUrl = await _uploadImage(_imageFile!);
      }

      // depois de criar um usuário, criar um novo documento no firestore chamada Users
      FirebaseFirestore.instance.collection("Users").doc(credential.user!.email).set({
        'uid': credential.user!.uid,
        'username': emailController.text.split('@')[0], // nome inicial
        'bio': 'Biografia vazia', // iniciando com uma biografia vazia
        'profile_pic_url': profilePicUrl, // URL inicial da imagem de perfil (pode ser nula)
      });

      Navigator.pushReplacementNamed(context, "/home");
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      // Exibir mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ex.message!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
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
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 50),

                    const Text(
                      'Crie sua conta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),

                    const SizedBox(height: 25,),

                    // Circle Avatar para escolher imagem
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null
                            ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 25,),

                    // Email Textfield
                    MyTextField(
                      controller: emailController,
                      hintText: 'Digite seu E-mail',
                      obscureText: false,
                    ),

                    const SizedBox(height: 25,),

                    // Password Textfield
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Digite sua senha',
                      obscureText: true,
                    ),

                    const SizedBox(height: 25,),

                    // Confirm Password Textfield
                    MyTextField(
                      controller: confirmPwController,
                      hintText: 'Confirme sua senha',
                      obscureText: true,
                    ),

                    const SizedBox(height: 25,),

                    // Botão de Registrar
                    MyButton(
                      onPressed: () => {registerUserIn(context)},
                      buttonText: 'Registrar',
                    ),

                    const SizedBox(height: 25,),

                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: const Text(
                        "Já possui uma conta?",
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
