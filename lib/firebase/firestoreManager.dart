import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'imageManager.dart';
import '../models/meetup_post.dart';
import '../models/spot_detail_model.dart';
import '../models/chat_list_item_model.dart';
import '../models/chat_message_model.dart';

late UserState mainUserInfo;

void SetUpFireManager()
{
mainUserInfo = UserState();
}

class UserState {
// Basic Information
String? email;
String? name;
String? region;
String? gender;
int? birthYear;

// Additional Profile Information
List<UserLanguageInfo> languages;
List<String> visitedCountries;
String profileURL;
String statusMessage;
String wantsToDo;
String iLike;
List<String> postIds;
List<String> comments;
List<String> friendsEmail;
String travelGoal;
List<String> chatIds = [];

// Preference Survey
List<String> preferTravlePurpose;
List<String> preferDestination;
List<String> preferPeople;
List<String> preferPlanningStyle;

// Default Constructor
UserState()
    : email = "",
name = "",
region = "",
gender = "",
birthYear = 0,
languages = [],
visitedCountries = [],
profileURL = "",
statusMessage = "",
wantsToDo = "",
iLike = "",
postIds = [],
comments = [],
friendsEmail = [],
travelGoal = "",
preferTravlePurpose = [],
preferDestination = [],
preferPeople = [],
preferPlanningStyle = [],
chatIds = [];
}

class UserChat{
String chatId = "";
String adminEmail = "";
String otherUserEmail = "";
String LastChatTime = "";
List<(DateTime, String)> chatMessages = [];
}

class UserMeetUpPost{

List<String> meetUpPostCategory = [];
String meetUpPostLocation = "";
String meetUpPostDate = "";

String meetUpPostId = "";
String meetUpPostTitle = "";
String meetUpPostContent = "";
String meetUpPostPhoto = "";
String meetUpRegion = "";
num totalCnt = 10;
num currentCnt = 1;

}

class UserRecommandPost{
String recommandPostId = "";
String recommandPostTitle = "";
String recommandPostSubHead = "";
String recommandPostContent = "";
String recommandPostPhoto = "";
String recommandPostLocation = "";

String adminEmail = "";

}

class Comment{
String commentId = "";
String userEmail = "";
String userName = "";
String userPhoto = "";
String commentContent = "";

}

// Language Information
class UserLanguageInfo {
final String languageCode;   // e.g., 'ko'
final String languageName;   // e.g., 'Korean'
final int proficiency;       // e.g., 1~5

UserLanguageInfo({
required this.languageCode,
required this.languageName,
required this.proficiency,
});

factory UserLanguageInfo.fromMap(Map<String, dynamic> map) {
return UserLanguageInfo(
languageCode: map['languageCode'] ?? '',
languageName: map['languageName'] ?? '',
proficiency: map['proficiency'] ?? 1,
);
}

Map<String, dynamic> toMap() {
return {
'languageCode': languageCode,
'languageName': languageName,
'proficiency': proficiency,
};
}
}


void addUser() {
final user = mainUserInfo;

FirebaseFirestore.instance.collection('users').add({
'email': user.email,
'name': user.name,
'region': user.region,
'gender': user.gender,
'birthYear': user.birthYear,

// Convert language list to Map list
'languages': user.languages
    .map((lang) => {
'languageName': lang.languageName,
'languageCode': lang.languageCode,
'proficiency': lang.proficiency,
}).toList(),

'visitedCountries': user.visitedCountries,
'profileURL': user.profileURL,
'statusMessage': user.statusMessage,
'wantsToDo': user.wantsToDo,
'iLike': user.iLike,
'postIds': user.postIds,
'comments': user.comments,
'friendsEmail': user.friendsEmail,
'travelGoal': user.travelGoal,
'chatIds': user.chatIds,

'timestamp': FieldValue.serverTimestamp(),

'preferTravlePurpose': user.preferTravlePurpose,
'preferDestination': user.preferDestination,
'preferPeople': user.preferPeople,
'preferPlanningStyle': user.preferPlanningStyle,
}).then((DocumentReference doc) {
print('✅ Document added with ID: ${doc.id}');
}).catchError((error) {
print('❌ Error adding user: $error');
});
}

