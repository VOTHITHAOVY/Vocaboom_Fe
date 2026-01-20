import 'dart:async';
import 'package:flutter/material.dart';
import '../models/vocabulary_word.dart';
import '../widgets/vocabulary_card.dart';
import '../widgets/vocabulary_detail_sheet.dart';
import '../services/vocabulary_api_service.dart';

class VocabularyScreen extends StatefulWidget {
  final int heartCount;
  final Function(int)? onHeartCountChanged;

  const VocabularyScreen({
    Key? key,
    required this.heartCount,
    this.onHeartCountChanged,
  }) : super(key: key);

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final VocabularyApiService _apiService = VocabularyApiService();
  final List<VocabularyWord> _localWords = [
    VocabularyWord(
      id: '1',
      word: 'stick to',
      pronunciation: '/stɪk tuː/',
      meaning: 'giữ nguyên, kiên trì',
      example: 'I\'m sticking to my decision.',
      exampleTranslation: 'Tôi vẫn giữ nguyên quyết định của mình.',
      category: 'Phrasal Verb',
      level: 'Intermediate',
      isBookmarked: false,
      isLearned: false,
      translatedMeaning: 'giữ nguyên, kiên trì',
    ),
    VocabularyWord(
      id: '2',
      word: 'perseverance',
      pronunciation: '/ˌpɜːrsəˈvɪrəns/',
      meaning: 'sự kiên trì',
      example: 'Success requires perseverance.',
      exampleTranslation: 'Thành công đòi hỏi sự kiên trì.',
      category: 'Noun',
      level: 'Advanced',
      isBookmarked: true,
      isLearned: true,
      translatedMeaning: 'sự kiên trì',
    ),
  ];

  List<VocabularyWord> _filteredWords = [];
  final List<VocabularyWord> _apiWords = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isSearching = false;
  bool _showApiResults = false;
  String _searchQuery = '';
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _filteredWords = _localWords;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim().toLowerCase();

      setState(() {
        _searchQuery = query;
      });

