// lib/screens/search_screen.dart
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 검색 실행 함수
  void _performSearch(String query) {
    final trimmedQuery = query.trim(); // 앞뒤 공백 제거
    if (trimmedQuery.isNotEmpty) { // 검색어가 비어있지 않을 때만 결과 반환
      print('Performing search for: $trimmedQuery');
      // *** 중요: 검색어를 결과로 전달하며 pop ***
      Navigator.pop(context, trimmedQuery);
    } else {
      // 검색어가 비어있으면 아무것도 안하거나, 사용자에게 알림 (선택 사항)
      print('Search query is empty.');
      // 예: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a search term.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          // *** 중요: 뒤로가기 버튼은 null을 반환 ***
          onPressed: () => Navigator.pop(context), // 결과 없이 pop
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search meet-ups...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch, // 엔터키로 검색 실행
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear, color: colorScheme.onSurface.withOpacity(0.7)),
            onPressed: () => _searchController.clear(),
          ),
        ],
      ),
      body: Container(), // 검색 결과 표시 영역 (비워둠)
    );
  }
}