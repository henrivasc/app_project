import 'dart:typed_data';

import 'package:app_teste4/components/text_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? _image;
  String? _profilePicUrl;

  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection("Users");

  Future<Uint8List?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      return File(pickedFile.path).readAsBytesSync();
    }
    return null;
  }

  Future<void> uploadImage() async {
    if (_image != null) {
      // Crie uma referência para o local onde a imagem será armazenada no Firebase Storage
      Reference ref = FirebaseStorage.instance.ref().child('user_profile_images').child(currentUser.uid);

      // Faça o upload da imagem para o Firebase Storage
      UploadTask uploadTask = ref.putData(_image!);

      // Obtenha a URL da imagem após o upload ser concluído
      uploadTask.then((res) async {
        String imageUrl = await res.ref.getDownloadURL();

        // Atualize a URL da imagem no documento do usuário no Firestore
        await userCollection.doc(currentUser.email).update({'profile_pic_url': imageUrl});

        // Atualize o estado com a nova URL da imagem
        setState(() {
          _profilePicUrl = imageUrl;
        });
      });
    }
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blue,
        title: Text(
          "Edit $field",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.white),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Salvar',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              Navigator.pop(context);
              if (newValue.trim().isNotEmpty) {
                await userCollection.doc(currentUser.email).update({field: newValue});
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Página de Perfil'),
        backgroundColor: Colors.blue[700],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.email).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            _profilePicUrl = userData['profile_pic_url'];

            return ListView(
              children: [
                SizedBox(height: 25,),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundImage: _image != null 
                            ? MemoryImage(_image!)
                            : _profilePicUrl != null 
                              ? NetworkImage(_profilePicUrl!) 
                              : null,
                        child: _image == null && _profilePicUrl == null
                            ? Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            Uint8List? img = await pickImage(ImageSource.gallery);
                            setState(() {
                              _image = img;
                            });
                            await uploadImage();
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.camera_alt, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 25,),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'Detalhes da Conta',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                MyTextBox(
                    text: userData['username'],
                    sectionName: 'username',
                    onPressed: () => editField('username')),
                MyTextBox(
                    text: userData['bio'],
                    sectionName: 'bio',
                    onPressed: () => editField('bio')),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ${snapshot.error}'),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
