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


// Upload to Firebase Storage
Future<String?> uploadProfileImage(File imageFile, String userId) async {
try {
final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
final uploadTask = await storageRef.putFile(imageFile);
final downloadUrl = await storageRef.getDownloadURL();
return downloadUrl;
} catch (e) {
print('Upload error: $e');
return null;
}
}


// Save to Firestore
Future<void> saveImageUrlToFirestore(String userEmail, String imageUrl) async {

final querySnapshot = await FirebaseFirestore.instance
    .collection('users')
    .where('email', isEqualTo: userEmail)
    .limit(1)
    .get();

if (querySnapshot.docs.isEmpty) {
print('(Image Manager Save Function) Cannot find user document with that email.');
return;
}

final docId = querySnapshot.docs.first.id;

await FirebaseFirestore.instance.collection('users').doc(docId).update({
'profileURL': imageUrl,
});
}

// Image Upload
Future<bool> handleImageUpload(String userEmail) async {

if(userEmail == 'none')
{
print('(Image Upload Function) No email');
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
firestoreManager.mainUserInfo.profileURL = imageUrl;
print("Image upload and save complete: $imageUrl");

return true;
}
}

return false;
}

Future<bool> ImagePickerForWeb(String userEmail) async {

final user = FirebaseAuth.instance.currentUser;
print( " (Web Image Load Function) $user?.email");

try {
final picker = ImagePicker();
final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

if (pickedFile != null) {
final Uint8List imageBytes = await pickedFile.readAsBytes();

print("Web Image Function: Image selected");

final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userEmail.jpg');
final uploadTask = await storageRef.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));

print("Web Image Function: 1 $uploadTask");

final imageUrl = await storageRef.getDownloadURL();
await saveImageUrlToFirestore(userEmail, imageUrl);
print('Download URL: $imageUrl'); // appspot.com should be included here
print("Web Image Function: 2 $imageUrl");

firestoreManager.mainUserInfo.profileURL = imageUrl;

print("✅ Image upload and save complete from web: $imageUrl");
return true;
} else {
print("User did not select an image");
return false;
}
} catch (e) {
print("❌ Web image upload error: $e");
return false;
}
}


Future<String?> getProfileImageUrl(String userEmail) async {
try {
final ref = FirebaseStorage.instance.ref().child('profile_images/$userEmail.jpg');
final imageUrl = await ref.getDownloadURL();
return imageUrl;
} catch (e) {
print('Error loading image: $e');
return null;
}
}


Future<String?> uploadHostImage(String? hostId, firestoreManager.UserState userInfo, XFile? selectedImage) async {
try {

if(hostId == null || selectedImage == null)
{
print("😁 Host ID or image is missing (Image Manager)");
}

if (selectedImage == null) return null;

File imageFile = File(selectedImage.path);

// Specify Firebase Storage path
String filePath = 'hostImages/${userInfo.email}_$hostId.jpg';

// Upload image
final ref = FirebaseStorage.instance.ref().child(filePath);
final uploadTask = await ref.putFile(imageFile);

// Get download URL
final downloadUrl = await ref.getDownloadURL();

return downloadUrl;
} catch (e) {
print('Error occurred during image upload: $e');
return null;
}
}

Future<String?> uploadSpotImage(String? spotId, firestoreManager.UserState userInfo, XFile? selectedImage) async {
try {

if(spotId == null || selectedImage == null)
{
print("😁 Spot ID or image is missing (Image Manager)");
}

if (selectedImage == null) return null;

File imageFile = File(selectedImage.path);

// Specify Firebase Storage path
String filePath = 'spotImages/${userInfo.email}_$spotId.jpg';

// Upload image
final ref = FirebaseStorage.instance.ref().child(filePath);
final uploadTask = await ref.putFile(imageFile);

// Get download URL
final downloadUrl = await ref.getDownloadURL();

return downloadUrl;
} catch (e) {
print('Error occurred during image upload: $e');
return null;
}
}