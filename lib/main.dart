import 'package:flutter/material.dart';
import "package:sliding_up_panel/sliding_up_panel.dart"; // 슬라이딩 패널 패키지 import
import 'screen/firebase_test_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
// 앱의 시작
void main() async {
  print("main 시작");
  WidgetsFlutterBinding.ensureInitialized(); // 필수!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("파이어베이스 정보 로딩 끝");
  runApp(const MyApp2());
}

class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FirebaseTestScreen(), // 실험 중이니까 이걸로 시작
    );
  }
}


// 앱의 루트 위젯입니다. MaterialApp을 설정합니다.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

// 앱의 기본 테마와 홈 화면을 설정
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naviya', // 앱 제목
      theme: ThemeData(
        primarySwatch: Colors.deepOrange, // 앱의 기본 색상 견본
        visualDensity: VisualDensity.adaptivePlatformDensity, // 플랫폼별 시각적 밀도 조정
        // 전체적인 앱 배경 및 AppBar 등의 색상을 어둡게 설정 (선택 사항)
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // 기본 Scaffold 배경색
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F), // AppBar 배경색
          foregroundColor: Colors.white, // AppBar 전경색 (텍스트, 아이콘)
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black, // 하단 네비게이션 바 배경색
          selectedItemColor: Colors.white, // 선택된 아이템 색상
          unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
        ),
      ),
      home: const HomeScreen(), // 앱이 시작될 때 표시될 첫 화면
      debugShowCheckedModeBanner: false, // 개발 중 표시되는 디버그 배너 숨김
    );
// [source: 3]
  }
}

// 앱의 메인 화면 위젯입니다. 하단 네비게이션 바와 페이지 전환을 관리합니다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
// [source: 4]
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // 초기 선택된 탭 인덱스를 'Map' (인덱스 2)으로 설정합니다.

// [source: 5] - 각 탭에 해당하는 페이지 위젯 목록입니다.
  // 요구사항에 맞춰 PlaceholderPage를 실제 구현된 화면 위젯으로 교체합니다.
  final List<Widget> _pages = [
    const PlaceholderPage(title: 'Home'),           // 홈 화면 (임시)
    const PlaceholderPage(title: 'Lightning'),     // 라이트닝 화면 (임시)
    const MapScreen(),                             // 지도 화면 (수정됨)
    const ChatListScreen(),                        // 채팅 목록 화면 (수정됨)
    const MyPageScreen(),                          // 마이페이지 화면 (수정됨)
  ];

// [source: 6] - 하단 네비게이션 바의 아이템을 탭했을 때 호출되는 함수입니다.
  void _onItemTapped(int index) {
    // setState를 호출하여 화면을 갱신하고 선택된 인덱스를 변경합니다.
    setState(() {
      _selectedIndex = index;
    });
// [source: 7]
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Stack( // Stack을 제거하여 검색창과 하단 바 오버레이를 없앱니다.
      //   children: [
      //     // 현재 선택된 페이지를 표시합니다.
      //     _pages[_selectedIndex],

      //     // --- 요구사항에 따라 전역 검색창 제거 ---
      //     // Positioned( ... ),

      //     // --- 요구사항에 따라 전역 '여행지' 바 제거 ---
      //     // Positioned( ... ),
      //   ],
      // ),
      // Stack 대신 현재 선택된 페이지만 표시하도록 변경합니다.
      body: _pages[_selectedIndex],

      // 하단 네비게이션 바 설정입니다.
      bottomNavigationBar: BottomNavigationBar(
// [source: 18] - 네비게이션 바 아이템 목록입니다.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),   // 기본 아이콘
            activeIcon: Icon(Icons.home),     // 활성화 시 아이콘
            label: 'Home',                      // 아이템 라벨
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
// [source: 19]
            activeIcon: Icon(Icons.article),
            label: 'Lightning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
// [source: 20]
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Mypage',
// [source: 21]
          ),
        ],
        currentIndex: _selectedIndex, // 현재 선택된 탭 인덱스
        // 테마에서 설정되었으므로 주석 처리 또는 삭제 가능
        // selectedItemColor: Colors.white,
        // unselectedItemColor: Colors.grey,
        // backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed, // 모든 아이템 라벨 고정 표시
        onTap: _onItemTapped, // 아이템 탭 시 호출될 함수 연결
      ),

      // 플로팅 액션 버튼입니다. Map 화면(인덱스 2)일 때만 표시됩니다.
      // 위치 조정을 위해 floatingActionButtonLocation 사용 가능
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
        onPressed: () {
          // TODO: 플로팅 버튼 클릭 시 동작 구현
          print("플로팅 액션 버튼 클릭됨!");
        },
        backgroundColor: Colors.deepOrange, // 버튼 배경색
        child: const Icon(Icons.add, size: 30), // 버튼 아이콘
        tooltip: '장소 추가', // 버튼 위에 오래 누르면 표시될 툴팁
      )
          : null, // Map 화면이 아니면 버튼 표시 안 함
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // 버튼 위치 (기본값)
// [source: 22]
// [source: 23]
    );
  }
}

