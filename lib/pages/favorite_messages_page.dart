import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_teste4/chat/chat_service.dart';
import 'package:intl/intl.dart';

class FavoriteMessagesPage extends StatelessWidget {
  final String chatRoomId;
  final ChatService _chatService = ChatService();

  FavoriteMessagesPage({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens Favoritas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getFavoriteMessages(chatRoomId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma mensagem favorita.'));
          }

          List<DocumentSnapshot> docs = snapshot.data!.docs;

          // Ordena as mensagens pelo timestamp, mais recente primeiro
          docs.sort((a, b) {
            Timestamp aTimestamp = a['timestamp'] as Timestamp;
            Timestamp bTimestamp = b['timestamp'] as Timestamp;
            return bTimestamp.compareTo(aTimestamp);
          });

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = docs[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              var timestamp = data['timestamp'] as Timestamp;
              var time = DateFormat('HH:mm').format(timestamp.toDate());
              var message = data['message'] ?? '';
              var imageUrl = data['imageUrl'] ?? '';
              var fileUrl = data['fileUrl'] ?? '';
              var fileName = data['fileName'] ?? '';

              return ListTile(
                title: imageUrl.isNotEmpty
                    ? Image.network(imageUrl)
                    : fileUrl.isNotEmpty
                        ? Row(
                            children: [
                              const Icon(Icons.insert_drive_file),
                              const SizedBox(width: 8),
                              Text(fileName),
                            ],
                          )
                        : Text(message),
                subtitle: Text('Enviado às: $time'),
              );
            },
          );
        },
      ),
    );
  }
}
