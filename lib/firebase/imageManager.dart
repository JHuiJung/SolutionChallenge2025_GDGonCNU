import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestoreManager.dart' as firestoreManager;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';

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
Future<void> saveImageUrlToFirestore(String userEmail, String imageUrl) async {

  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: userEmail)
      .limit(1)
      .get();

  if (querySnapshot.docs.isEmpty) {
    print('(이미지 매니저 저장 함수) 해당 이메일을 가진 유저 문서를 찾을 수 없습니다.');
    return;
  }

  final docId = querySnapshot.docs.first.id;

  await FirebaseFirestore.instance.collection('users').doc(docId).update({
    'profileURL': imageUrl,
  });
}

//이미지 업로드
Future<bool> handleImageUpload(String userEmail) async {

  if(userEmail == 'none')
    {
      print('(이미지 업로드 함수) 이메일 없음');
      return false;
    }

  bool isImageChange =false;

  if (kIsWeb) {
    isImageChange = await ImagePickerForWeb(userEmail);
  } else {
    if (Platform.isAndroid) {
      isImageChange = await ImagePickerForMobile(userEmail);

    } else if (Platform.isIOS) {
      isImageChange = await ImagePickerForMobile(userEmail);
    }
  }

  return isImageChange;
}

Future<bool> ImagePickerForMobile(String userEmail) async {

  final imageFile = await pickImage();
  if (imageFile != null) {
    final imageUrl = await uploadProfileImage(imageFile, userEmail);
    if (imageUrl != null) {
      await saveImageUrlToFirestore(userEmail, imageUrl);
      firestoreManager.UserState().profileURL = imageUrl;
      print("이미지 업로드 및 저장 완료: $imageUrl");

      return true;
    }
  }

  return false;
}

Future<bool> ImagePickerForWeb(String userEmail) async {

  final user = FirebaseAuth.instance.currentUser;
  print( " (웹 이미지 로드 함수 ) $user?.email");

  try {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      print("웹 이미지 함수 : 이미지 선택 됨");

      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userEmail.jpg');
      final uploadTask = await storageRef.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));

      print("웹 이미지 함수 : 1 $uploadTask");

      final imageUrl = await storageRef.getDownloadURL();
      await saveImageUrlToFirestore(userEmail, imageUrl);
      print('다운로드 URL: $imageUrl'); // 여기에 appspot.com 이 포함되어야 함
      print("웹 이미지 함수 : 2 $imageUrl");

      firestoreManager.UserState().profileURL = imageUrl;

      print("✅ 웹에서 이미지 업로드 및 저장 완료: $imageUrl");
      return true;
    } else {
      print("사용자가 이미지를 선택하지 않음");
      return false;
    }
  } catch (e) {
    print("❌ 웹에서 이미지 업로드 오류: $e");
    return false;
  }
}


Future<String?> getProfileImageUrl(String userEmail) async {
  try {
    final ref = FirebaseStorage.instance.ref().child('profile_images/$userEmail.jpg');
    final imageUrl = await ref.getDownloadURL();
    return imageUrl;
  } catch (e) {
    print('이미지 불러오기 오류: $e');
    return null;
  }
}
