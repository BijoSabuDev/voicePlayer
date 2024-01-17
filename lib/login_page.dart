import 'package:audioplayer/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Login Or Sign Up',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('android/assets/watsapp.png'),
                fit: BoxFit.cover)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 120,
            ),
            const Text(
              'Login now',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter username',
                  hintStyle: const TextStyle(color: Colors.black),
                  label: const Text(''),
                  focusColor: Colors.grey[200],
                  fillColor: Colors.grey[200],
                  disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12)),
                ),
                controller: _loginController,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  hintStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  label: const Text(''),
                  focusColor: Colors.grey[200],
                  fillColor: Colors.grey[200],
                  disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12)),
                ),
                controller: _passwordController,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 50,
              width: 220,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    maximumSize: const Size(120, 50),
                  ),
                  onPressed: () async {
                    final user = await _loginUser(_loginController.text,
                        _passwordController.text, context);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return UsersOfApp(
                        user: user!.user!.email!,
                      );
                    }));
                  },
                  child: const Text(
                    'Login now',
                    style: TextStyle(color: Colors.black),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'OR',
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              width: 160,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      maximumSize: const Size(200, 50)),
                  onPressed: () async {
                    final user = await _signUpUser(
                      _loginController.text,
                      _passwordController.text,
                      context,
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return UsersOfApp(
                        user: user!.user!.email!,
                      );
                    }));
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(color: Colors.black),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Future<UserCredential?> _loginUser(
      String loginName, String password, BuildContext context) async {
    try {
      if (loginName.isEmpty && password.isEmpty) {
        throw 'loginandpassword required';
      } else {
        final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        UserCredential userCredential = await firebaseAuth
            .signInWithEmailAndPassword(email: loginName, password: password);
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message!),
          duration: const Duration(seconds: 3),
        ),
      );
      return null;
    }
  }

  Future<UserCredential?> _signUpUser(
      String loginName, String password, BuildContext context) async {
    try {
      if (loginName.isEmpty && password.isEmpty) {
        throw 'loginandpassword required';
      } else {
        final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        final FirebaseFirestore fireStore = FirebaseFirestore.instance;
        UserCredential userCredential =
            await firebaseAuth.createUserWithEmailAndPassword(
                email: loginName, password: password);
        fireStore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email
        });

        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message!),
          duration: const Duration(seconds: 3),
        ),
      );
      return null;
    }
  }
}
