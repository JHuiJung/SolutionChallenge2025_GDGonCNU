// lib/widgets/overlapping_avatars.dart
import 'package:flutter/material.dart';

class OverlappingAvatars extends StatelessWidget {
  final List<String> imageUrls;
  final double avatarRadius;
  final double overlap; // Overlap amount (0.0 ~ 1.0)
  final int maxAvatarsToShow;

  const OverlappingAvatars({
    super.key,
    required this.imageUrls,
    this.avatarRadius = 15.0, // Default avatar radius
    this.overlap = 0.4, // Default overlap amount (40%)
    this.maxAvatarsToShow = 4, // Maximum number of avatars to show
  });

  @override
  Widget build(BuildContext context) {
    List<String> urlsToShow = imageUrls.take(maxAvatarsToShow).toList();
    double itemWidth = avatarRadius * 2 * (1 - overlap); // Width each item occupies

    return SizedBox(
      // Set the height of the entire widget to be the same as the avatar diameter
      height: avatarRadius * 2,
      // Calculate the width of the entire widget
      width: itemWidth * (urlsToShow.length -1) + (avatarRadius * 2),
      child: Stack(
        children: List.generate(urlsToShow.length, (index) {
          return Positioned(
            // Calculate position from the left to create overlapping effect
            left: itemWidth * index,
            // Center vertically within the Stack
            top: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.grey.shade300, // Background before image loads
              // Add a border to make overlapping parts clearer (optional)
              child: CircleAvatar(
                radius: avatarRadius - 1, // Subtract border thickness
                backgroundImage: NetworkImage(urlsToShow[index]),
                onBackgroundImageError: (exception, stackTrace) {
                  // Display default icon on image load failure (optional)
                  // print('Error loading avatar: $exception');
                },
                child: Builder( // child may be needed for error handling
                    builder: (context) {
                      // This child is not visible when NetworkImage is loaded
                      // On error, can display an icon here
                      // Example: Icon(Icons.person, size: avatarRadius);
                      return const SizedBox.shrink();
                    }
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}