import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _status = 'Not authenticated';

  Future<void> _signInAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        _status = 'Signed in as: ${userCredential.user?.uid}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("FireBase Build 함수 실행");
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signInAnonymously,
              child: const Text('Sign in Anonymously'),
            ),
          ],
        ),
      ),
    );
  }
}
