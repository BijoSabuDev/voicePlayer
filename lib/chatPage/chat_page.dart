// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:audioplayer/chatPage/audio_functions.dart';

import 'package:audioplayer/chatServices/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:voice_message_package/voice_message_package.dart';

class ChatScreen extends StatefulWidget {
  final String chattingWith;
  final String userName;
  const ChatScreen(
      {super.key, required this.chattingWith, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ValueNotifier<String?> currentPlayingAudioSrcNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<bool> isAudioPlayingNotifier = ValueNotifier<bool>(false);

  final _firebaseAuth = FirebaseAuth.instance;

  final _chatService = ChatServices();

  final TextEditingController msgController = TextEditingController();

  final AudioServices audioServices = AudioServices();

  final ChatServices chatServices = ChatServices();

  AudioRecorder? _audioRecorder;

  String currentAudioPath = '';

  bool? isRecording;

  @override
  void initState() {
    _audioRecorder = AudioRecorder();
    isRecording = false;
    super.initState();
  }

  @override
  void dispose() {
    // _audioRecorder!.dispose();
    msgController.dispose();
    super.dispose();
  }

  void _startRecording() async {
    PermissionStatus permissionStatus = await Permission.microphone.status;

    if (permissionStatus.isDenied) {
      await Permission.microphone.request();
    }
    setState(() {
      isRecording = true;
      currentAudioPath = '';
    });

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';
    String audioFileName = 'audio_$formattedDate.m4a';
    String audioFilePath = '$tempPath/$audioFileName';

    _audioRecorder!.start(const RecordConfig(encoder: AudioEncoder.aacLc),
        path: audioFilePath);
  }

  void _stopRecording() async {
    setState(() {
      isRecording = false;
    });
    String? filePath = await _audioRecorder!.stop();
    // if (kDebugMode) {
    //   print(filePath);
    // }
    setState(() {
      currentAudioPath = filePath!;
    });
    if (kDebugMode) {
      print(currentAudioPath);
    }
  }

  Future<String> uploadAudioToFirebaseStorage(String filePath) async {
    try {
      File audioFile = File(filePath);
      String fileName = audioFile.path.split('/').last;

      var ref = FirebaseStorage.instance.ref('audios/$fileName');

      await ref.putFile(audioFile);
      final downloadUrl = await ref.getDownloadURL();

      if (kDebugMode) {
        print('Audio file uploaded to Firebase Storage successfully!');
      }
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading audio file to Firebase Storage: $e');
      }
      return '';
    }
  }

  void updateCurrentPlayingAudio(String? audioSrc) {
    currentPlayingAudioSrcNotifier.value = audioSrc;
  }

  void updateIsAudioPlaying(bool isPlaying) {
    isAudioPlayingNotifier.value = isPlaying;
  }

  void stopPreviousAudio() {
    if (isAudioPlayingNotifier.value) {
      currentPlayingAudioSrcNotifier.value = null;
      updateIsAudioPlaying(false);
    }
  }

  // final audioRecord = AudioRecord();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(
          widget.userName,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('android/assets/watsapp.png'),
                fit: BoxFit.cover)),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: _chatList()),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        if (!isRecording!)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter message',
                                  label: const Text(''),
                                  focusColor: Colors.black,
                                  fillColor: Colors.black,
                                  disabledBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(12)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                controller: msgController,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        if (isRecording!)
                          const Expanded(child: Text('RECORDING')),
                        IconButton(
                          icon: Icon(
                            isRecording! ? Icons.stop : Icons.mic,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            if (isRecording!) {
                              _stopRecording();
                            } else {
                              _startRecording();
                            }
                          },
                        ),
                        IconButton(
                          onPressed: () async {
                            if (currentAudioPath == '') {
                              if (kDebugMode) {
                                print(currentAudioPath);
                              }
                              if (kDebugMode) {
                                print('message to send ${msgController.text}');
                              }
                              chatServices.sendMessage(widget.chattingWith,
                                  msgController.text, msgController);
                            } else {
                              if (kDebugMode) {
                                print(currentAudioPath);
                              }

                              final audioUrl = await audioServices
                                  .uploadAudioToFirebaseStorage(
                                      currentAudioPath);
                              chatServices.sendMessage(
                                  widget.chattingWith, audioUrl, msgController);
                            }
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.green,
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatBox(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    var color = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? const Color(0xFF00a884)
        : Colors.grey[800];

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                // Text(
                //   data['senderEmail'],
                //   style: const TextStyle(
                //     fontSize: 8,
                //   ),
                // ),
                if (data['message'].toString().startsWith('https://'))
                  ValueListenableBuilder(
                      valueListenable: currentPlayingAudioSrcNotifier,
                      builder: (context, value, _) {
                        void updateCurrentPlayingAudio(String? audioSrc) {
                          currentPlayingAudioSrcNotifier.value = audioSrc;
                        }

                        void updateIsAudioPlaying(bool isPlaying) {
                          isAudioPlayingNotifier.value = isPlaying;
                        }

                        // final isPlaying = value == data['message'];
                        return VoiceMessageView(
                          circlesColor: Colors.black26,
                          activeSliderColor: Colors.white,
                          backgroundColor: Colors.grey.withOpacity(0.4),
                          controller: VoiceController(
                            audioSrc: data['message'],
                            maxDuration: const Duration(seconds: 60),
                            isFile: false,
                            onComplete: () {},
                            onPause: () {},
                            onPlaying: () {
                              if (currentPlayingAudioSrcNotifier.value !=
                                  data['message']) {
                                stopPreviousAudio();
                                updateCurrentPlayingAudio(data['message']);
                              }

                              updateIsAudioPlaying(true);
                            },
                          ),
                        );
                      })
                else
                  Text(
                    data['message'],
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.chattingWith,
        _firebaseAuth.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading....');
        }
        return ListView(
          children: snapshot.data!.docs
              .map((messages) => _chatBox(messages))
              .toList(),
        );
      },
    );
  }
}
