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
  // 기본정보
  String? email;
  String? name;
  String? region;
  String? gender;
  int? birthYear;

  // 프로필 추가 정보
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

  // 선호 조사
  List<String> preferTravlePurpose;
  List<String> preferDestination;
  List<String> preferPeople;
  List<String> preferPlanningStyle;

  // 기본 생성자
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

// 언어 정보
class UserLanguageInfo {
  final String languageCode;   // 예: 'ko'
  final String languageName;   // 예: 'Korean'
  final int proficiency;       // 예: 1~5

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

    // 언어 리스트를 Map 리스트로 변환
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
    // 이메일로 문서 검색
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print('해당 이메일을 가진 유저 문서를 찾을 수 없습니다.');
      return;
    }

    final docId = querySnapshot.docs.first.id;

    // 업데이트
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

    print('✅ 유저 정보 업데이트 완료: $docId');
  } catch (e) {
    print('❌ 유저 업데이트 중 오류 발생: $e');
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
      print("(firestoreManager) 해당 이메일의 유저가 없습니다.");
      return false;
    }

    final data = snapshot.docs.first.data();
    final user = mainUserInfo;

    user.email = data['email'] ?? '';
    user.name = data['name'] ?? '';
    user.region = data['region'] ?? '';
    user.gender = data['gender'] ?? '';
    user.birthYear = data['birthYear'] ?? 0;

    // 언어 리스트 역직렬화
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

    print("유저 정보 로드 성공: ${user.name}");
    return true;
  } catch (e) {
    print("유저 정보 가져오기 오류: $e");
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
      print("(firestoreManager) 해당 이메일의 유저가 없습니다.");
      return null;
    }

    final data = snapshot.docs.first.data();
    UserState user = UserState();

    user.email = data['email'] ?? '';
    user.name = data['name'] ?? '';
    user.region = data['region'] ?? '';
    user.gender = data['gender'] ?? '';
    user.birthYear = data['birthYear'] ?? 0;

    // 언어 리스트 역직렬화
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

    print("유저 정보 로드 성공: ${user.name}");
    return user;
  } catch (e) {
    print("유저 정보 가져오기 오류: $e");
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
      'createdAt': FieldValue.serverTimestamp(), // 업로드 시간 기록 (선택)
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
        .orderBy('createdAt', descending: true) // 최신 순 정렬 (선택)
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
      'createdAt': FieldValue.serverTimestamp(), // 업로드 시간 기록 (선택)
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
        // comments: List<SpotCommentModel>.from(...), // 필요 시 주석 해제
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
      // 'updatedAt': FieldValue.serverTimestamp(), // 필요시 추가
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
      imageUrl: data['imageUrl'] as String?, // null 허용
      lastMessage: data['lastMessage'] as String,
      timestamp: timestampMap != null
          ? TimeOfDay(
        hour: timestampMap['hour'] as int,
        minute: timestampMap['minute'] as int,
      )
          : TimeOfDay(hour: 0, minute: 0), // 기본값 처리
      isRead: data['isRead'] as bool? ?? true,
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
        .doc(message.id) // 메시지 ID로 문서 추가
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
        .orderBy('timestamp') // 시간 순으로 정렬
        .get();

    return snapshot.docs
        .map((doc) => ChatMessageModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    print('Error getting messages: $e');
    return [];
  }
}