      if (query.isEmpty) {
        _showLocalWords();
      } else if (query.length >= 2) {
        _searchFromApi(query);
      } else {
        _searchLocal(query);
      }
    });
  }

  void _showLocalWords() {
    setState(() {
      _showApiResults = false;
      _filterWords();
    });
  }

  void _searchLocal(String query) {
    final filtered = _localWords.where((word) {
      return word.word.toLowerCase().contains(query) ||
          word.meaning.toLowerCase().contains(query) ||
          word.example.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _showApiResults = false;
      _filteredWords = filtered;
    });
  }

  Future<void> _searchFromApi(String query) async {
    setState(() {
      _isSearching = true;
      _apiWords.clear();
    });

    try {
      final results = await _apiService.searchWords(query);

      setState(() {
        _apiWords.addAll(results);
        _showApiResults = true;
        _filteredWords = _apiWords;
        _isSearching = false;
      });

      if (results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Tìm thấy ${results.length} nghĩa cho "$query"'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _filterWords() {
    List<VocabularyWord> source = _showApiResults ? _apiWords : _localWords;
    List<VocabularyWord> filtered = source;

    if (_searchQuery.isNotEmpty && !_showApiResults) {
      filtered = filtered.where((word) {
        return word.word.toLowerCase().contains(_searchQuery) ||
            word.meaning.toLowerCase().contains(_searchQuery) ||
            word.example.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    switch (_selectedFilter) {
      case 1:
        filtered = filtered.where((word) => word.isBookmarked).toList();
        break;
      case 2:
        filtered = filtered.where((word) => word.isLearned).toList();
        break;
      case 3:
        filtered = filtered.where((word) => !word.isLearned).toList();
        break;
    }

    setState(() {
      _filteredWords = filtered;
    });
  }

  void _toggleBookmark(String wordId) {
    setState(() {
      if (_showApiResults) {
        final index = _apiWords.indexWhere((word) => word.id == wordId);
        if (index != -1) {
          _apiWords[index] = _apiWords[index].copyWith(
            isBookmarked: !_apiWords[index].isBookmarked,
          );
        }
      } else {
        final index = _localWords.indexWhere((word) => word.id == wordId);
        if (index != -1) {
          _localWords[index] = _localWords[index].copyWith(
            isBookmarked: !_localWords[index].isBookmarked,
          );
        }
      }
      _filterWords();
    });
  }

  void _toggleLearned(String wordId) {
    setState(() {
      if (_showApiResults) {
        final index = _apiWords.indexWhere((word) => word.id == wordId);
        if (index != -1) {
          _apiWords[index] = _apiWords[index].copyWith(
            isLearned: !_apiWords[index].isLearned,
          );
        }
      } else {
        final index = _localWords.indexWhere((word) => word.id == wordId);
        if (index != -1) {
          _localWords[index] = _localWords[index].copyWith(
            isLearned: !_localWords[index].isLearned,
          );
        }
      }
      _filterWords();
    });
  }

  void _showWordDetail(VocabularyWord word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => VocabularyDetailSheet(
        word: word,
        onToggleBookmark: () => _toggleBookmark(word.id),
        onToggleLearned: () => _toggleLearned(word.id),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bộ lọc',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('Tất cả', 0),
            _buildFilterOption('Đã đánh dấu', 1),
            _buildFilterOption('Đã học', 2),
            _buildFilterOption('Chưa học', 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Áp dụng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String text, int value) {
    return ListTile(
      title: Text(text),
      trailing: _selectedFilter == value
          ? const Icon(Icons.check, color: Colors.purple)
          : null,
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        Navigator.pop(context);
        _filterWords();
      },
    );
  }

  void _showWordOfTheDay() async {
    final words = ['hello', 'learn', 'english', 'practice', 'improve', 'study'];
    final randomWord = words[DateTime.now().millisecondsSinceEpoch % words.length];

    _searchController.text = randomWord;
    await _searchFromApi(randomWord);
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkedCount = _localWords.where((word) => word.isBookmarked).length;
    final learnedCount = _localWords.where((word) => word.isLearned).length;
    final totalWords = _localWords.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Từ vựng',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          if (_showApiResults)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.cloud, color: Colors.blue[700], size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Từ điển Online',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Thống kê'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildStatItem('Từ vựng local', '$totalWords từ', Icons.library_books),
                                      const SizedBox(height: 10),
                                      _buildStatItem('Đã học', '$learnedCount từ', Icons.check_circle),
                                      const SizedBox(height: 10),
                                      _buildStatItem('Đã đánh dấu', '$bookmarkedCount từ', Icons.bookmark),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Đóng'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.insights, color: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showApiResults
                        ? 'Kết quả từ điển cho "$_searchQuery"'
                        : 'Học và ôn tập từ vựng mỗi ngày',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm từ vựng (gõ ít nhất 2 ký tự)...',
                          border: InputBorder.none,
                          prefixIcon: _isSearching
                              ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                              : const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _showLocalWords();
                            },
                          )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('Tổng số', '$totalWords', Colors.blue),
                  _buildMiniStat('Đã học', '$learnedCount', Colors.green),
                  _buildMiniStat('Đánh dấu', '$bookmarkedCount', Colors.orange),
                  _buildMiniStat('API', _apiWords.length.toString(), Colors.purple),
                ],
              ),
            ),
            Expanded(
              child: _isSearching
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đang tìm kiếm "$_searchQuery"...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
                  : _filteredWords.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showApiResults
                          ? 'Không tìm thấy từ "$_searchQuery"'
                          : 'Không tìm thấy từ vựng nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!_showApiResults && _searchQuery.isEmpty)
                      ElevatedButton(
                        onPressed: _showWordOfTheDay,
                        child: const Text('Tìm từ ngẫu nhiên'),
                      ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredWords.length,
                itemBuilder: (context, index) {
                  final word = _filteredWords[index];
                  return VocabularyCard(
                    word: word,
                    onTap: () => _showWordDetail(word),
                    onBookmarkToggle: () => _toggleBookmark(word.id),
                    onLearnedToggle: () => _toggleLearned(word.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showWordOfTheDay,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 14)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}