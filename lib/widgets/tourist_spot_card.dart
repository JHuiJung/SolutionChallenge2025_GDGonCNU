// lib/widgets/tourist_spot_card.dart
import 'package:flutter/material.dart';
import '../models/tourist_spot_model.dart';

class TouristSpotCard extends StatelessWidget {
  final TouristSpotModel spot;

  const TouristSpotCard({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: MediaQuery.of(context).size.width * 0.65, // Adjust card width
      height: 200, // Adjust card height (match SizedBox height inside panel)
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        // When using Container instead of Card, shadow can be added directly
        // boxShadow: [ BoxShadow(...) ],
      ),
      clipBehavior: Clip.antiAlias, // To prevent content from overflowing borders
      child: InkWell( // Make card clickable
        onTap: () {
          Navigator.pushNamed(context, '/spot_detail', arguments: spot.id);
          print('Navigate to spot detail: ${spot.id}');
          // print('Tapped on spot: ${spot.name}');
        },
        child: Stack(
          fit: StackFit.expand, // Stack expands to match Container size
          children: [
            // Background image
            Image.network(
              spot.imageUrl,
              fit: BoxFit.cover,
              // Loading/Error handling
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              errorBuilder: (context, error, stack) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            // Dark Gradient overlay (improve text readability)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            // Text and icon info (bottom aligned)
            Positioned(
              bottom: 12.0,
              left: 12.0,
              right: 12.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location info (icon + text)
                  // Row(
                  //   children: [
                  //     const Icon(Icons.location_on, color: Colors.white, size: 16),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       spot.location,
                  //       style: textTheme.bodySmall?.copyWith(color: Colors.white),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 4),
                  // Tourist spot name
                  Text(
                    spot.name,
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Bottom right arrow button
            Positioned(
              bottom: 12.0,
              right: 12.0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),

            // Photographer tag (design reference - pink) (Additional feature)
            // Positioned(
            //   top: 12.0,
            //   right: 12.0,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            //     decoration: BoxDecoration(
            //       color: Colors.pinkAccent.withOpacity(0.8),
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //     child: Text(
            //       spot.photographerName,
            //       style: textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),

            // TODO: Need to implement pink arrow pointer, purple icon, etc. (Consider using CustomPaint)

          ],
        ),
      ),
    );
  }
}