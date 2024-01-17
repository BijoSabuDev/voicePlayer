import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class AudioServices {
  Future<String> uploadAudioToFirebaseStorage(String filePath) async {
    try {
      File audioFile = File(filePath);
      String fileName = audioFile.path.split('/').last;

      var ref = FirebaseStorage.instance.ref().child('audios/$fileName');

      await ref.putFile(audioFile);
      final downloadUrl = await ref.getDownloadURL();

      print('Audio file uploaded to Firebase Storage successfully!');
      return downloadUrl;
    } catch (e) {
      print('Error uploading audio file to Firebase Storage: $e');
      return '';
    }
  }

  // Future<String?> uploadAudioToFbStorage(String filePath) async {
  //   try {
  //     File audioFile = File(filePath);
  //     String fileName = audioFile.path.split('/').last;

  //     var ref = FirebaseStorage.instance.ref().child('audios/$fileName');

  //     await ref.putFile(audioFile);
  //     final downloadUrl = await ref.getDownloadURL();

  //     print('Audio file uploaded to Firebase Storage successfully!');
  //     return downloadUrl;
  //   } catch (e) {
  //     print('Error uploading audio file to Firebase Storage: $e');
  //     return null;
  //   }
  // }
}
