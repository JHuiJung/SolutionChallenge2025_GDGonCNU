// lib/screens/user_profile_screen.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // May be needed for async operations like Timer

// --- Model Imports (Check path) ---
import '../models/user_profile_model.dart';
import '../models/meetup_post.dart';
import '../models/comment_model.dart';

// --- Widget Imports (Check path) ---
import '../widgets/meetup_post_item.dart';
import '../widgets/comment_item.dart';
import '../widgets/language_indicator.dart';
import '../widgets/preference_display_box.dart';
import '../firebase/firestoreManager.dart';

// --- Dummy Data Functions (Replace with separate file or API calls in actual implementation) ---
// Assuming UserProfileModel has a constructor or function that accepts userId
/*UserProfileModel getDummyUserProfile(String userId) {
  // Return different dummy data based on userId (example)
  bool isJohn = userId == 'user_john'; // Example ID
  return UserProfileModel(
    userId: userId,
    name: isJohn ? 'John' : 'Another User',
    age: isJohn ? 27 : 25,
    location: isJohn ? 'Seoul, Korea' : 'Busan, Korea',
    timeZoneInfo: isJohn ? '13:37 (-7hours)' : '14:00 (+9 hours)', // Needs calculation in reality
    profileImageUrl: isJohn
        ? 'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg?size=626&ext=jpg' // John image
        : 'https://source.unsplash.com/random/200x200/?person&sig=${userId.hashCode}', // Random image for other user
    statusMessage: isJohn ? "Let's hang out!" : "Exploring the world!",
    languages: [
      UserLanguage(languageCode: 'ko', languageName: 'Korean', proficiency: isJohn ? 4 : 5),
      UserLanguage(languageCode: 'en', languageName: 'English', proficiency: isJohn ? 5 : 3),
    ],
    likes: isJohn ? 'Shopping, Movie, Coding' : 'Hiking, Photography, Reading',
    placesBeen: isJohn ? 'Japan, America, India, Germany' : 'Thailand, Vietnam, Spain',
    wantsToDo: isJohn ? 'make a happy memory with me' : 'find hidden gems',
  );
}*/

UserProfileModel getUserProfile(UserState userInfo) {
  // Return different dummy data based on userId (example)

  return UserProfileModel(
    userId: userInfo.email ?? 'noneEmail',
    name: userInfo.name ?? 'noneName',
    age: userInfo.birthYear ?? 0,
    location: userInfo.region ?? 'Seoul, Korea',
    timeZoneInfo: DateTime.now().toString().split('.').first, // Needs calculation in reality
    profileImageUrl: userInfo.profileURL, // Random image for other user
    statusMessage: userInfo.statusMessage,
    languages: userInfo.languages,
    likes: userInfo.iLike,
    placesBeen: userInfo.visitedCountries.join(', '),
    wantsToDo: userInfo.wantsToDo,
  );
}

List<MeetupPost> getDummyHostedPosts(String userId) {
  // Filter posts authored by userId (example)
  return getDummyMeetupPosts()
      .where((post) => post.authorId == userId)
      .toList();
}

List<CommentModel> getDummyCommentsAboutUser(String userId) {
  // Filter comments about userId (example - in reality, query comments where the target is userId)
  return getDummyComments()
      .where((comment) => userId == 'user_john') // Show comments only on John's profile (temporary)
      .toList();
}
// --- End of Dummy Data Functions ---


