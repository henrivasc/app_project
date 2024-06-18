import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<QuerySnapshot> getMessages(String currentUserId, String receiverUserId) {
    List<String> ids = [currentUserId, receiverUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getFavoriteMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('favoritedBy', arrayContains: _auth.currentUser!.uid)
        .snapshots();
  }

  Future<void> sendMessage(
    String receiverUserId,
    String message, {
    String? imageUrl,
    String? fileUrl,
    String? fileName,
  }) async {
    String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add({
      'senderId': currentUserId,
      'receiverId': receiverUserId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'favoritedBy': [],
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'unread': true,
    });
  }

  Future<void> toggleFavoriteStatus(String chatRoomId, String messageId, bool isFavorite) async {
    String currentUserId = _auth.currentUser!.uid;
    DocumentReference messageRef = _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').doc(messageId);

    if (isFavorite) {
      await messageRef.update({
        'favoritedBy': FieldValue.arrayUnion([currentUserId]),
      });
    } else {
      await messageRef.update({
        'favoritedBy': FieldValue.arrayRemove([currentUserId]),
      });
    }
  }

  Future<String> uploadImage(File image) async {
    String currentUserId = _auth.currentUser!.uid;
    Reference storageRef = _storage.ref().child('chat_images/$currentUserId/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadFile(File file, String fileName) async {
    String currentUserId = _auth.currentUser!.uid;
    Reference storageRef = _storage.ref().child('chat_files/$currentUserId/$fileName');
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }
}
