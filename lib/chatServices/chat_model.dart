import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;

  ChatModel(
      {required this.senderId,
      required this.senderEmail,
      required this.receiverId,
      required this.message,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
