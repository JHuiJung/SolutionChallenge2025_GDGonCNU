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
  int _selectedIndex = 0; // Currently selected tab index

  // List of screen widgets corresponding to each tab
  static const List<Widget> _widgetOptions = <Widget>[
    MeetupScreen(),
    MapScreen(),
    ChatScreen(),
  ];

  // Function to be called when a tab is selected
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // AppBar title for each tab
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Meet Up';
      case 1:
        return 'Explore';
      case 2:
        return 'Chat';
      default:
        return '여행 만남';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the top app bar
      // appBar: AppBar(
      //   title: Text(_getAppBarTitle(_selectedIndex)), // Change title based on selected tab
      // ),
      body: Center(
        // Display the screen corresponding to the selected index
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people), // Icon when active
            label: 'Meet Up',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex, // Current selected tab index
        // Color of selected item (get from theme or specify directly)
        selectedItemColor: Theme.of(context).primaryColor,
        // Color of unselected item
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Connect event handler for tab selection
        type: BottomNavigationBarType.fixed, // Use fixed type when the number of tabs is small
      ),
    );
  }
}