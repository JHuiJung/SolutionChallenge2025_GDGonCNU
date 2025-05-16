// lib/screens/post_detail_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/meetup_post.dart'; // Import MeetupPost model (check path)
import '../widgets/overlapping_avatars.dart'; // Import participant avatar widget (check path)
import 'dart:async'; // Added for Timer usage
import 'dart:ui'; // Added for ImageFilter usage (for bottom button blur effect)
import '../firebase/firestoreManager.dart';
import '../models/comment_model.dart';
import '../widgets/comment_item.dart';
import '../services/api_service.dart'; // *** Import ApiService ***

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // --- Data loading status (needed in actual implementation) ---
  bool _isLoading = true;
  late MeetupPost _postDetail;
  String? _postId;
  bool _isJoined = false; // Added variable to store participation status
  bool _isProcessing = false; // Flag to check if button click is being processed
  List<CommentModel> _comments = [];
  // --- Added AI comment state variables ---
  String? _aiComment;
  bool _isLoadingAiComment = false; // AI comment loading status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _postId = ModalRoute.of(context)?.settings.arguments as String;
        print("🚑 (Post Detail) Post ID: $_postId");
        _loadPostDetailsAndAiComment(_postId!); // Call function to load AI comment
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        print("Error: Post ID not provided.");
        // Navigator.pop(context);
      }
    });
  }

  // Load post details and AI comment
  Future<void> _loadPostDetailsAndAiComment(String postIdFromRoute) async { // Parameter name change
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isLoadingAiComment = true;
    });

    // Load post details
    await Future.delayed(const Duration(milliseconds: 300));
    // Load _postDetail using postIdFromRoute
    //_postDetail = getDummyPostDetail(postIdFromRoute);
    MeetupPost _dummy = getDummyPostDetail(postIdFromRoute);
    _postDetail = await getMeetUpPostById(_postId!)??_dummy;
    _comments = getDummyComments();

    // Load AI comment
    try {
      // --- 1. Get current logged-in user ID ---
      final User? currentUser = FirebaseAuth.instance.currentUser;
      String? currentUserIdForApi;
      print("🥲111111");

      if (currentUser != null) {
        currentUserIdForApi = await getOriginUserId(mainUserInfo.email!) ?? "";
      } else {
        // Handle case where user is not logged in
        print("Error: User not logged in. Cannot fetch AI comment.");
        if (mounted) {
          setState(() {
            _aiComment = "Please log in to see AI comments.";
            _isLoadingAiComment = false;
            _isLoading = false; // Also mark overall loading as complete
          });
        }
        return; // Exit function
      }
      print("🥲22222");

      // --- 2. Use the received postIdFromRoute as eventId ---
      final String eventIdForApi = postIdFromRoute;

      // --- Check ID values before API call (for debugging) ---
      if (currentUserIdForApi.isEmpty || eventIdForApi.isEmpty) {
        print("Error: Invalid IDs for AI comment. UserID: '$currentUserIdForApi', EventID: '$eventIdForApi'");
        if(mounted) {
          setState(() {
            _aiComment = "Error: Could not fetch AI comment due to invalid IDs.";
            _isLoadingAiComment = false;
            _isLoading = false;
          });
        }
        return;
      }
      print('Fetching AI comment for eventId: $eventIdForApi, userId: $currentUserIdForApi');
      print("🥲33333");

      final fetchedAiComment = await ApiService.fetchComment(
        eventId: eventIdForApi,
        userId: currentUserIdForApi,
      );
      print("🥲44444");

      if (mounted) {
        setState(() {
          _aiComment = fetchedAiComment;
        });
      }
    } catch (e) {
      print("Error fetching AI comment: $e");
      if (mounted) {
        setState(() {
          _aiComment = "Failed to load AI comment: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAiComment = false;
          // _isLoading should be set to false only after both post details and AI comment loading are complete
          // In the current structure, _isLoading = true at the start of _loadPostDetailsAndAiComment,
          // and setting _isLoading = false in the finally block seems appropriate, assuming AI comment loading is the last task.
          if (!_isLoadingAiComment && !_isLoading) { // If there were other async tasks, consider their completion times too
            // Assuming post loading is already finished, set to false here
          }
          print("🥲55555");
          _isLoading = false; // Assuming AI comment loading is the last task, mark overall loading complete
        });
      }
    }
  }

  // Handle join button click
  Future<void> _handleJoin() async {
    if (_isProcessing || _isJoined) return; // Prevent double execution if processing or already joined

    if (mounted) {
      setState(() => _isProcessing = true); // Start processing
    }

    // TODO: Add logic to send join request to the actual server
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate server request

    // Check if the corresponding chatId is in the main user's chat info

    List<String> userChats = mainUserInfo.chatIds;
    bool isChatOn = false;


    for (String chatId in userChats) {
      if (chatId == _postDetail.meetupChatid) {
        isChatOn = true;
        break;
      }
    }

    if(!isChatOn)
    {
      mainUserInfo.chatIds.add(_postDetail.meetupChatid);
      updateUser();
    }

    // If not present, add and update info

    if (mounted) {
      // Assuming successful processing
      _showSuccessDialog(); // Show success popup
      setState(() {
        _isJoined = true; // Change to joined state
        // _isProcessing = false; // Change to false when popup closes
      });
    }
  }

  // Handle cancel button click
  Future<void> _handleCancel() async {
    if (_isProcessing || !_isJoined) return; // Prevent double execution if processing or not in joined state

    if (mounted) {
      setState(() => _isProcessing = true); // Start processing
    }

    // TODO: Add logic to send cancel participation request to the actual server
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate server request

    if (mounted) {
      // Assuming successful processing
      setState(() {
        _isJoined = false; // Change to canceled participation state
        _isProcessing = false; // Processing complete
      });
      print('Event participation cancelled.');
    }
  }


  // Show success popup function
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Disable closing by tapping background
      barrierColor: Colors.black.withValues(alpha: 0.7), // Slightly darken background
      builder: (BuildContext context) {
        // Automatically close popup after 1 second
        Timer(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop(); // Close popup
            setState(() => _isProcessing = false); // Processing complete when popup closes
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent, // Make default background transparent
          elevation: 0, // Remove shadow
          child: Column(
            mainAxisSize: MainAxisSize.min, // Take up only the size of content
            children: [
              Image.asset(
                'assets/images/egg.png', // Path to added image
                height: 200, // Adjust image size
              ),
              const SizedBox(height: 24),
              const Text(
                'Successfully Joined!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent, // Design reference color
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color surfaceVariantWithOpacity = colorScheme.surfaceVariant.withOpacity(0.7);
    final Color onSurfaceWithOpacity = colorScheme.onSurface.withOpacity(0.7);
    final Color surfaceWithOpacity = colorScheme.surface.withOpacity(0.9);
    final Color blackWithOpacityLow = Colors.black.withOpacity(0.1);
    final Color blackWithOpacityMid = Colors.black.withOpacity(0.3);
    final Color primaryWithOpacity = colorScheme.primary.withOpacity(0.5);
    final Color grey600WithOpacity = Colors.grey.shade600.withOpacity(0.5);
    // --- AI Comment Box Background Color (design reference) ---
    final Color aiCommentBoxColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade200.withOpacity(0.7) // Light mode
        : Colors.grey.shade800.withOpacity(0.7); // Dark mode

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              _buildSliverAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Categories, title, number of people etc. (existing content)...
                    _buildCategoryChips(context, colorScheme),
                    const SizedBox(height: 12), // Space between categories and title
                    Text(
                      _postDetail.title,
                      style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6), // Space between title and number of people
                    Text(
                      '${_postDetail.totalPeople} people · ${_postDetail.spotsLeft} left',
                      style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 12), // Space between number of people and user profile
                    _buildAuthorSection(context, textTheme),
                    // Horizontal divider line
                    const SizedBox(height: 6), // Space between user and info
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(thickness: 1.5, height: 1.5),
                    ),
                    const SizedBox(height: 3),
                    _buildInfoRow(context, Icons.location_on_outlined, _postDetail.eventLocation),
                    const SizedBox(height: 8), // Space between location and time
                    _buildInfoRow(context, Icons.access_time_outlined, _postDetail.eventDateTimeString),
                    const SizedBox(height: 3),
                    // Horizontal divider line
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(thickness: 1.5, height: 1.5),
                    ),
                    // Reserve space for bottom button (consider button height + padding)
                    const SizedBox(height: 10),
                    Text(
                      _postDetail.description,
                      style: textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),

                    // --- Add "Comments by AI" section ---
                    _buildAiCommentSection(context, textTheme, aiCommentBoxColor),
                    const SizedBox(height: 40), // Space before user comments section
                    // --- End of "Comments by AI" section ---

                    const SizedBox(height: 90),
                  ]),
                ),
              ),
            ],
          ),
          // Fixed bottom button (display different buttons based on state)
          _buildBottomButton(context, colorScheme, textTheme),
        ],
      ),
    );
  }

  // --- Existing builder functions (_buildSliverAppBar, _buildCategoryChips, _buildAuthorSection, _buildInfoRow) ---
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      stretch: true,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Image.network(
          _postDetail.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : Container(color: Colors.grey.shade300),
          errorBuilder: (context, error, stack) => Container(
            color: Colors.grey.shade400,
            child: const Icon(Icons.broken_image, color: Colors.white54, size: 50), // Placeholder for loading photo later
            // child: Image.asset(
            //               'assets/images/spring.jpg', // Path to added image
            //             )
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, ColorScheme colorScheme) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _postDetail.categories.map((category) => Chip(
        label: Text(category),
        labelStyle: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        backgroundColor: colorScheme.surfaceVariant.withValues(alpha: 0.7),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        side: BorderSide.none,
      )).toList(),
    );
  }

  Widget _buildAuthorSection(BuildContext context, TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/user_profile', arguments: _postDetail.authorId);
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(_postDetail.authorImageUrl),
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _postDetail.authorName,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _postDetail.authorLocation,
                    style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        if (_postDetail.participantImageUrls.isNotEmpty)
          OverlappingAvatars(
            imageUrls: _postDetail.participantImageUrls,
            avatarRadius: 18,
          ),
      ],
    );
  }


  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  // Bottom button builder (returns Join or Cancel button based on state)
  Widget _buildBottomButton(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 5,
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: _isJoined
              ? _buildCancelButton(context, colorScheme, textTheme) // If joined state, Cancel button
              : _buildJoinButton(context, colorScheme, textTheme), // Otherwise, Join button
        ),
      ),
    );
  }

  // Join button widget
  Widget _buildJoinButton(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return ElevatedButton(
        onPressed: _isProcessing ? null : _handleJoin, // Disable if processing
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          // Disabled style when processing (optional)
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
        ),
        child: _isProcessing
            ? const SizedBox( // Show loading indicator
          height: 15,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text('Join this event', style: TextStyle(fontSize: 18.0))
    );
  }

  // Cancel button widget
  Widget _buildCancelButton(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _handleCancel, // Disable if processing
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        backgroundColor: Colors.grey.shade600, // Grey background (design reference)
        foregroundColor: Colors.white, // White text
        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Slightly less rounded (design reference)
        ),
        disabledBackgroundColor: Colors.grey.shade600.withValues(alpha: 0.5),
      ),
      child: _isProcessing
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : const Text('Cancel', style: TextStyle(fontSize: 18.0)),
    );
  }


  // --- "Comments by AI" section builder ---
  Widget _buildAiCommentSection(BuildContext context, TextTheme textTheme, Color boxBackgroundColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20), // Space between main body and AI comment section
        Text(
          ' Comments by Gemini',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5), // Space between 'Comments by AI' and content area
        Container(
          width: double.infinity, // Fill width
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: boxBackgroundColor, // Design reference background color
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: _isLoadingAiComment
              ? const Center( // Show while loading
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          )
              : Text(
            _aiComment ?? 'No AI comment available.', // AI comment or default message
            style: textTheme.bodyLarge?.copyWith(
              height: 1.5, // Line spacing
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), // Slightly faded text
            ),
          ),
        ),
      ],
    );
  }
}