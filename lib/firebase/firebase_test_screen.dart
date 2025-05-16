import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
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

  // ✅ Google sign-in function
  Future<void> _signInWithGoogle(BuildContext _context) async {

    // Get login information
    final userinfo = FirebaseAuth.instance.currentUser;

    if (userinfo != null) {
      // Already signed in -> Move to main screen
      bool isRight = await firestoreManager.getUserInfoByEmail(userinfo!.email!);  // Add await

      if(isRight)
      {
        Navigator.pushReplacementNamed(_context, '/main');
        return;
      }

    }

    // Not signed in -> Move to login screen
    if (kIsWeb) {
      await signInWithGoogleForWeb(_context);
    } else {
      await signInWithGoogleForMobile(_context);
    }

    User? user = FirebaseAuth.instance.currentUser;

    // Retrieve user info from Firestore
    bool isMember = await firestoreManager.getUserInfoByEmail(user!.email!);

    print("😍 event1");

    if (isMember) {
      print("😍 event2");
      Navigator.pushReplacementNamed(_context, '/main');
    } else {
      print("😍 event3");
      Navigator.pushReplacementNamed(_context, '/profile');
    }
  }

  // Function to sign in with Google for web
  Future<void> signInWithGoogleForWeb(BuildContext context) async {
    try {
      final googleProvider = GoogleAuthProvider();
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

  // Function to sign in with Google for mobile
  Future<void> signInWithGoogleForMobile(BuildContext context) async {

    print("😍 Mobile event1");

    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    print("😍 Mobile event2");

    if (googleUser == null) {
      // User canceled sign-in
      return;
    }

    print("😍 Mobile event3");
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    print("😍 Mobile event4");
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    print("😍 Mobile event5");
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
        print("✅ Login successful: ${user.email}");
        // Handle screen transition after successful login
        bool isMember = await firestoreManager.getUserInfoByEmail(user!.email!);

        print("😍 Event1");

        if(isMember)
        {
          print("😍 Event2");
          Navigator.pushReplacementNamed(context, '/main');

        }
        else{
          print("😍 Event3");
          Navigator.pushReplacementNamed(context, '/profile');

        }
      }
    } on FirebaseAuthException catch (e) {
      print("❌ Login failed: ${e.code} - ${e.message}");
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
                'By Team Gromits',
                style: TextStyle(fontSize: 24)),
            const Text(
                'GDG on campus: Chonnam National Univ',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}