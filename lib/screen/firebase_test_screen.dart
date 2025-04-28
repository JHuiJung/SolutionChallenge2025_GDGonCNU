import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // kIsWeb 사용
import 'package:cloud_firestore/cloud_firestore.dart';
import './firestoreManager.dart';

String firebase_client_id = "194283088715-clqaongemkmhhd4n3fcq9oflqsamv26q.apps.googleusercontent.com";



class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});


  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _status = 'Not authenticated';



  // ✅ 구글 로그인 함수
  Future<void> _signInWithGoogle() async {

    if (kIsWeb) {
      await signInWithGoogleForWeb();
    } else {
      await signInWithGoogleForMobile();
    }

    User? user = FirebaseAuth.instance.currentUser;

    print(user?.email);

  }

  // 웹 테스트용 구글 로그인 함수
  Future<void> signInWithGoogleForWeb() async {
    try {
      final googleProvider = GoogleAuthProvider();

      // Optional: Add scopes or custom parameters
      // googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');

      final userCredential =
      await FirebaseAuth.instance.signInWithPopup(googleProvider);

      setState(() {
        _status = 'Signed in with Google: ${userCredential.user?.displayName}';
      });
      print("Signed in as ${userCredential.user?.displayName}");

    } catch (e) {
      setState(() {
        _status = 'Google sign-in error: $e';
      });
      print("Google sign-in failed: $e");
    }
  }

  // 모바일 구글 로그인 함수
  Future<void> signInWithGoogleForMobile() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // 사용자가 로그인 취소함
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    setState(() {
      _status = 'Signed in with Google: ${userCredential.user?.displayName}';
    });
    print("Signed in as ${userCredential.user?.displayName}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Firebase Test')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Let's Get Started",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            ElevatedButton(
              onPressed: addUser,
              child: Text('사용자 추가'),
            ),

            const SizedBox(height: 25),

            // Google G Logo Button
            GestureDetector(
              onTap: _signInWithGoogle,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  //border: Border.all(color: Colors.grey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/Google__G__logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Start with Google',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

}
