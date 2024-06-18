// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:app_teste4/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onMessageTap;
  final void Function()? onSignOut;

  const MyDrawer ({super.key, required this.onProfileTap, required this.onSignOut, required this.onMessageTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blue[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            // cabeçario 
          const DrawerHeader(
            child: Icon(
              Icons.person,
              color: Color(0xfffd7e14),
              size: 64,
            ),
          ),

          // pagina inicial 
          MyListTile(
            icon: Icons.home,
             text: 'H O M E',
             onTap: () => Navigator.pop(context),
            ),

          // Indo para a página de perfil 
          MyListTile(
            icon: Icons.person,
              text: 'P R O F I L E',
              onTap: onProfileTap,
              ),


          //Indo para o chat (teste)
          MyListTile(
            icon: Icons.message,
            text: 'M E S S A G E S',
            onTap: onMessageTap,

          ),
          
          ],

          ),

           // pagina inicial 
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout,
               text: 'L O G O U T',
               onTap: onSignOut,
              ),
          ),

          
        ],
      ),
    );
  }
}