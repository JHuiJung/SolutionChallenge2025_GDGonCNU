// lib/screens/mypage_screen.dart
import 'package:flutter/material.dart';
import 'package:naviya/firebase/firestoreManager.dart';
import '../models/user_profile_model.dart'; // My profile model
import '../models/meetup_post.dart'; // Hosting post model
import '../models/comment_model.dart'; // Comment model
import '../widgets/meetup_post_item.dart'; // Hosting post widget
import '../widgets/comment_item.dart'; // Comment widget
import '../widgets/language_indicator.dart'; // Language indicator widget
import '../widgets/preference_display_box.dart'; // Preference box widget
import '../firebase/firestoreManager.dart' as firestoreManager;
import '../firebase/imageManager.dart' as imageManager;

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // --- Data loading status (needed in actual implementation) ---
  bool _isLoading = true;
  late UserProfileModel _userProfile;
  late List<MeetupPost> _hostedPosts;
  late List<CommentModel> _comments;

  // Fetch Firebase data
  late UserState userinfo;

  @override
  void initState() {
    super.initState();

    _loadMyPageData();
  }

  // Async data loading function (example)
  Future<void> _loadMyPageData() async {
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: Fetch data from actual API or local DB

    // Loading Firebase info
    userinfo = firestoreManager.mainUserInfo;


    List<MeetupPost> userMeetupPosts = [];


    print("(My Page) 🙄 Number of posts I wrote ${mainUserInfo.postIds.length}");
    for(int i = 0 ; i < mainUserInfo.postIds.length; ++i)
    {

      MeetupPost? _meetUpPost = await getMeetUpPostById(mainUserInfo.postIds[i]);
      print("(My Page) 🙄${i}th post I wrote ${_meetUpPost == null ? "None" : mainUserInfo.postIds[i]}");
      if(_meetUpPost != null)
      {
        userMeetupPosts.add(_meetUpPost);
      }
    }
    print("(My Page) 🙄 Number of posts loaded ${userMeetupPosts.length}");

    _userProfile = getDummyMyProfile();
    // Filter hosted posts (example: posts with authorId same as my ID)
    //_hostedPosts = getDummyMeetupPosts()
    _hostedPosts = userMeetupPosts
    //.where((post) => post.authorId == _userProfile.userId) // Actual ID comparison needed
        .toList();
    if (_hostedPosts.isEmpty && getDummyMeetupPosts().isNotEmpty) {
      // If I have no posts, show one post from someone else (for dummy data)
      print("(My Page)😥 No posts uploaded, creating dummy");
      _hostedPosts.add(getDummyMeetupPosts().first);
    }

    // Loading Firebase info
    userinfo = firestoreManager.mainUserInfo;


    _comments = getDummyComments();

    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Define preference box style
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
          // 1. Top AppBar (Name, Age, Back button)
          SliverAppBar(
            pinned: true, // Pin to the top when scrolling
            // backgroundColor: colorScheme.surface, // Use theme background color
            elevation: 1, // Slight shadow
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${userinfo.name}, ${userinfo.birthYear}',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true, // Center title
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: colorScheme.onSurface), // Pencil icon
                onPressed: () {
                  // Navigate to profile edit screen
                  Navigator.pushNamed(context, '/edit_mypage');
                  print('Navigate to Edit MyPage');
                },
                tooltip: 'Edit Profile', // Add tooltip
              ),
              const SizedBox(width: 8), // Right margin
            ],
            // --- End of actions addition ---
          ),

          // 2. Header Area (Map background, profile picture, status message)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280, // Adjust header area height
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Map background (use actual map SDK or image)
                  Positioned.fill(
                    child: Image.network( // Example image
                      'https://developers.google.com/static/maps/images/landing/hero_geocoding_api.png',
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.1), // Slightly darken (optional)
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade300),
                    ),
                  ),
                  // Profile picture (displayed above the map)
                  Positioned(
                    top: 50, // Position from the top of the map
                    child: InkWell(
                      onTap:() async {

                        // Save image
                        bool isImageChanged = await imageManager
                            .handleImageUpload(userinfo.email ?? 'none');
                        if (isImageChanged) {
                          Navigator.pushNamed(context, '/mypage');
                          // UI update etc.
                        }

                        //Navigator.pushNamed(context, '/edit_profile_picture');
                        //print('Navigate to edit profile picture');
                      },

                      child: CircleAvatar(
                        radius: 65, // Photo size
                        backgroundColor: Colors.white, // Border effect
                        child: CircleAvatar(
                          radius: 62,
                          // Check if profileURL is null here.
                          backgroundImage: (userinfo != null && userinfo.profileURL != null && userinfo.profileURL.isNotEmpty)
                          // If userinfo exists and profileURL is not null and not empty, use NetworkImage
                              ? NetworkImage(userinfo.profileURL) as ImageProvider<Object>?
                          // Otherwise, use a default image (AssetImage etc.) or display a different widget entirely
                              : AssetImage('assets/images/user_profile.jpg') as ImageProvider<Object>?, // Example: default profile image path
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  // Status message (below the profile picture)
                  Positioned(
                    top: 185, // Adjust to be below the profile picture
                    child: Text(
                      userinfo.statusMessage,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text because background is dark
                        shadows: [ // Improve text readability (optional)
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Info Section (Info, Language, Preferences) - Add padding
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // --- Info ---
                _buildSectionTitle(context, 'Info'),
                _buildInfoRow(context, Icons.location_on_outlined, userinfo.region ?? 'No Location'),
                _buildInfoRow(context, Icons.access_time, DateTime.now().toString().split('.').first),
                const SizedBox(height: 24),

                // --- Language ---
                _buildSectionTitle(context, 'Language'),
                ...userinfo.languages.map((lang) => _buildLanguageRow(context, lang)),
                //..._userProfile.languages.map((lang) => _buildLanguageRow(context, lang)),
                const SizedBox(height: 24),

                // --- Preferences ---
                PreferenceDisplayBox(
                  title: 'I like',
                  content: userinfo.iLike,
                  backgroundColor: prefBoxBgColor,
                  titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor,
                  borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 12),
                PreferenceDisplayBox(
                  title: "I've been",
                  content: userinfo.visitedCountries.join(", "),
                  backgroundColor: prefBoxBgColor,
                  titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor,
                  borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 12),
                PreferenceDisplayBox(
                  title: 'I want you to',
                  content: userinfo.wantsToDo,
                  backgroundColor: prefBoxBgColor,
                  titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor,
                  borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),

          // 4. Hosting Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(child: _buildSectionTitle(context, 'Hosting')),
          ),
          _hostedPosts.isEmpty
              ? SliverPadding( // Message when no hosted posts
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            sliver: SliverToBoxAdapter(
              child: Center(child: Text('No meet-ups hosted yet.', style: TextStyle(color: Colors.grey))),
            ),
          )
              : SliverPadding( // List of hosted posts
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => MeetupPostItem(post: _hostedPosts[index]),
                childCount: _hostedPosts.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)), // Margin between sections

          // 5. Comments Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(child: _buildSectionTitle(context, 'Comments')),
          ),
          _comments.isEmpty
              ? SliverPadding( // Message when no comments
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            sliver: SliverToBoxAdapter(
              child: Center(child: Text('No comments yet.', style: TextStyle(color: Colors.grey))),
            ),
          )
              : SliverPadding( // List of comments
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Column( // Add a divider below each comment
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
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)), // Bottom margin
        ],
      ),
    );
  }

  // --- Helper Widgets ---

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
          Expanded( // Handle text wrapping for long text
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  // Huijung's version
  Widget _buildLanguageRow(BuildContext context, UserLanguageInfo langinfo) {
    // TODO: Actual flag image assets needed matching languageCode
    String flagAssetPath = 'assets/flags/${langinfo.languageCode}.jpg'; // Example path
    //String flagAssetPath = 'assets/flags/usa.jpg'; // Example path

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Flag image (asset needed)
          Image.asset(
            flagAssetPath,
            width: 24,
            height: 18, // Maintain aspect ratio
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => // Placeholder on error
            Container(width: 24, height: 18, color: Colors.grey.shade300, child: Icon(Icons.flag, size: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              langinfo.languageName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          LanguageIndicator(proficiency: langinfo.proficiency), // Display proficiency dots
        ],
      ),
    );
  }
}
/*
  // Language row widget (flag + name + proficiency) _ Jaehyeon version
  Widget _buildLanguageRow(BuildContext context, UserLanguage language) {
    // TODO: Actual flag image assets needed matching languageCode
    String flagAssetPath = 'assets/flags/korea.jpg'; // Example path
    //String flagAssetPath = 'assets/flags/usa.jpg'; // Example path

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Flag image (asset needed)
          Image.asset(
            flagAssetPath,
            width: 24,
            height: 18, // Maintain aspect ratio
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => // Placeholder on error
            Container(width: 24, height: 18, color: Colors.grey.shade300, child: Icon(Icons.flag, size: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              language.languageName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          LanguageIndicator(proficiency: language.proficiency), // Display proficiency dots
        ],
      ),
    );
  }
}
*/

// --- Placeholder Screen for Editing Profile Picture ---
class EditProfilePictureScreen extends StatelessWidget {
  const EditProfilePictureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile Picture')),
      body: const Center(child: Text('Image picker/cropper interface goes here')),
    );
  }
}