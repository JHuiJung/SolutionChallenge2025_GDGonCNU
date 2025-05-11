// lib/screens/tabs/chat_screen.dart
import 'package:flutter/material.dart';
import '../../models/chat_list_item_model.dart'; // 채팅 모델 임포트
import '../../widgets/chat_list_item.dart'; // 채팅 아이템 위젯 임포트
import '../../firebase/firestoreManager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<ChatListItemModel> _chatList;
  bool _isLoading = true;

  late UserState userinfo;

  @override
  void initState() {
    super.initState();
    _loadChatList();
  }

  Future<void> _loadChatList() async {

    userinfo = mainUserInfo;

    // Simulate loading data
    await Future.delayed(const Duration(milliseconds: 300));


    //_chatList = getDummyChatListItems();
    List<ChatListItemModel> _dummyChatList = getDummyChatListItems();

    List<ChatListItemModel> usersChats = [];

    for(int i = 0 ; i < mainUserInfo.chatIds.length ; ++i)
    {
      ChatListItemModel? newChat = await getChat(mainUserInfo.chatIds[i]);

      if(newChat != null)
        {
          usersChats.add(newChat);
        }

    }

    _chatList = usersChats;

    setState(() {
     //_chatList = getDummyChatListItems(); // 더미 데이터 사용



      // 더미 데이터 사용


      // 시간 순으로 정렬 (최신 메시지가 위로) - TimeOfDay 비교
      /*_chatList.sort((a, b) {
        final aDateTime = DateTime(0,0,0, a.timestamp.hour, a.timestamp.minute);
        final bDateTime = DateTime(0,0,0, b.timestamp.hour, b.timestamp.minute);
        return bDateTime.compareTo(aDateTime); // 내림차순 정렬
      });*/
      usersChats.sort((a, b) {
        final aDateTime = DateTime(0,0,0, a.timestamp.hour, a.timestamp.minute);
        final bDateTime = DateTime(0,0,0, b.timestamp.hour, b.timestamp.minute);
        return bDateTime.compareTo(aDateTime); // 내림차순 정렬
      });
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack( // AI 챗봇 버튼을 위에 띄우기 위해 Stack 사용
          children: [
            CustomScrollView(
              slivers: [
                // 1. 상단 헤더 (Chat 타이틀, MyPage 아이콘)
                SliverPadding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Chat",
                          style: TextStyle(
                            fontSize: 32, // Meetup과 동일하게
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // MyPage 화면으로 이동
                            Navigator.pushNamed(context, '/mypage');
                            print('Navigate to MyPage');
                          },
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.grey.shade300,
                            // TODO: 실제 사용자 프로필 이미지로 교체
                            backgroundImage: (userinfo != null && userinfo.profileURL != null && userinfo.profileURL.isNotEmpty)
                            // userinfo가 있고 profileURL이 null이 아니며 비어있지 않다면 NetworkImage 사용
                                ? NetworkImage(userinfo.profileURL) as ImageProvider<Object>?
                            // 그렇지 않다면 기본 이미지 (AssetImage 등) 사용 또는 아예 다른 위젯 표시
                                : AssetImage('assets/images/egg.png') as ImageProvider<Object>?,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. 채팅 목록
                _isLoading
                    ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
                    : _chatList.isEmpty
                    ? SliverFillRemaining( // 채팅 목록이 없을 때 표시할 내용 (선택 사항)
                  child: Center(
                    child: Text(
                      'No chats yet!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      // 구분선 추가 (마지막 아이템 제외)
                      return Column(
                        children: [
                          ChatListItem(chat: _chatList[index]),
                          if (index < _chatList.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 88, // 프로필 사진 너비 + 여백 만큼 들여쓰기
                              color: colorScheme.surfaceVariant.withOpacity(0.5),
                            ),
                        ],
                      );
                    },
                    childCount: _chatList.length,
                  ),
                ),
                // 하단 여백 (AI 버튼에 가려지지 않도록)
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),

            // 3. AI 채팅 버튼 (로봇 모양)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  // AI 채팅방으로 이동
                  Navigator.pushNamed(context, '/ai_chat');
                  print('Navigate to AI Chat');
                },
                backgroundColor: colorScheme.primaryContainer, // 테마 색상 활용
                child: Icon(
                  Icons.smart_toy_outlined, // 로봇 아이콘 (혹은 Image 위젯 사용)
                  color: colorScheme.onPrimaryContainer,
                  size: 30,
                ),
                // tooltip: 'Chat with AI', // 길게 눌렀을 때 힌트 (선택 사항)
              ),
            ),

            // 4. 로봇 일러스트 (선택 사항 - 목록이 비어있을 때만 표시하거나 항상 표시)
            // 실제 이미지 에셋 필요
            // if (!_isLoading && _chatList.isEmpty) // 목록이 비어있을 때만 표시
            Positioned(
              bottom: 80, // FAB 위에 위치하도록 조정
              right: 10,
              child: Opacity( // 약간 투명하게 (선택 사항)
                opacity: 0.8,
                child: Image.asset( // 실제 이미지 경로로 변경 필요
                  'assets/images/robot_thinking.png', // 예시 경로
                  height: 120,
                  // 에러 처리
                  errorBuilder: (context, error, stackTrace) => const SizedBox(height: 120), // 에러 시 빈 공간
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}