// --- Map Screen ---
// 지도와 하단 슬라이딩 패널을 포함하는 화면 위젯입니다.
class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 화면 크기를 얻어와 패널의 최대 높이를 설정합니다.
    final double screenHeight = MediaQuery.of(context).size.height;
    // 패널이 최대로 올라왔을 때 화면의 80%를 차지하도록 설정
    final double maxPanelHeight = screenHeight * 0.8;
    // 패널이 접혔을 때의 최소 높이 (기존 '여행지' 바와 유사한 높이)
    const double minPanelHeight = 60.0;

    return SlidingUpPanel(
      // 패널의 최대/최소 높이 설정
      maxHeight: maxPanelHeight,
      minHeight: minPanelHeight,
      // 패널 배경색 및 모양 설정
      color: Colors.grey[900]!, // 패널 배경색 (어둡게)
      borderRadius: const BorderRadius.only( // 패널 상단 모서리 둥글게
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      ),
      // 패널 헤더 (상단 핸들 부분)
      header: Container(
        width: MediaQuery.of(context).size.width, // 너비 전체 채움
        height: minPanelHeight, // 헤더 높이 = 최소 패널 높이
        padding: const EdgeInsets.only(top: 8.0), // 상단 여백
        decoration: BoxDecoration( // 헤더에도 동일한 둥근 모서리 적용
          color: Colors.grey[900]!,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Column( // 핸들 모양과 텍스트 배치
          mainAxisAlignment: MainAxisAlignment.start, // 위쪽 정렬
          crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
          children: [
            // 위로 드래그 핸들 모양
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            const SizedBox(height: 10), // 핸들과 텍스트 사이 간격
            // '여행지 목록' 텍스트
            Text(
              '여행지 목록',
              style: TextStyle(
                color: Colors.grey[300],
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      // 패널 본문 (스크롤 가능한 여행지 목록)
      panel: _buildTravelDestinationList(),
      // 패널 뒤의 배경 내용 (지도)
      body: const MapPlaceholderWidget(), // 실제 지도를 표시할 위젯
      // 패널 스크롤 시 body(지도)가 어두워지는 효과 (선택 사항)
      backdropEnabled: true,
      backdropColor: Colors.black,
      backdropOpacity: 0.5,
    );
  }

  // 여행지 목록을 만드는 위젯 함수입니다.
  Widget _buildTravelDestinationList() {
    // TODO: 실제 여행지 데이터로 교체해야 합니다.
    final List<String> destinations = List.generate(20, (index) => '여행지 ${index + 1}');

    // ListView.builder를 사용하여 스크롤 가능한 목록을 만듭니다.
    return ListView.builder(
      // 패널 헤더 높이만큼 상단 패딩을 주어 내용이 가려지지 않도록 합니다.
      padding: const EdgeInsets.only(top: minPanelHeight + 10, left: 16, right: 16, bottom: 16),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        return Card( // 각 여행지를 카드 형태로 표시
          color: Colors.grey[800],
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            leading: Icon(Icons.location_pin, color: Colors.deepOrangeAccent), // 장소 아이콘
            title: Text(
              destinations[index],
              style: const TextStyle(color: Colors.white), // 텍스트 색상
            ),
            subtitle: Text(
              '여행지 ${index + 1}에 대한 간단한 설명입니다.',
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: IconButton( // 상세 정보 버튼 (예시)
              icon: Icon(Icons.info_outline, color: Colors.grey[400]),
              onPressed: () {
                // TODO: 여행지 상세 정보 보기 기능 구현
                print('${destinations[index]} 정보 보기');
              },
            ),
            onTap: () {
              // TODO: 여행지 선택 시 동작 구현 (예: 지도 이동)
              print('${destinations[index]} 선택됨');
            },
          ),
        );
      },
    );
  }

  // const double minPanelHeight = 60.0; // 다른 함수에서도 사용하기 위해 클래스 멤버 변수로 선언할 수 있습니다.
  static const double minPanelHeight = 60.0; // 또는 static 상수로 선언

}

// 지도 화면의 실제 지도 부분을 나타내는 임시 위젯입니다.
// TODO: 실제 지도 SDK(예: Maps_flutter) 위젯으로 교체해야 합니다.
class MapPlaceholderWidget extends StatelessWidget {
  const MapPlaceholderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 기존 MapPlaceholderPage와 유사하게 어두운 배경을 사용합니다.
    return Container(
      color: const Color(0xFF242f3e), // 어두운 배경색 (지도처럼 보이게)
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              '지도 표시 영역',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// --- Chat Screens ---

// 채팅 목록을 보여주는 화면 위젯입니다.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 채팅방 목록 데이터로 교체해야 합니다.
    final List<Map<String, String>> chatRooms = List.generate(
      15,
          (index) => {
        'name': '사용자 ${index + 1}',
        'lastMessage': '마지막 대화 내용 미리보기 $index...',
        'time': '${(index % 60).toString().padLeft(2, '0')}분 전', // 간단한 시간 표시 예시
        'avatarUrl': 'https://picsum.photos/seed/${index + 1}/100/100', // 임시 아바타 이미지
      },
    );

    return Scaffold(
      // AppBar를 추가하여 화면 제목을 표시합니다.
      appBar: AppBar(
        title: const Text('채팅'),
        // AppBar 배경색은 앱 테마에서 설정됩니다.
        // backgroundColor: Colors.black87, // 필요시 개별 설정 가능
      ),
      body: ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final room = chatRooms[index];
          return ListTile(
            // 사용자 아바타 (원형 이미지)
            leading: CircleAvatar(
              backgroundImage: NetworkImage(room['avatarUrl']!), // 네트워크 이미지 사용
              backgroundColor: Colors.grey[700], // 이미지 로딩 전 배경색
            ),
            // 채팅방 이름 (사용자 이름)
            title: Text(
              room['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            // 마지막 메시지 미리보기
            subtitle: Text(
              room['lastMessage']!,
              style: TextStyle(color: Colors.grey[400]),
              maxLines: 1, // 한 줄만 표시
              overflow: TextOverflow.ellipsis, // 넘치면 ... 처리
            ),
            // 마지막 메시지 시간
            trailing: Text(
              room['time']!,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            // 리스트 타일을 탭했을 때의 동작
            onTap: () {
              // ChatScreen으로 이동하고, 채팅방 정보를 전달합니다.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chatRoomName: room['name']!),
                ),
              );
              print('${room['name']} 채팅방 입장');
            },
          );
        },
      ),
    );
  }
}

// 개별 채팅 화면 위젯입니다.
class ChatScreen extends StatefulWidget {
  final String chatRoomName; // 이전 화면에서 전달받은 채팅방 이름

  const ChatScreen({Key? key, required this.chatRoomName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController(); // 메시지 입력 컨트롤러
  final List<Map<String, dynamic>> _messages = []; // 채팅 메시지 목록 (임시 데이터)

  @override
  void initState() {
    super.initState();
    // 임시로 초기 메시지 몇 개를 추가합니다.
    // TODO: 실제로는 서버에서 메시지를 로드해야 합니다.
    _messages.addAll([
      {'sender': 'other', 'text': '안녕하세요!'},
      {'sender': 'me', 'text': '안녕하세요! ${widget.chatRoomName}님.'},
      {'sender': 'other', 'text': '테스트 테스트'},
      {'sender': 'me', 'text': '아ㅓ나ㅣ어ㅣㅏ'},
    ]);
  }

  // 메시지 전송 함수
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        // 내가 보낸 메시지를 목록에 추가합니다.
        _messages.add({'sender': 'me', 'text': text});
        _messageController.clear(); // 입력 필드 비우기

        // TODO: 실제로는 서버로 메시지를 전송해야 합니다.

        // (임시) 상대방이 답장하는 것처럼 보이게 설정
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _messages.add({'sender': 'other', 'text': '메시지 잘 받았습니다!'});
          });
        });
      });
      // 키보드 숨기기 (선택 사항)
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar에 채팅 상대방 이름을 표시합니다.
      appBar: AppBar(
        title: Text(widget.chatRoomName),
        // 뒤로가기 버튼이 자동으로 생성됩니다.
      ),
      body: Column(
        children: [
          // 채팅 메시지 목록을 표시하는 영역
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: _messages.length,
              // reverse: true, // 최신 메시지가 아래에 오도록 하려면 주석 해제 및 정렬 로직 추가 필요
              itemBuilder: (context, index) {
                final message = _messages[index];
                // 내가 보낸 메시지인지 상대방이 보낸 메시지인지 구분
                final isMe = message['sender'] == 'me';

                return Align(
                  // 메시지 정렬 (나는 오른쪽, 상대는 왼쪽)
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    // 메시지 버블 스타일
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.deepOrangeAccent : Colors.grey[700],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // 메시지 텍스트
                    child: Text(
                      message['text'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          // 하단 메시지 입력 영역
          _buildMessageInputField(),
        ],
      ),
    );
  }

  // 메시지 입력 필드를 만드는 위젯 함수입니다.
  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor, // AppBar와 유사한 배경색
        boxShadow: [ // 상단에 약간의 그림자 효과
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 1,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea( // 시스템 UI 영역(예: iPhone 하단 홈 인디케이터) 침범 방지
        child: Row(
          children: [
            // 메시지 입력 텍스트 필드
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white), // 입력 텍스트 색상
                decoration: InputDecoration(
                  hintText: '메시지 입력...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  filled: true, // 배경색 채우기 활성화
                  fillColor: Colors.grey[800], // 입력 필드 배경색
                  border: OutlineInputBorder( // 테두리 설정
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none, // 테두리 선 없음
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                ),
                // 엔터 키 눌렀을 때 전송 (선택 사항)
                // onSubmitted: (value) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8.0), // 입력 필드와 전송 버튼 사이 간격
            // 전송 버튼
            IconButton(
              icon: const Icon(Icons.send),
              color: Colors.deepOrangeAccent, // 아이콘 색상
              onPressed: _sendMessage, // 버튼 클릭 시 메시지 전송 함수 호출
            ),
          ],
        ),
      ),
    );
  }

  // 위젯이 제거될 때 컨트롤러를 해제하여 메모리 누수를 방지합니다.
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}


