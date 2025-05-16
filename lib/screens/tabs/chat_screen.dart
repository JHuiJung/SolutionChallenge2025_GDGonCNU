// lib/screens/tabs/chat_screen.dart
import 'package:flutter/material.dart';
import '../../models/chat_list_item_model.dart'; // Import chat model
import '../../widgets/chat_list_item.dart'; // Import chat item widget
import '../../firebase/firestoreManager.dart'; // Import Firestore manager

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatListItemModel> _chatList = []; // Full list of chats to display on screen
  bool _isLoading = true; // Data loading status
  // late UserState userinfo; // Current user information (use mainUserInfo directly or manage as state if needed)

  @override
  void initState() {
    super.initState();
    _loadAndProcessChatList(); // Call function to load and process chat list
  }

  // Function to load chat list and handle AI Tutor fixed item
  Future<void> _loadAndProcessChatList() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // UserState userinfo = mainUserInfo; // Use global variable (or inject with Provider etc.)
    List<ChatListItemModel> fetchedUserChats = [];

    // 1. Get each chat room's information based on the current user's chat ID list
    //    (Assuming mainUserInfo.chatIds is the list of chat room IDs fetched from Firestore)
    if (mainUserInfo.chatIds.isNotEmpty) {
      for (String chatId in mainUserInfo.chatIds) {
        // Skip 'chat_ai_tutor' as it's handled separately
        if (chatId == 'chat_ai_tutor') continue;

        ChatListItemModel? chatItem = await getChat(chatId); // Get chat room info from Firestore
        if (chatItem != null) {
          fetchedUserChats.add(chatItem);
        }
      }
    }

    // 2. Sort user chat list by time (latest message at the top)
    fetchedUserChats.sort((a, b) {
      // Convert TimeOfDay to a comparable form (based on today's date)
      final now = DateTime.now();
      final aDateTime = DateTime(now.year, now.month, now.day, a.timestamp.hour, a.timestamp.minute);
      final bDateTime = DateTime(now.year, now.month, now.day, b.timestamp.hour, b.timestamp.minute);
      return bDateTime.compareTo(aDateTime); // Sort in descending order
    });

    // 3. Create or load AI Tutor chat room information
    //    (Assuming AI Tutor always exists, load from Firestore if necessary)
    ChatListItemModel aiTutorChat = ChatListItemModel(
      chatId: 'chat_ai_tutor',
      userId: 'ai_tutor_bot', // AI Tutor's unique ID
      name: 'Hatchy',
      imageUrl: null, // AI Tutor profile image path
      lastMessage: 'Hi! How can I help you?', // Initial or last message
      timestamp: TimeOfDay.now(), // To always appear latest (or use actual last message time)
      isRead: true, // Default value
    );
    // If AI Tutor chat room info is also managed in Firestore, call getChat('chat_ai_tutor') here

    // 4. Compose the final chat list: Add AI Tutor at the very beginning
    List<ChatListItemModel> finalChatList = [aiTutorChat, ...fetchedUserChats];

    if (mounted) {
      setState(() {
        _chatList = finalChatList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // UserState userinfo = mainUserInfo; // Refer again if needed within the build method

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator( // Add pull-to-refresh functionality
              onRefresh: _loadAndProcessChatList,
              child: CustomScrollView(
                slivers: [
                  // 1. Top Header (Chat Title, MyPage Icon)
                  _buildHeader(context, colorScheme, mainUserInfo),
                  // Pass mainUserInfo

                  // 2. Chat List
                  _buildChatList(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Builder Functions ---

  // Build top header function
  Widget _buildHeader(BuildContext context, ColorScheme colorScheme,
      UserState currentUserInfo) {
    return SliverPadding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Chat",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/mypage'),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade300,
                // Display current user's profile image
                backgroundImage: (currentUserInfo.profileURL.isNotEmpty)
                    ? NetworkImage(currentUserInfo.profileURL)
                    : const AssetImage(
                    'assets/images/user_profile.jpg') as ImageProvider, // Default image asset
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build chat list function
  Widget _buildChatList(ColorScheme colorScheme) {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_chatList.isEmpty) {
      // If even AI Tutor is missing, show this message (rare in practice as AI Tutor should always exist)
      return const SliverFillRemaining(
        child: Center(
          child: Text('No chats yet!', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return Column(
            children: [
              ChatListItem(chat: _chatList[index]),
              if (index < _chatList.length - 1) // Add divider except for the last item
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 88, // Profile picture width + padding
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                ),
            ],
          );
        },
        childCount: _chatList.length,
      ),
    );
  }
}