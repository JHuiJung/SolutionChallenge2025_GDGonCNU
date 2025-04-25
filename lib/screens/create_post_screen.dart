import 'package:flutter/material.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meet-Up Post'),
      ),
      body: const Center(
        child: Text('Meet-Up Post Creation Form Goes Here'),
      ),
    );
  }
}