void updateUser() async {
final user = mainUserInfo;

try {
// Search document by email
final querySnapshot = await FirebaseFirestore.instance
    .collection('users')
    .where('email', isEqualTo: user.email)
    .limit(1)
    .get();

if (querySnapshot.docs.isEmpty) {
print('Cannot find user document with that email.');
return;
}

final docId = querySnapshot.docs.first.id;

// Update
await FirebaseFirestore.instance.collection('users').doc(docId).update({
'name': user.name,
'region': user.region,
'gender': user.gender,
'birthYear': user.birthYear,
'languages': user.languages.map((lang) => {
'languageName': lang.languageName,
'languageCode': lang.languageCode,
'proficiency': lang.proficiency,
}).toList(),
'visitedCountries': user.visitedCountries,
'profileURL': user.profileURL,
'statusMessage': user.statusMessage,
'wantsToDo': user.wantsToDo,
'iLike': user.iLike,
'postIds': user.postIds,
'comments': user.comments,
'friendsEmail': user.friendsEmail,
'travelGoal': user.travelGoal,
'chatIds': user.chatIds,
'preferTravlePurpose': user.preferTravlePurpose,
'preferDestination': user.preferDestination,
'preferPeople': user.preferPeople,
'preferPlanningStyle': user.preferPlanningStyle,
'timestamp': FieldValue.serverTimestamp(),
});

print('✅ User information update complete: $docId');
} catch (e) {
print('❌ Error occurred during user update: $e');
}
}

Future<bool> getUserInfoByEmail(String email) async {
try {
final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .where('email', isEqualTo: email)
    .limit(1)
    .get();

if (snapshot.docs.isEmpty) {
print("(firestoreManager) No user with that email.");
return false;
}

final data = snapshot.docs.first.data();
final user = mainUserInfo;

user.email = data['email'] ?? '';
user.name = data['name'] ?? '';
user.region = data['region'] ?? '';
user.gender = data['gender'] ?? '';
user.birthYear = data['birthYear'] ?? 0;

// Deserialize language list
final languagesData = List<Map<String, dynamic>>.from(data['languages'] ?? []);
user.languages = languagesData
    .map((langMap) => UserLanguageInfo.fromMap(langMap))
    .toList();

user.visitedCountries = List<String>.from(data['visitedCountries'] ?? []);
user.profileURL = data['profileURL'] ?? '';
user.statusMessage = data['statusMessage'] ?? '';
user.wantsToDo = data['wantsToDo'] ?? '';
user.iLike = data['iLike'] ?? '';
user.postIds = List<String>.from(data['postIds'] ?? []);
user.comments = List<String>.from(data['comments'] ?? []);
user.friendsEmail = List<String>.from(data['friendsEmail'] ?? []);
user.chatIds = List<String>.from(data['chatIds'] ?? []);
user.travelGoal = data['travelGoal'] ?? '';

user.preferTravlePurpose = List<String>.from(data['preferTravlePurpose'] ?? []);
user.preferDestination = List<String>.from(data['preferDestination'] ?? []);
user.preferPeople = List<String>.from(data['preferPeople'] ?? []);
user.preferPlanningStyle = List<String>.from(data['preferPlanningStyle'] ?? []);

print("User info loaded successfully: ${user.name}");
return true;
} catch (e) {
print("Error fetching user info: $e");
return false;
}
}

Future<UserState?> getAnotherUserInfoByEmail(String email) async {


try {
final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .where('email', isEqualTo: email)
    .limit(1)
    .get();

if (snapshot.docs.isEmpty) {
print("(firestoreManager) No user with that email.");
return null;
}

final data = snapshot.docs.first.data();
UserState user = UserState();

user.email = data['email'] ?? '';
user.name = data['name'] ?? '';
user.region = data['region'] ?? '';
user.gender = data['gender'] ?? '';
user.birthYear = data['birthYear'] ?? 0;

// Deserialize language list
final languagesData = List<Map<String, dynamic>>.from(
data['languages'] ?? []);
user.languages = languagesData
    .map((langMap) => UserLanguageInfo.fromMap(langMap))
    .toList();

user.visitedCountries = List<String>.from(data['visitedCountries'] ?? []);
user.profileURL = data['profileURL'] ?? '';
user.statusMessage = data['statusMessage'] ?? '';
user.wantsToDo = data['wantsToDo'] ?? '';
user.iLike = data['iLike'] ?? '';
user.postIds = List<String>.from(data['postIds'] ?? []);
user.comments = List<String>.from(data['comments'] ?? []);
user.friendsEmail = List<String>.from(data['friendsEmail'] ?? []);
user.chatIds = List<String>.from(data['chatIds'] ?? []);
user.travelGoal = data['travelGoal'] ?? '';

user.preferTravlePurpose =
List<String>.from(data['preferTravlePurpose'] ?? []);
user.preferDestination = List<String>.from(data['preferDestination'] ?? []);
user.preferPeople = List<String>.from(data['preferPeople'] ?? []);
user.preferPlanningStyle =
List<String>.from(data['preferPlanningStyle'] ?? []);

print("User info loaded successfully: ${user.name}");
return user;
} catch (e) {
print("Error fetching user info: $e");
return null;
}
}

