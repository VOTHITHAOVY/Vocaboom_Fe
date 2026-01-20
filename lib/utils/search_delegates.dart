import 'package:flutter/material.dart';

class VideoSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Kết quả tìm kiếm cho: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> suggestions = [
      'English Conversation',
      'Business English',
      'Travel English',
      'Grammar Lessons',
      'Vocabulary Building',
    ];

    final filteredSuggestions = suggestions.where((suggestion) {
      return suggestion.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredSuggestions[index]),
          onTap: () {
            query = filteredSuggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}

class LessonSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Kết quả tìm kiếm bài học: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> suggestions = [
      'Lesson 1: Greetings',
      'Lesson 2: Introductions',
      'Lesson 3: Family',
      'Lesson 4: Food',
      'Lesson 5: Travel',
    ];

    final filteredSuggestions = suggestions.where((suggestion) {
      return suggestion.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredSuggestions[index]),
          onTap: () {
            query = filteredSuggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}