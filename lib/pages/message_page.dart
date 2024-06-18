import 'package:app_teste4/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos'),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar os contatos'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (_auth.currentUser!.uid != data['uid']) {
      return FutureBuilder<int>(
        future: _countUnreadMessages(data['uid']),
        builder: (context, snapshot) {
          int unreadCount = snapshot.data ?? 0;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: data['profile_pic_url'] != null
                      ? NetworkImage(data['profile_pic_url'])
                      : null,
                  child: data['profile_pic_url'] == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                title: Text(data['username']),
                subtitle: Text(data['bio'] ?? 'No bio available'),
                trailing: const CircularProgressIndicator(),
              ),
            );
          }
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: data['profile_pic_url'] != null
                    ? NetworkImage(data['profile_pic_url'])
                    : null,
                child: data['profile_pic_url'] == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              title: Text(data['username']),
              subtitle: Text(data['bio'] ?? 'No bio available'),
              trailing: unreadCount > 0
                  ? Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
              onTap: () async {
                await _markMessagesAsRead(data['uid']);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiveUserName: data['username'],
                      receiverUserID: data['uid'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Future<int> _countUnreadMessages(String receiverUserID) async {
    String currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, receiverUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserID)
          .where('unread', isEqualTo: true)
          .get();

      print("Unread messages count for $receiverUserID: ${snapshot.docs.length}");
      return snapshot.docs.length;
    } catch (e) {
      print("Error counting unread messages: $e");
      return 0;
    }
  }

  Future<void> _markMessagesAsRead(String receiverUserID) async {
    String currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, receiverUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    QuerySnapshot unreadMessages = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserID)
        .where('unread', isEqualTo: true)
        .get();

    for (var doc in unreadMessages.docs) {
      doc.reference.update({'unread': false});
    }
  }
}
