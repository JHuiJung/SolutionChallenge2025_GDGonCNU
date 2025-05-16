import 'package:naviya/screens/write/write_meetup_screen.dart';
import 'package:naviya/screens/write/write_spot_screen.dart';

import 'theme/app_theme.dart'; // Import theme file
import 'dart:ui'; // Add import

import 'package:flutter/material.dart';
import 'package:naviya/screens/spot_detail_screen.dart';
import 'package:naviya/screens/write/write_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebase/firebase_test_screen.dart';
import 'firebase/firestoreManager.dart' as firestoreManager;

// import 'screens/create_post_screen.dart'; (Deleted)
import 'screens/splash_screen.dart'; // *** Import Splash Screen ***
import 'screens/preference_selection_screen.dart';
import 'screens/profile_registration_screen.dart';
import 'screens/main_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/post_detail_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/chat/chat_room_screen.dart';
import 'screens/search_screen.dart'; // Import Search Screen
import 'screens/spot_detail_screen.dart'; // Import Tourist Spot Detail Screen
import 'screens/write/write_user_comment_screen.dart';
import 'screens/write/write_spot_comment_screen.dart';
import 'screens/edit_mypage_screen.dart'; // Import Profile Edit Screen
import 'screens/write/write_meetup_screen.dart'; // Import Meetup Post Write Screen
import 'screens/write/write_spot_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // For testing, delete after use
  firestoreManager.SetUpFireManager();
  //firestoreManager.getUserInfoByEmail("test1@dummy.com");
  //await testNetworkConnectivity();
  //await createDummyAccounts();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hatch',
      theme: AppTheme.lightTheme, // Apply light theme
      darkTheme: AppTheme.darkTheme, // Apply dark theme
      // themeMode: ThemeMode.system, // Auto switch theme based on system settings
      themeMode: ThemeMode.light, // Always light mode
      debugShowCheckedModeBanner: false, // Hide debug banner
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),

      // Set the first screen when the app starts
      initialRoute: '/splash',
      //initialRoute: '/profile',

      // Define navigation routes
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const FirebaseTestScreen(),
        '/profile': (context) => const ProfileRegistrationScreen(),
        '/preference': (context) => const PreferenceSelectionScreen(),
        '/main': (context) => const MainScreen(),
        '/mypage': (context) => const MyPageScreen(), // Add MyPage route
        '/post_detail': (context) => const PostDetailScreen(), // Add Post Detail route
        '/user_profile': (context) => const UserProfileScreen(), // Add User Profile route
        '/chat_room': (context) => const ChatRoomScreen(), // Add individual Chat Room route
        '/spot_detail': (context) => const SpotDetailScreen(),
        '/search': (context) => const SearchScreen(), // Add Search Screen route
        '/write_user_comment': (context) => const WriteUserCommentScreen(), // Add User Comment Write route
        '/write_spot_comment': (context) => const WriteSpotCommentScreen(), // Add Tourist Spot Comment Write route
        '/edit_mypage': (context) => const EditMyPageScreen(), // Add Profile Edit route
        '/write_meetup': (context) => const WriteMeetupScreen(),
        '/write_spot': (context) => const WriteSpotScreen(), // *** Added ***
      },
    );
  }
}



Future<void> testNetworkConnectivity() async {
  try {
    // Test with a well-known external URL like Google homepage
    var response = await http.get(Uri.parse('https://www.google.com'));
    if (response.statusCode == 200) {
      print('Network test successful! Google homepage loaded.');
    } else {
      print('Network test failed! Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Network test exception: $e');
  }
}

Future<void> createDummyAccounts() async {
  final List<Map<String, String>> dummyUsers = [
    {'email': 'test6@dummy.com', 'password': 'password123'},
    {'email': 'test7@dummy.com', 'password': 'password123'},
    {'email': 'test8@dummy.com', 'password': 'password123'},
    {'email': 'test9@dummy.com', 'password': 'password123'},
    {'email': 'test10@dummy.com', 'password': 'password123'},
    {'email': 'test11@dummy.com', 'password': 'password123'},
  ];

  for (var user in dummyUsers) {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user['email']!,
        password: user['password']!,
      );
      print('✅ Created: ${user['email']}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('⚠️ Already exists: ${user['email']}');
      } else {
        print('❌ Error for ${user['email']}: ${e.message}');
      }
    }
  }
}
// Add a button or event listener to call this function
// ElevatedButton(
//   onPressed: testNetworkConnectivity,
//   child: Text('Test Network'),
// )