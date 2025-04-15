import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // kIsWeb 사용

String client_id = "194283088715-clqaongemkmhhd4n3fcq9oflqsamv26q.apps.googleusercontent.com";

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _status = 'Not authenticated';

  // ✅ 구글 로그인 함수
  Future<void> _signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? client_id
            : null,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _status = 'Google sign-in cancelled';
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        _status = 'Signed in with Google: ${userCredential.user?.displayName}';
      });
    } catch (e) {
      setState(() {
        _status = 'Google sign-in error: $e';
      });
      print(e);
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        _status = 'Signed in anonymously: ${userCredential.user?.uid}';
      });
    } catch (e) {
      setState(() {
        _status = 'Anonymous sign-in error: $e';
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signInAnonymously,
              child: const Text('익명 로그인'),
            ),
            GoogleAuthProvider(client_id: client_id)
            ,

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: const Text('구글 아이디로 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
