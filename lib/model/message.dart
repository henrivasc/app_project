import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderUsername;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final String? imageUrl;
  final String? fileUrl;
  final String? fileName;
  final List<dynamic> favoritedBy;
  final bool unread;

  Message({
    required this.senderId,
    required this.senderUsername,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.imageUrl,
    this.fileUrl,
    this.fileName,
    this.favoritedBy = const [],
    this.unread = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderUsername': senderUsername,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'favoritedBy': favoritedBy,
      'unread': unread,
    };
  }
}
