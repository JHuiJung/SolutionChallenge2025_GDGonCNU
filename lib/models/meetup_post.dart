// lib/models/meetup_post.dart
import 'package:flutter/material.dart'; // Added for LatLng usage
import 'package:google_maps_flutter/google_maps_flutter.dart'; // When integrating with actual map

class MeetupPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorImageUrl;
  final String authorLocation; // Added author's location
  final String imageUrl; // Main image for the post
  final String title;
  final int totalPeople;
  final int spotsLeft;
  final List<String> participantImageUrls; // List of participant image URLs
  final List<String> categories; // e.g.: ['Sightseeing', 'Culture']
  final String description;
  final String eventLocation; // e.g.: "Seoul, Korea" (Meeting location)
  // final LatLng eventCoordinates; // Meeting location coordinates when integrating with actual map
  final String eventDateTimeString; // e.g.: "25th, April, 15:00~18:00"
  final String meetupChatid; // e.g.: "25th, April, 15:00~18:00"

  MeetupPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorImageUrl,
    required this.authorLocation, // Added
    required this.imageUrl,
    required this.title,
    required this.totalPeople,
    required this.spotsLeft,
    required this.participantImageUrls,
    required this.categories,
    required this.description,
    required this.eventLocation,
    // this.eventCoordinates,
    required this.eventDateTimeString,
    required this.meetupChatid,
  });
}

// --- Temporary Dummy Data Creation Function Modified ---
List<MeetupPost> getDummyMeetupPosts() {
  return List.generate(5, (index) {
    List<String> participants = List.generate(
      (index % 4) + 3,
          (pIndex) => 'https://i.pravatar.cc/150?img=${index * 10 + pIndex + 1}',
    );
    int spots = (index % 3) + 1;
    int total = participants.length + spots;

    return MeetupPost(
      id: 'post_$index',
      authorId: 'user_${index % 3}',
      authorName: ['Amy', 'Brian', 'Charlie'][index % 3], // Added Amy
      authorImageUrl: 'https://source.unsplash.com/random/100x100/?person&sig=${50 + index % 3}', // Author image changed
      authorLocation: ['Seoul, Korea', 'Busan, Korea', 'New York, USA'][index % 3], // Added author location
      imageUrl: 'https://source.unsplash.com/random/800x600/?food,picnic,nature&sig=$index', // Image subject changed
      title: ['Let\' have a picnic near mountain Fuji', 'Explore Gangnam Food Scene', 'Han River Sunset Walk', 'Visit Gyeongbok Palace Together', 'Hiking at Bukhansan'][index % 5], // Title changed
      totalPeople: total,
      spotsLeft: spots,
      participantImageUrls: participants,
      // --- Added Detailed Information ---
      categories: index % 2 == 0 ? ['Sightseeing', 'Culture'] : ['Food', 'Activity'], // Category example
      description: "If you're looking to explore a peaceful and culturally rich spot off the typical tourist trail, I highly recommend visiting Yongbongsa Temple. As a local, I've been there many times, and each visit offers something new — a sense of calm, history, and beauty that's hard to find elsewhere. Let's enjoy the spring together!", // Description example
      eventLocation: ['Near Mt. Fuji Station', 'Gangnam Station Exit 10', 'Yeouinaru Station Exit 2', 'Gyeongbok Palace Entrance', 'Bukhansan National Park Entrance'][index % 5], // Meeting location example
      // eventCoordinates: LatLng(...), // Actual coordinates
      eventDateTimeString: '25th, April, 15:00~18:00', // Date/Time example
      meetupChatid: 'none',
    );
  });
}

// Function to get dummy data for a specific ID (for detail screen)
MeetupPost getDummyPostDetail(String postId) {
  // In a real app, you would call an API or query the DB with postId
  // Here, it finds the ID in the dummy list or returns the first item if not found (example)
  return getDummyMeetupPosts().firstWhere((post) => post.id == postId, orElse: () => getDummyMeetupPosts().first);
}