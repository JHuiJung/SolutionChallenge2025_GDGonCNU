// lib/models/spot_detail_model.dart
import 'spot_comment_model.dart'; // Import comment model

class SpotDetailModel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String quote; // e.g.: "You must go here in Spring."
  final String authorId;
  final String authorName;
  final String authorImageUrl;
  final String description;
  final String recommendTo; // e.g.: "People who like nature"
  final String canEnjoy; // e.g.: "The beauty of Korea"
  final List<String> commentIds;
  //final List<SpotCommentModel> comments;

  SpotDetailModel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.quote,
    required this.authorId,
    required this.authorName,
    required this.authorImageUrl,
    required this.description,
    required this.recommendTo,
    required this.canEnjoy,
    required this.commentIds,
    //required this.comments,
  });
}

// --- Temporary Dummy Data Creation Function ---
SpotDetailModel getDummySpotDetail(String spotId) {
  // Can implement to return different data based on spotId
  return SpotDetailModel(
    id: spotId,
    name: 'Sensoji Temple', // Example name
    location: 'Seoul, Korea',
    imageUrl: 'https://source.unsplash.com/random/800x1200/?temple,spring,korea&sig=${spotId.hashCode}', // Unique image
    quote: '"You must go here in Spring."',
    authorId: 'user_amy', // Post author ID
    authorName: 'Amy',
    authorImageUrl: 'https://source.unsplash.com/random/100x100/?person,woman&sig=1', // Post author image
    description: "If you're looking to explore a peaceful and culturally rich spot off the typical tourist trail, I highly recommend visiting Yongbongsa Temple. As a local, I've been there many times, and each visit offers something new — a sense of calm, history, and beauty that's hard to find elsewhere.",
    recommendTo: 'People who like nature and quiet places',
    canEnjoy: 'The beauty of Korean traditional architecture and spring blossoms',
    commentIds: [],
    //comments: getDummySpotComments(), // Dummy comment data
  );
}