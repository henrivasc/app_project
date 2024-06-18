import 'dart:io';
import 'package:app_teste4/components/chat_bubble.dart';
import 'package:app_teste4/pages/favorite_messages_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:app_teste4/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiveUserName;
  final String receiverUserID;

  const ChatPage({
    required this.receiveUserName,
    required this.receiverUserID,
    super.key,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  bool _isFavoriteFilterEnabled = false;

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;
    await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
    _messageController.clear();
  }

  void _sendImageMessage(String imageUrl) async {
    await _chatService.sendMessage(widget.receiverUserID, '', imageUrl: imageUrl);
  }

  void _sendFileMessage(String fileUrl, String fileName) async {
    await _chatService.sendMessage(widget.receiverUserID, '', fileUrl: fileUrl, fileName: fileName);
  }

  void _toggleFavoriteStatus(String chatRoomId, String messageId, bool isFavorite) {
    _chatService.toggleFavoriteStatus(chatRoomId, messageId, isFavorite);
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final String imageUrl = await _chatService.uploadImage(File(pickedImage.path));
      _sendImageMessage(imageUrl);
    }
  }

  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final File file = File(result.files.single.path!);
      final String fileName = result.files.single.name;
      final String fileUrl = await _chatService.uploadFile(file, fileName);
      _sendFileMessage(fileUrl, fileName);
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, widget.receiverUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiveUserName),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteMessagesPage(chatRoomId: chatRoomId),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _isFavoriteFilterEnabled
                  ? _chatService.getFavoriteMessages(chatRoomId)
                  : _chatService.getMessages(currentUserId, widget.receiverUserID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhuma mensagem'));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot doc = snapshot.data!.docs[index];
                    final bool isSentByCurrentUser = doc['senderId'] == currentUserId;
                    final Color bubbleColor = isSentByCurrentUser ? Colors.blue : Colors.grey;
                    final bool isFavorite = (doc['favoritedBy'] as List<dynamic>).contains(currentUserId);

                    return Align(
                      alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: ChatBubble(
                        message: doc['message'],
                        color: bubbleColor,
                        time: _formatTimestamp(doc['timestamp']),
                        isFavorite: isFavorite,
                        onFavoriteToggle: () => _toggleFavoriteStatus(chatRoomId, doc.id, !isFavorite),
                        imageUrl: doc['imageUrl'],
                        fileUrl: doc['fileUrl'],
                        fileName: doc['fileName'],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Digite uma mensagem...'),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
