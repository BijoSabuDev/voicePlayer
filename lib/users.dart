import 'package:audioplayer/chatPage/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UsersOfApp extends StatelessWidget {
  final String user;
  const UsersOfApp({super.key, required this.user});

  Stream<QuerySnapshot<Map<String, dynamic>>> _getUsers() {
    final data = FirebaseFirestore.instance;
    return data.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.withOpacity(0.3),
        title: Text(
          'logged in as $user',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('android/assets/watsapp.png'),
                fit: BoxFit.cover)),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('no data'));
            } else {
              return Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    'All users',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final userData = snapshot.data!.docs[index].data();
                        if (kDebugMode) {
                          print(userData);
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (builder) {
                              final userId = userData['uid'];
                              final userEmail = userData['email'];
                              if (kDebugMode) {
                                print(userId);
                              }
                              return ChatScreen(
                                chattingWith: userId,
                                userName: userEmail,
                              );
                            }));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(
                                  userData['email'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