Future<void> addMeetUpPost(MeetupPost post) async {
try {
await FirebaseFirestore.instance.collection('meetupPosts').doc(post.id).set({
'id': post.id,
'authorId': post.authorId,
'authorName': post.authorName,
'authorImageUrl': post.authorImageUrl,
'authorLocation': post.authorLocation,
'imageUrl': post.imageUrl,
'title': post.title,
'totalPeople': post.totalPeople,
'spotsLeft': post.spotsLeft,
'participantImageUrls': post.participantImageUrls,
'categories': post.categories,
'description': post.description,
'eventLocation': post.eventLocation,
'eventDateTimeString': post.eventDateTimeString,
'meetupChatid': post.meetupChatid,
'createdAt': FieldValue.serverTimestamp(), // Record upload time (optional)
});

print('Meetup post successfully uploaded.');
} catch (e) {
print('Error uploading meetup post: $e');
}
}

Future<List<MeetupPost>> getAllMeetUpPost() async {
List<MeetupPost> meetups = [];

try {
QuerySnapshot snapshot = await FirebaseFirestore.instance
    .collection('meetupPosts')
    .orderBy('createdAt', descending: true) // Sort by latest (optional)
    .get();

for (var doc in snapshot.docs) {
final data = doc.data() as Map<String, dynamic>;

MeetupPost post = MeetupPost(
id: data['id'],
authorId: data['authorId'],
authorName: data['authorName'],
authorImageUrl: data['authorImageUrl'],
authorLocation: data['authorLocation'],
imageUrl: data['imageUrl'],
title: data['title'],
totalPeople: data['totalPeople'],
spotsLeft: data['spotsLeft'],
participantImageUrls: List<String>.from(data['participantImageUrls'] ?? []),
categories: List<String>.from(data['categories'] ?? []),
description: data['description'],
eventLocation: data['eventLocation'],
eventDateTimeString: data['eventDateTimeString'],
meetupChatid : data['meetupChatid'],
);

meetups.add(post);
}

print('Fetched ${meetups.length} meetup posts.');
} catch (e) {
print('Error fetching meetup posts: $e');
}

return meetups;
}

Future<MeetupPost?> getMeetUpPostById(String postId) async {
try {
DocumentSnapshot doc = await FirebaseFirestore.instance
    .collection('meetupPosts')
    .doc(postId)
    .get();

if (doc.exists) {
final data = doc.data() as Map<String, dynamic>;

return MeetupPost(
id: data['id'],
authorId: data['authorId'],
authorName: data['authorName'],
authorImageUrl: data['authorImageUrl'],
authorLocation: data['authorLocation'],
imageUrl: data['imageUrl'],
title: data['title'],
totalPeople: data['totalPeople'],
spotsLeft: data['spotsLeft'],
participantImageUrls: List<String>.from(data['participantImageUrls'] ?? []),
categories: List<String>.from(data['categories'] ?? []),
description: data['description'],
eventLocation: data['eventLocation'],
eventDateTimeString: data['eventDateTimeString'],
meetupChatid: data['meetupChatid'],
);
} else {
print('No meetup post found with ID $postId');
return null;
}
} catch (e) {
print('Error fetching meetup post by ID: $e');
return null;
}
}

Future<void> addSpotPost(SpotDetailModel post) async {
try {
await FirebaseFirestore.instance.collection('spotPosts').doc(post.id).set({
'id': post.id,
'name': post.name,
'location': post.location,
'imageUrl': post.imageUrl,
'quote': post.quote,
'authorId': post.authorId,
'authorName': post.authorName,
'authorImageUrl': post.authorImageUrl,
'description': post.description,
'recommendTo': post.recommendTo,
'canEnjoy': post.canEnjoy,
'commentIds': post.commentIds,
'createdAt': FieldValue.serverTimestamp(), // Record upload time (optional)
});

print('Spot post successfully uploaded.');
} catch (e) {
print('Error uploading spot post: $e');
}
}

Future<List<SpotDetailModel>> getAllSpotPost() async {
List<SpotDetailModel> spotPosts = [];

try {
QuerySnapshot snapshot = await FirebaseFirestore.instance
    .collection('spotPosts')
    .orderBy('createdAt', descending: true)
    .get();

for (var doc in snapshot.docs) {
final data = doc.data() as Map<String, dynamic>;

SpotDetailModel post = SpotDetailModel(
id: data['id'],
name: data['name'],
location: data['location'],
imageUrl: data['imageUrl'],
quote: data['quote'],
authorId: data['authorId'],
authorName: data['authorName'],
authorImageUrl: data['authorImageUrl'],
description: data['description'],
recommendTo: data['recommendTo'],
canEnjoy: data['canEnjoy'],
commentIds: List<String>.from(data['commentIds'] ?? []),
);

spotPosts.add(post);
}

print('Fetched ${spotPosts.length} spot posts.');
} catch (e) {
print('Error fetching spot posts: $e');
}

return spotPosts;
}

