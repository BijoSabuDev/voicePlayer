import 'package:audioplayer/chatServices/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatServices extends ChangeNotifier {
  final _firebaseAuth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  void sendMessage(String receiverId, String message,
      TextEditingController msgController) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email!;
    final Timestamp timeStamp = Timestamp.now();

    ChatModel newMessage = ChatModel(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timeStamp);

    List<String> ids = [currentUserId, receiverId];

    ids.sort();

    String chatRoomId = ids.join('_');

    msgController.clear();
    await _fireStore
        .collection('chat')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    print('message send');
  }

  void sendAudioFile() async {}

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _fireStore
        .collection('chat')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
