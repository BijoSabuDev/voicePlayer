// import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';

// import 'package:flutter/foundation.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:record/record.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// class AudioRecordd extends StatefulWidget {
//   AudioRecordd({super.key});

//   // get currentAudioPath => null;

//   // get isRecording => null;
//   AudioRecorder? _audioRecorder;

//   String currentAudioPath = '';

//   bool? isRecording;
//   @override
//   _AudioRecorddState createState() => _AudioRecorddState();
// }

// class _AudioRecorddState extends State<AudioRecordd> {
//   // AudioRecorder? _audioRecorder;

//   // String currentAudioPath = '';

//   // bool? isRecording;
//   // bool _isPlaying = false;

//   @override
//   void initState() {
//     widget._audioRecorder = AudioRecorder();
//     widget.isRecording = false;
//     super.initState();
//   }

//   @override
//   void dispose() {
//     widget._audioRecorder!.dispose();

//     super.dispose();
//   }

//   void _startRecording() async {
//     PermissionStatus permissionStatus = await Permission.microphone.status;

//     if (permissionStatus.isDenied) {
//       await Permission.microphone.request();
//     }
//     setState(() {
//       widget.isRecording = true;
//       widget.currentAudioPath = '';
//     });

//     Directory tempDir = await getTemporaryDirectory();
//     String tempPath = tempDir.path;

//     DateTime now = DateTime.now();
//     String formattedDate =
//         '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';
//     String audioFileName = 'audio_$formattedDate.m4a';
//     String audioFilePath = '$tempPath/$audioFileName';

//     widget._audioRecorder!.start(
//         const RecordConfig(encoder: AudioEncoder.pcm16bits),
//         path: audioFilePath);
//   }

//   void _stopRecording() async {
//     setState(() {
//       widget.isRecording = false;
//     });
//     String? filePath = await widget._audioRecorder!.stop();
//     // if (kDebugMode) {
//     //   print(filePath);
//     // }
//     setState(() {
//       widget.currentAudioPath = filePath!;
//     });
//     if (kDebugMode) {
//       print(widget.currentAudioPath);
//     }
//   }

//   Future<String> uploadAudioToFirebaseStorage(String filePath) async {
//     try {
//       File audioFile = File(filePath);
//       String fileName = audioFile.path.split('/').last;

//       var ref = FirebaseStorage.instance.ref('audios/$fileName');

//       await ref.putFile(audioFile);
//       final downloadUrl = await ref.getDownloadURL();

//       print('Audio file uploaded to Firebase Storage successfully!');
//       return downloadUrl;
//     } catch (e) {
//       print('Error uploading audio file to Firebase Storage: $e');
//       return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         IconButton(
//           icon: Icon(
//             widget.isRecording! ? Icons.stop : Icons.mic,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             if (widget.isRecording!) {
//               _stopRecording();
//             } else {
//               _startRecording();
//             }
//           },
//         )

//         // ... Other UI code
//       ],
//     );
//   }
// }
