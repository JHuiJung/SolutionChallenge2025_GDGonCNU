import 'package:flutter/material.dart';
import 'tabs/meetup_screen.dart';
import 'tabs/map_screen.dart';
import 'tabs/chat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스

  // 각 탭에 해당하는 화면 위젯 리스트
  static const List<Widget> _widgetOptions = <Widget>[
    MeetupScreen(),
    MapScreen(),
    ChatScreen(),
  ];

  // 탭 선택 시 호출될 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 탭별 AppBar 제목
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Meet-Up';
      case 1:
        return 'Map';
      case 2:
        return 'Chat';
      default:
        return '여행 만남';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)), // 선택된 탭에 따라 제목 변경
      ),
      body: Center(
        // 선택된 인덱스에 해당하는 화면 표시
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people), // 활성화 시 아이콘
            label: 'Meet-Up',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex, // 현재 선택된 탭 인덱스
        // 선택된 아이템 색상 (테마에서 가져오거나 직접 지정)
        selectedItemColor: Theme.of(context).primaryColor,
        // 선택되지 않은 아이템 색상
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // 탭 선택 시 이벤트 핸들러 연결
        type: BottomNavigationBarType.fixed, // 탭 개수가 적을 때 고정 타입 사용
      ),
    );
  }
}