// --- MyPage Screen ---

// 마이페이지 화면 위젯입니다. 프로필 정보와 설정 메뉴를 표시합니다.
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        // actions: [ // 필요한 경우 AppBar 오른쪽에 버튼 추가 (예: 설정)
        //   IconButton(
        //     icon: Icon(Icons.settings),
        //     onPressed: () {
        //       // TODO: 설정 화면으로 이동
        //     },
        //   ),
        // ],
      ),
      body: ListView( // 스크롤 가능한 레이아웃
        padding: const EdgeInsets.all(16.0), // 전체적인 여백
        children: [
          // --- 프로필 섹션 ---
          _buildProfileSection(context),
          const SizedBox(height: 30.0), // 섹션 간 간격

          // --- 메뉴 섹션 ---
          _buildMenuSection(context),

          // TODO: 필요한 다른 섹션들 추가 (예: 내 활동, 공지사항 등)
        ],
      ),
    );
  }

  // 프로필 정보를 표시하는 위젯 함수입니다.
  Widget _buildProfileSection(BuildContext context) {
    // TODO: 실제 사용자 데이터로 교체해야 합니다.
    const String username = "Solution Challenge"; // 유저의 개인정보 입력으로부터 받아온다
    const String email = "user@gmail.com"; // 유저의 로그인 정보 입력으로부터 받아온다.
    const String avatarUrl = "https://cdn.pixabay.com/photo/2022/01/17/01/19/cherry-blossoms-6943659_1280.jpg"; // 임시 프로필

    return Column( // 프로필 요소들을 세로로 배치
      crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
      children: [
        // 프로필 이미지
        CircleAvatar(
          radius: 50.0, // 원의 반지름
          backgroundImage: NetworkImage(avatarUrl),
          backgroundColor: Colors.grey[700], // 이미지 로딩 전 배경색
        ),
        const SizedBox(height: 16.0), // 이미지와 이름 사이 간격
        // 사용자 이름
        Text(
          username,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith( // headlineSmall 스타일에 색상 적용
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8.0), // 이름과 이메일 사이 간격
        // 사용자 이메일
        Text(
          email,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 20.0), // 이메일과 수정 버튼 사이 간격
        // 프로필 수정 버튼 (선택 사항)
        ElevatedButton.icon(
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit Profile'),
          style: ElevatedButton.styleFrom(
            // primary: Colors.deepOrangeAccent, // 버튼 배경색 (테마 기본값 사용 시 주석 처리)
            // onPrimary: Colors.white, // 버튼 텍스트/아이콘 색상 (테마 기본값 사용 시 주석 처리)
            shape: RoundedRectangleBorder( // 버튼 모양 둥글게
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          onPressed: () {
            // TODO: 프로필 수정 화면으로 이동하는 로직 구현
            print('프로필 수정 버튼 클릭');
          },
        ),
      ],
    );
  }

  // 설정 메뉴 등을 표시하는 위젯 함수입니다.
  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
      children: [
        // 메뉴 제목 (선택 사항)
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            '설정',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[300],
            ),
          ),
        ),
        // 메뉴 아이템들을 Card 안에 배치하여 그룹화
        Card(
          color: Colors.grey[850], // 카드 배경색
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // 카드 모서리 둥글게
          clipBehavior: Clip.antiAlias, // 내부 컨텐츠가 카드 모양을 벗어나지 않도록 함
          child: Column(
            children: [
              _buildMenuItem(
                context,
                icon: Icons.notifications_outlined,
                title: '알림 설정',
                onTap: () {
                  // TODO: 알림 설정 화면으로 이동
                  print('알림 설정 클릭');
                },
              ),
              _buildDivider(), // 구분선
              _buildMenuItem(
                context,
                icon: Icons.lock_outline,
                title: '계정 및 보안',
                onTap: () {
                  // TODO: 계정/보안 설정 화면으로 이동
                  print('계정 및 보안 클릭');
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.language,
                title: '언어 설정',
                onTap: () {
                  // TODO: 언어 설정 기능 구현
                  print('언어 설정 클릭');
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: '고객센터',
                onTap: () {
                  // TODO: 고객센터 화면 또는 웹페이지 연결
                  print('고객센터 클릭');
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.logout,
                title: '로그아웃',
                color: Colors.redAccent, // 로그아웃 강조 색상
                onTap: () {
                  // TODO: 로그아웃 로직 구현
                  _showLogoutDialog(context); // 로그아웃 확인 다이얼로그 표시
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 개별 메뉴 아이템 위젯을 만드는 함수입니다.
  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, Color? color, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[400]), // 아이콘 색상 (기본값 또는 지정 색상)
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.white, fontSize: 16), // 텍스트 색상
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[600]), // 오른쪽 화살표 아이콘
      onTap: onTap, // 탭 시 실행될 함수
    );
  }

  // 메뉴 아이템 사이의 구분선을 만드는 함수입니다.
  Widget _buildDivider() {
    return Divider(
      height: 1, // 구분선 높이
      thickness: 1, // 구분선 두께
      color: Colors.grey[800], // 구분선 색상
      indent: 16.0, // 왼쪽 들여쓰기
      endIndent: 16.0, // 오른쪽 들여쓰기
    );
  }

  // 로그아웃 확인 다이얼로그를 표시하는 함수입니다.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('로그아웃', style: TextStyle(color: Colors.white)),
          content: Text('정말 로그아웃 하시겠습니까?', style: TextStyle(color: Colors.grey[300])),
          actions: <Widget>[
            TextButton(
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: const Text('로그아웃', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                // TODO: 실제 로그아웃 처리 로직 추가
                print('로그아웃 실행');
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                // 로그인 화면으로 이동하거나 앱 상태 변경 로직 추가
              },
            ),
          ],
        );
      },
    );
  }
}

// --- Placeholder Page ---
// 아직 구현되지 않은 다른 탭들을 위한 임시 페이지 위젯입니다.
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 어두운 테마에 맞춰 배경 및 텍스트 색상 조정
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // 각 페이지 제목을 AppBar에 표시
      ),
      body: Container(
        // color: Colors.grey[850], // Scaffold 배경색과 동일하게 하거나 다른 색 지정 가능
        alignment: Alignment.center,
        child: Center(
          child: Text(
            '$title 페이지 내용',
            style: const TextStyle(fontSize: 24, color: Colors.grey),
          ),
        ),
      ),
    );
// [source: 24]
// [source: 25]
  }
}

// --- 사용하지 않는 위젯 제거 ---
// 기존 MapPlaceholderPage는 MapScreen으로 대체되었으므로 제거합니다.
// class MapPlaceholderPage extends StatelessWidget { ... } [source: 26, 27]