Future<SpotDetailModel?> getSpotPostById(String spotId) async {
try {
DocumentSnapshot doc = await FirebaseFirestore.instance
    .collection('spotPosts')
    .doc(spotId)
    .get();

if (doc.exists) {
final data = doc.data() as Map<String, dynamic>;

return SpotDetailModel(
id: spotId,
name: data['name'] ?? '',
location: data['location'] ?? '',
imageUrl: data['imageUrl'] ?? '',
quote: data['quote'] ?? '',
authorId: data['authorId'] ?? '',
authorName: data['authorName'] ?? '',
authorImageUrl: data['authorImageUrl'] ?? '',
description: data['description'] ?? '',
recommendTo: data['recommendTo'] ?? '',
canEnjoy: data['canEnjoy'] ?? '',
commentIds: List<String>.from(data['commentIds'] ?? []),
// Uncomment if needed
// comments: List<SpotCommentModel>.from(...),
);
} else {
print('No Spot post found with ID $spotId');
return null;
}
} catch (e) {
print('Error fetching meetup post by ID: $e');
return null;
}
}

Future<void> addChat(ChatListItemModel chat) async {
try {
await FirebaseFirestore.instance.collection('chats').doc(chat.chatId).set({
'chatId': chat.chatId,
'userId': chat.userId,
'name': chat.name,
'imageUrl': chat.imageUrl,
'lastMessage': chat.lastMessage,
'timestamp': {
'hour': chat.timestamp.hour,
'minute': chat.timestamp.minute,
},
'isRead': chat.isRead,
'memberIds': chat.memberIds,
'createdAt': FieldValue.serverTimestamp(),
});

print('Chat successfully uploaded.');
} catch (e) {
print('Error uploading chat: $e');
}
}

Future<void> updateChat(ChatListItemModel chat) async {
try {
await FirebaseFirestore.instance.collection('chats').doc(chat.chatId).update({
'userId': chat.userId,
'name': chat.name,
'imageUrl': chat.imageUrl,
'lastMessage': chat.lastMessage,
'timestamp': {
'hour': chat.timestamp.hour,
'minute': chat.timestamp.minute,
},
'isRead': chat.isRead,
// Add if needed
// 'updatedAt': FieldValue.serverTimestamp(),
});

print('Chat successfully updated.');
} catch (e) {
print('Error updating chat: $e');
}
}

Future<ChatListItemModel?> getChat(String chatId) async {
try {
final doc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

if (!doc.exists) {
print('Chat not found.');
return null;
}

final data = doc.data()!;

final timestampMap = data['timestamp'] as Map<String, dynamic>?;

return ChatListItemModel(
chatId: data['chatId'] as String,
userId: data['userId'] as String,
name: data['name'] as String,
imageUrl: data['imageUrl'] as String?, // Allow null
lastMessage: data['lastMessage'] as String,
timestamp: timestampMap != null
? TimeOfDay(
hour: timestampMap['hour'] as int,
minute: timestampMap['minute'] as int,
)
    : TimeOfDay(hour: 0, minute: 0), // Handle default value
isRead: data['isRead'] as bool? ?? true,
memberIds: List<String>.from(data['memberIds'] ?? []),
);
} catch (e) {
print('Error getting chat: $e');
return null;
}
}


Future<void> addMessage(String chatId, ChatMessageModel message) async {
try {
await FirebaseFirestore.instance
    .collection('chatMessages')
    .doc(chatId)
    .collection('messages')
    .doc(message.id) // Add document by message ID
    .set(message.toMap());
} catch (e) {
print('Error adding message: $e');
}
}


Future<List<ChatMessageModel>> getMessages(String chatId) async {
try {
final snapshot = await FirebaseFirestore.instance
    .collection('chatMessages')
    .doc(chatId)
    .collection('messages')
    .orderBy('timestamp') // Sort by time
    .get();

return snapshot.docs
    .map((doc) => ChatMessageModel.fromMap(doc.data()))
    .toList();
} catch (e) {
print('Error getting messages: $e');
return [];
}
}

Future <String?> getOriginUserId(String userEmail) async {
final querySnapshot = await FirebaseFirestore.instance
    .collection('users')
    .where('email', isEqualTo: userEmail)
    .limit(1)
    .get();

if (querySnapshot.docs.isEmpty) {
print('Cannot find user document with that email.');
return null;
}

final docId = querySnapshot.docs.first.id;

return docId;
}