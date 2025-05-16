// lib/screens/tabs/meetup_screen.dart
import 'package:flutter/material.dart';
import '../../models/meetup_post.dart';
import '../../widgets/meetup_post_item.dart';
import '../../firebase/firestoreManager.dart';

class MeetupScreen extends StatefulWidget {
  const MeetupScreen({super.key});

  @override
  State<MeetupScreen> createState() => _MeetupScreenState();
}

class _MeetupScreenState extends State<MeetupScreen> {
  List<MeetupPost> _allPosts = []; // Store original list of all posts
  List<MeetupPost> _displayedPosts = []; // Posts to be displayed on screen (filtered result)
  bool _isLoading = true;
  String? _searchQuery; // State variable to store search query

  late UserState userinfo;

  @override
  void initState() {
    super.initState();
    _loadMeetupPosts(); // Initial data load
  }

  // Load all posts (initial or when search is cleared)
  Future<void> _loadMeetupPosts() async {

    userinfo = mainUserInfo;
    print("Meet up initialization function ${userinfo.name}");

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _searchQuery = null; // Initialize search query
    });
    await Future.delayed(const Duration(milliseconds: 500));
    //_allPosts = getDummyMeetupPosts(); // Get all dummy data
    _allPosts = await getAllMeetUpPost();
    _displayedPosts = List.from(_allPosts); // Initially display all posts
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  // Filter posts based on search query
  void _filterMeetupPosts() {
    if (!mounted) return;
    setState(() {
      _isLoading = true; // Show loading during filtering (optional)
    });

    if (_searchQuery == null || _searchQuery!.isEmpty) {
      // If no search query, display all posts
      _displayedPosts = List.from(_allPosts);
    } else {
      // If there is a search query, filter posts whose title contains the query (case-insensitive)
      final query = _searchQuery!.toLowerCase();
      _displayedPosts = _allPosts
          .where((post) => post.title.toLowerCase().contains(query))
          .toList();
    }

    setState(() {
      _isLoading = false; // Loading complete
    });
  }

  // Initialize search status and reload all posts
  void _clearSearch() {
    _loadMeetupPosts(); // Reload all posts (includes setState)
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              // Clear search status and reload all on pull-to-refresh
              onRefresh: _loadMeetupPosts,
              child: CustomScrollView(
                slivers: [
                  // 1. Modify top header area
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- Left: Title or Search Result ---
                          Expanded( // Use Expanded to reserve space for the right icons
                            child: (_searchQuery == null || _searchQuery!.isEmpty)
                                ? const Text( // Default title
                              "Let's meet up!",
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                : Row( // Display search result
                              children: [
                                Flexible( // Handle long search queries
                                  child: Text(
                                    '"$_searchQuery"', // Display search query
                                    style: const TextStyle(
                                      fontSize: 24, // Slightly smaller than title
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis, // Ellipsis on overflow
                                  ),
                                ),
                                IconButton( // Clear search button
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: _clearSearch,
                                  tooltip: 'Clear search',
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.only(left: 4.0), // Spacing from text
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),

                          // --- Right: Icon Group ---
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Search button
                              IconButton(
                                icon: Icon(Icons.search, color: colorScheme.onSurface, size: 28),
                                onPressed: () async { // Add async
                                  // Navigate to search screen and wait for result (search query)
                                  final result = await Navigator.pushNamed(context, '/search');
                                  // If the result is a non-null, non-empty string
                                  if (result != null && result is String && result.isNotEmpty) {
                                    // Update state and perform filtering
                                    setState(() {
                                      _searchQuery = result;
                                    });
                                    _filterMeetupPosts(); // Call filtering function
                                  } else if (result == null) {
                                    // If user navigates back without searching (do nothing)
                                    print('Search cancelled');
                                  }
                                },
                                tooltip: 'Search Meet-ups',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 2),
                              // Write button
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: colorScheme.onSurface, size: 28),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/write_meetup'); // Change existing write part to write_meetup
                                },
                                tooltip: 'Write a Post',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 10),
                              // Profile Avatar
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/mypage');
                                },
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: (userinfo != null && userinfo.profileURL != null && userinfo.profileURL.isNotEmpty)
                                  // Use NetworkImage if userinfo exists and profileURL is not null and not empty
                                      ? NetworkImage(userinfo.profileURL) as ImageProvider<Object>?
                                  // Otherwise, use a default image (AssetImage etc.) or display a different widget entirely
                                      : AssetImage('assets/images/user_profile.jpg') as ImageProvider<Object>?, // Example: Default profile image path,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Post List Area (Displayed data changed: _posts -> _displayedPosts)
                  _isLoading
                      ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : _displayedPosts.isEmpty // When filter result is empty
                      ? SliverFillRemaining(
                    child: Center(
                      child: Text(
                        _searchQuery == null
                            ? 'No meet-ups yet.' // Initial state message
                            : 'No results found for "$_searchQuery"', // No search results message
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                      : SliverPadding( // Display filter result
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          // *** Important: Use _displayedPosts ***
                          return MeetupPostItem(post: _displayedPosts[index]);
                        },
                        childCount: _displayedPosts.length,
                      ),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}