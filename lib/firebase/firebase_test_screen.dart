import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // kIsWeb 사용
import 'package:cloud_firestore/cloud_firestore.dart';
import './firestoreManager.dart' as firestoreManager;

String firebase_client_id = "194283088715-clqaongemkmhhd4n3fcq9oflqsamv26q.apps.googleusercontent.com";



class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});


  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _status = 'Not authenticated';
  String testDummyEmail = "test2@dummy.com";
  String testDummyPassword = "password123";

  // ✅ 구글 로그인 함수
  Future<void> _signInWithGoogle(BuildContext _context) async {

    // 로그인 정보 가져오기
    final userinfo = FirebaseAuth.instance.currentUser;

    if (userinfo != null) {
      // 이미 로그인 되어 있음 → 메인화면으로 이동
      bool isRight = await firestoreManager.getUserInfoByEmail(userinfo!.email!);  // await 추가

      if(isRight)
      {
        Navigator.pushReplacementNamed(_context, '/main');
        return;
      }

    }

    // 로그인 안됨 → 로그인화면으로 이동
    if (kIsWeb) {
      await signInWithGoogleForWeb(_context);
    } else {
      await signInWithGoogleForMobile(_context);
    }

    User? user = FirebaseAuth.instance.currentUser;

    // Firestore에서 유저 정보 조회
    bool isMember = await firestoreManager.getUserInfoByEmail(user!.email!);

    print("😍 이벤트1");

    if (isMember) {
      print("😍 이벤트2");
      Navigator.pushReplacementNamed(_context, '/main');
    } else {
      print("😍 이벤트3");
      Navigator.pushReplacementNamed(_context, '/profile');
    }
  }


  // 웹 테스트용 구글 로그인 함수
  Future<void> signInWithGoogleForWeb(BuildContext context) async {
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
  Future<void> signInWithGoogleForMobile(BuildContext context) async {

    print("😍 모바일 이벤트1");

    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    print("😍 모바일 이벤트2");

    if (googleUser == null) {
      // 사용자가 로그인 취소함
      return;
    }

    print("😍 모바일 이벤트3");
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    print("😍 모바일 이벤트4");
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    print("😍 모바일 이벤트5");
    setState(() {
      _status = 'Signed in with Google: ${userCredential.user?.displayName}';
    });
    print("😍 Signed in as ${userCredential.user?.displayName}");
  }

  Future<void> signInWithEmailPassword({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        print("✅ 로그인 성공: ${user.email}");
        // 로그인 성공 후 화면 이동 등 처리

        bool isMember = await firestoreManager.getUserInfoByEmail(user!.email!);

        print("😍 이벤트1");

        if(isMember)
        {
          print("😍 이벤트2");
          Navigator.pushReplacementNamed(context, '/main');

        }
        else{
          print("😍 이벤트3");
          Navigator.pushReplacementNamed(context, '/profile');

        }
      }
    } on FirebaseAuthException catch (e) {
      print("❌ 로그인 실패: ${e.code} - ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Firebase Test')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                signInWithEmailPassword(
                  context: context,
                  email: testDummyEmail,
                  password: testDummyPassword,
                );
              },
              child: const Text(
                "테스트 더미 로그인",
                style: TextStyle(fontSize: 32),
              ),
            ),
            Image.asset(
              'assets/images/egg.png', // Assuming egg.png is in assets/images/
              height: 170, // Adjust size as needed based on your image
            ),
            SizedBox(height: 24),
            const Text(
              "Travel Local\nConnect Deeper",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            /*
            ElevatedButton(
              onPressed: addUser,
              child: Text('사용자 추가'),
            ),

             */

            const SizedBox(height: 50),

            // Google G Logo Button
            GestureDetector(
              onTap: () => _signInWithGoogle(context),
              child: Container(
                width: 60,
                height: 60,
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
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
                'Start with Google',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 55),
            const Text(
                'By Team Gromits.',
                style: TextStyle(fontSize: 24)),
            const Text(
                'GDG on campus: Chonnam National Univ.',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}