class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  late UserProfileModel _userProfile;
  late List<MeetupPost> _hostedPosts;
  late List<CommentModel> _comments;
  String? _userId;
  bool _isFollowing = false; // Whether I am currently following this user (Needs DB integration)
  bool _isProcessingFollow = false; // Flag for follow/unfollow processing

  late UserState? userInfo;

  @override
  void initState() {
    super.initState();



    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _userId = ModalRoute.of(context)?.settings.arguments as String;
        _loadUserProfileData(_userId!);

      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        print("Error: User ID not provided for profile screen.");
        // Navigator.pop(context); // Go back if no ID
      }
    });
  }

  Future<void> _loadUserProfileData(String userId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400)); // Simulate loading

    userInfo = await getAnotherUserInfoByEmail(_userId ?? '');

    // TODO: Load data based on userId from actual API or DB
    // _userProfile = getDummyUserProfile(userId);
    _userProfile = getUserProfile(userInfo ?? mainUserInfo);
    // _hostedPosts = getDummyHostedPosts(userId);
    _hostedPosts = [];

    //print("🚒 Number of available languages: ${_userProfile.languages.length}");

    List<String> userHostIds = userInfo?.postIds ?? [];

    for(int i = 0 ; i < userHostIds.length;++i)
    {
      MeetupPost? _post = await getMeetUpPostById(userHostIds[i]);

      if(_post != null)
      {
        _hostedPosts.add(_post);
      }
    }

    _comments = getDummyCommentsAboutUser(userId);
    // TODO: Check in DB if the current logged-in user follows this userId and set _isFollowing

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  // Follow/unfollow handling function
  Future<void> _handleFollowToggle() async {
    if (_isProcessingFollow) return; // Prevent duplicate if processing

    setState(() => _isProcessingFollow = true);

    // TODO: Send follow or unfollow request to the actual server/DB
    // Update _isFollowing status on successful request
    await Future.delayed(const Duration(milliseconds: 500)); // Simulation

    if (mounted) {
      setState(() {
        _isFollowing = !_isFollowing; // Toggle status
        _isProcessingFollow = false;
      });
      print('Follow status toggled for user: $_userId. Now following: $_isFollowing');
    }
  }



  // Call function (Placeholder)
  void _handleCall() {
    // TODO: Implement call functionality using packages like url_launcher
    // final Uri telLaunchUri = Uri(scheme: 'tel', path: _userProfile.phoneNumber); // Needs phone number field
    // await launchUrl(telLaunchUri);
    print('Call button pressed for user: ${_userProfile.name} (Not implemented)');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling feature is not implemented yet.')),
    );
  }

  // Message sending function
  void _handleMessage() {
    // TODO: Logic needed to create a chat room ID or find an existing one
    // Temporarily using userId as chatId
    Navigator.pushNamed(context, '/chat_room', arguments: _userProfile.userId);
    print('Message button pressed for user: ${_userProfile.name}');
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Preference box style (same as MyPageScreen)
    final Color prefBoxBgColor = colorScheme.brightness == Brightness.light
        ? Color(0xffE3DCF2).withValues(alpha: 0.5)
        : Color(0xffE3DCF2).withValues(alpha: 0.3);
    final Color prefBoxTitleColor = colorScheme.onSurface.withValues(alpha: 0.9);
    final Color prefBoxContentColor = colorScheme.onSurface;
    final Color prefBoxBorderColor = Color(0xffE3DCF2).withValues(alpha: 0.9);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: <Widget>[
          // 1. Top AppBar (User Name, Age, Back button)
          SliverAppBar(
            pinned: true,
            elevation: 1,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${_userProfile.name}, ${_userProfile.age}', // Display other user's info
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),

          // 2. Header Area (Map background, profile picture, status message, action buttons)
          SliverToBoxAdapter(
            child: SizedBox(
              // Adjust height if needed to include action button area
              height: 350, // Example: 280 (original) + 70 (button area)
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Map background (same as MyPageScreen)
                  Positioned.fill(
                    bottom: 70, // Exclude area for action buttons
                    child: Image.network(
                      'https://developers.google.com/static/maps/images/landing/hero_geocoding_api.png',
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.1),
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade300),
                    ),
                  ),
                  // Profile picture (same as MyPageScreen, InkWell removed)
                  Positioned(
                    top: 70,
                    child: CircleAvatar( // InkWell removed
                      radius: 65,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 62,
                        backgroundImage: NetworkImage(_userProfile.profileImageUrl),
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  // Status message (same as MyPageScreen)
                  Positioned(
                    top: 185,
                    child: Text(
                      _userProfile.statusMessage,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // --- New Action Buttons Area ---
                  Positioned(
                    top: 235, // Adjust position below status message
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      // Can add background color (optional)
                      // color: colorScheme.surface.withValues(alpha: 0.8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
                        children: [
                          _buildActionButton(
                            context,
                            icon: Icons.call,
                            label: 'Call',
                            onPressed: _handleCall,
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.chat_bubble_outline,
                            label: 'Message',
                            onPressed: _handleMessage,
                          ),
                          _buildActionButton(
                            context,
                            // Change icon based on follow status
                            icon: _isFollowing ? Icons.person_remove_alt_1_outlined : Icons.person_add_alt_1_outlined,
                            label: _isFollowing ? 'Following' : 'Follow',
                            onPressed: _handleFollowToggle,
                            // Show loading while processing follow (optional)
                            isLoading: _isProcessingFollow,
                            // Different color when following (optional)
                            // backgroundColor: _isFollowing ? colorScheme.primaryContainer : null,
                            // iconColor: _isFollowing ? colorScheme.primary : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Info Section (Info, Language, Preferences) - Use same widgets as MyPageScreen
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle(context, 'Info'),
                _buildInfoRow(context, Icons.location_on_outlined, _userProfile.location),
                _buildInfoRow(context, Icons.access_time, _userProfile.timeZoneInfo),
                const SizedBox(height: 20),

                _buildSectionTitle(context, 'Language'),
                ..._userProfile.languages.map((lang) => _buildLanguageRow(context, lang)),
                const SizedBox(height: 24),

                PreferenceDisplayBox(
                  title: 'I like', content: _userProfile.likes,
                  backgroundColor: prefBoxBgColor, titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor, borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 12),
                PreferenceDisplayBox(
                  title: "I've been", content: _userProfile.placesBeen,
                  backgroundColor: prefBoxBgColor, titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor, borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 12),
                PreferenceDisplayBox(
                  title: 'I want you to', content: _userProfile.wantsToDo,
                  backgroundColor: prefBoxBgColor, titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor, borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 15),
              ]),
            ),
          ),

          // 4. Hosting Section - Use same widgets as MyPageScreen
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(child: _buildSectionTitle(context, 'Hosting')),
          ),
          _hostedPosts.isEmpty
              ? SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            sliver: SliverToBoxAdapter(
              child: Center(child: Text('No meet-ups hosted yet.', style: TextStyle(color: Colors.grey))),
            ),
          )
              : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => MeetupPostItem(post: _hostedPosts[index]),
                childCount: _hostedPosts.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),

          // 5. Comments Section Modification
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Comments',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: colorScheme.onSurface.withOpacity(0.7)),
                        onPressed: () async { // Add async
                          // Navigate to user comment write screen and wait for the result (entered text)
                          final newCommentText = await Navigator.pushNamed(
                            context,
                            '/write_user_comment',
                            arguments: _userId,
                          );

                          // If result is non-null and non-empty string, update UI
                          if (newCommentText != null && newCommentText is String && newCommentText.isNotEmpty) {
                            // --- Create new comment object (temporary) ---
                            // TODO: In reality, this should be filled with current logged-in user info
                            final newComment = CommentModel(
                              commentId: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
                              commenterId: 'current_user_id', // Needs current user ID
                              commenterName: 'Me', // Needs current user name
                              commenterInfo: 'My Location, My Age', // Needs current user info
                              commenterImageUrl: 'https://i.pravatar.cc/150?img=60', // Needs current user image URL
                              commentText: newCommentText,
                              timestamp: DateTime.now(),
                            );
                            // --- End of creating new comment object ---

                            // Update state to add to the list (add to the front)
                            setState(() {
                              _comments.insert(0, newComment);
                            });
                          }
                        },
                        tooltip: 'Write a comment',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Divider(height: 16, thickness: 1, color: colorScheme.surfaceVariant.withOpacity(0.5)),
                ],
              ),
            ),
          ),
          _comments.isEmpty
              ? SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            sliver: SliverToBoxAdapter(
              child: Center(child: Text('No comments yet.', style: TextStyle(color: Colors.grey))),
            ),
          )
              : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Column(
                    children: [
                      CommentItem(comment: _comments[index]),
                      if (index < _comments.length - 1)
                        Divider(height: 1, thickness: 1, color: colorScheme.surfaceVariant.withValues(alpha: 0.3)),
                    ],
                  );
                },
                childCount: _comments.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  // --- Helper Widgets (Get from MyPageScreen or implement similarly) ---

  // Action button builder (newly added)
  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false, // Add loading status
    Color? backgroundColor,
    Color? iconColor,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color defaultBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.purple.shade50.withValues(alpha: 0.8)
        : Colors.purple.shade900.withValues(alpha: 0.6);
    final Color defaultIconColor = colorScheme.onSurface.withValues(alpha: 0.8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: isLoading ? null : onPressed, // Disable tap if loading
          borderRadius: BorderRadius.circular(30), // Ink effect radius
          child: CircleAvatar(
            radius: 30,
            backgroundColor: backgroundColor ?? defaultBackgroundColor,
            child: isLoading
                ? const SizedBox( // Loading indicator
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(
              icon,
              color: iconColor ?? defaultIconColor,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Section title widget
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Info row widget (icon + text)
  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
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
      ),
    );
  }

  // Language row widget (flag + name + proficiency)
  Widget _buildLanguageRow(BuildContext context, UserLanguageInfo language) {
    String flagAssetPath = 'assets/flags/${language.languageCode}.jpg'; // Check asset path

    print("✈️ Language Row: $flagAssetPath");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.asset(
            flagAssetPath,
            width: 24, height: 18, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(width: 24, height: 18, color: Colors.grey.shade300, child: Icon(Icons.flag, size: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              language.languageName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          LanguageIndicator(proficiency: language.proficiency),
        ],
      ),
    );
  }
}