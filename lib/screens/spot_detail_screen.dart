// lib/screens/spot_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/spot_detail_model.dart';
import '../widgets/preference_display_box.dart'; // Reuse
import '../widgets/spot_comment_card.dart';
import '../firebase/firestoreManager.dart';
import '../models/spot_comment_model.dart';

class SpotDetailScreen extends StatefulWidget {
  const SpotDetailScreen({super.key});

  @override
  State<SpotDetailScreen> createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends State<SpotDetailScreen> {
  bool _isLoading = true;
  late SpotDetailModel _spotDetail;
  String? _spotId;

  List<SpotCommentModel> spotComments = [];

  get outlineColorWithOpacity => null;

  @override
  void initState() {
    super.initState();
    // Get spotId after build and load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _spotId = ModalRoute.of(context)?.settings.arguments as String;
        _loadSpotDetails(_spotId!);
      } else {
        // Handle case where ID is missing
        setState(() => _isLoading = false);
        print("Error: Spot ID not provided.");
        // Navigator.pop(context); // Or display an error message
      }
    });



  }

  Future<void> _loadSpotDetails(String spotId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400)); // Simulate loading
    // TODO: Fetch data matching spotId from actual API or DB query
    //_spotDetail = getDummySpotDetail(spotId);
    SpotDetailModel _spotdummy = getDummySpotDetail(spotId);
    _spotDetail = await getSpotPostById(spotId) ?? _spotdummy;
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Preference box style (similar to MyPage)
    final Color prefBoxBgColor = colorScheme.brightness == Brightness.light
        ? Colors.purple.shade50.withValues(alpha: 0.7)
        : Colors.purple.shade900.withValues(alpha: 0.5);
    final Color prefBoxTitleColor = colorScheme.onSurface.withValues(alpha: 0.6);
    final Color prefBoxContentColor = colorScheme.onSurface;
    final Color prefBoxBorderColor = Colors.purple.shade300;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: <Widget>[
          // 1. Top image and info area (SliverAppBar)
          _buildSliverAppBar(context, colorScheme, textTheme),

          // 2. Main content area (SliverList)
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Tourist spot description
                Text(
                  _spotDetail.description,
                  style: textTheme.bodyLarge?.copyWith(height: 1.5), // Line spacing
                ),
                const SizedBox(height: 24),

                // Recommended to
                PreferenceDisplayBox(
                  title: 'Recommend to',
                  content: _spotDetail.recommendTo,
                  backgroundColor: prefBoxBgColor,
                  titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor,
                  borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 12),

                // Can enjoy
                PreferenceDisplayBox(
                  title: 'You can enjoy',
                  content: _spotDetail.canEnjoy,
                  backgroundColor: prefBoxBgColor,
                  titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor,
                  borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 24),

                // --- Modify Comments section title ---
                Row( // Row for title and button
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Comments',
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    // Add comment write button
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: colorScheme.onSurface.withOpacity(0.7)),
                      onPressed: () {
                        // Navigate to spot comment write screen (pass spotId)
                        Navigator.pushNamed(context, '/write_spot_comment', arguments: _spotId);
                      },
                      tooltip: 'Write a comment',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                Divider(thickness: 1, height: 20, color: outlineColorWithOpacity), // Divider
                // --- End of Comments section title modification ---
              ]),
            ),
          ),

          // 3. Comment list (horizontal scroll)
          _buildCommentsSection(context),

          // Add bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  // SliverAppBar builder
  Widget _buildSliverAppBar(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return SliverAppBar(
      expandedHeight: 350.0, // Image area height
      stretch: true, // Allow image to stretch on overscroll
      pinned: true, // Pin AppBar to the top when scrolling
      backgroundColor: colorScheme.surface, // AppBar background color when pinned
      iconTheme: const IconThemeData(color: Colors.white), // Back button color (initial)
      // Change icon color when pinned (optional)
      // surfaceTintColor: colorScheme.onSurface,

      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        // Title is not used (placed directly)
        // title: Text('Details'),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              _spotDetail.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Container(color: Colors.grey.shade300), // Grey background while loading
              errorBuilder: (context, error, stack) => Container(
                color: Colors.grey.shade400,
                child: const Icon(Icons.broken_image, color: Colors.white54, size: 50),
              ),
            ),
            // Dark Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0], // Adjust gradient range
                ),
              ),
            ),
            // Text and profile info above the image (bottom aligned)
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location
                  // Row(
                  //   children: [
                  //     const Icon(Icons.location_on, color: Colors.white, size: 16),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       _spotDetail.location,
                  //       style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 8),
                  // Place name
                  Text(
                    _spotDetail.name,
                    style: textTheme.displaySmall?.copyWith( // Larger title style
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black.withValues(alpha: 0.5))],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // One-line introduction (Quote)
                  Text(
                    _spotDetail.quote,
                    style: textTheme.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 12),
                  // Author info
                  InkWell( // Make it clickable
                    onTap: () {
                      // Navigate to author's profile screen
                      Navigator.pushNamed(context, '/user_profile', arguments: _spotDetail.authorId);
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(_spotDetail.authorImageUrl),
                          backgroundColor: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _spotDetail.authorName,
                          style: textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Comments section builder (horizontal scroll)
  Widget _buildCommentsSection(BuildContext context) {
    // Use SliverToBoxAdapter to place a horizontal ListView inside CustomScrollView
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 150, // Comment card height + padding consideration
        //child: _spotDetail.comments.isEmpty
        child: spotComments.isEmpty
            ? Center( // Message when no comments
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No comments yet.', style: TextStyle(color: Colors.grey)),
          ),
        )
            : ListView.builder(
          scrollDirection: Axis.horizontal, // Horizontal scroll
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //itemCount: _spotDetail.comments.length,
          itemCount: spotComments.length,
          itemBuilder: (context, index) {
            //return SpotCommentCard(comment: _spotDetail.comments[index]);
            return SpotCommentCard(comment: spotComments[index]);
          },
        ),
      ),
    );
  }
}