// lib/screens/edit_mypage_screen.dart
import 'package:flutter/material.dart';

class EditMyPageScreen extends StatefulWidget {
  const EditMyPageScreen({super.key});

  @override
  State<EditMyPageScreen> createState() => _EditMyPageScreenState();
}

class _EditMyPageScreenState extends State<EditMyPageScreen> {
  // TODO: Declare controllers/variables to load and edit existing profile data

  @override
  void initState() {
    super.initState();
    // TODO: Load existing profile data passed from previous screen (MyPage) or from DB
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          // Save button (functionality to be implemented later)
          TextButton(
            onPressed: () {
              // TODO: Implement logic to save modified profile information
              print('Save profile changes');
              Navigator.pop(context); // Go back to the previous screen after saving
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Profile editing form goes here.\n(Name, Status Message, Preferences, etc.)',
            textAlign: TextAlign.center,
          ),
        ),
        // TODO: Implement actual profile editing UI (TextField, Dropdown, etc.)
      ),
    );
  }
}