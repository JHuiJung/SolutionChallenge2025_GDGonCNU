import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<File?> pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  return pickedFile != null ? File(pickedFile.path) : null;
}


// fire storage에 업로드
Future<String?> uploadProfileImage(File imageFile, String userId) async {
  try {
    final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
    final uploadTask = await storageRef.putFile(imageFile);
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('업로드 오류: $e');
    return null;
  }
}


// 파이어 스토어에 저장
Future<void> saveImageUrlToFirestore(String userId, String imageUrl) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'profileImageUrl': imageUrl,
  });
}