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

  // Search execution function
  void _performSearch(String query) {
    final trimmedQuery = query.trim(); // Remove leading/trailing spaces
    if (trimmedQuery.isNotEmpty) { // Return result only if search query is not empty
      print('Performing search for: $trimmedQuery');
      // *** Important: pop with the search query as result ***
      Navigator.pop(context, trimmedQuery);
    } else {
      // If search query is empty, do nothing or notify user (optional)
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
          // *** Important: Back button returns null ***
          onPressed: () => Navigator.pop(context), // pop without result
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
          onSubmitted: _performSearch, // Execute search on Enter key
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear, color: colorScheme.onSurface.withValues(alpha: 0.7)),
            onPressed: () => _searchController.clear(),
          ),
        ],
      ),
      body: Container(), // Area to display search results (left empty)
    );
  }
}