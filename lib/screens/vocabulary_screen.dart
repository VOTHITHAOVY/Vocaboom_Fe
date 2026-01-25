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
  // Khởi tạo Service
  final VocabularyApiService _apiService = VocabularyApiService();

  // Dữ liệu mẫu (Local - Giả lập Database)
  final List<VocabularyWord> _localWords = [
    VocabularyWord(
      id: '1',
      word: 'stick to',
      pronunciation: '/stɪk tuː/',
      meaning: 'to continue doing something despite difficulties',
      translatedMeaning: 'giữ nguyên, kiên trì',
      example: 'I\'m sticking to my decision.',
      exampleTranslation: 'Tôi vẫn giữ nguyên quyết định của mình.',
      category: 'Phrasal Verb',
      level: 'Intermediate',
      isBookmarked: false,
      isLearned: false,
    ),
    VocabularyWord(
      id: '2',
      word: 'perseverance',
      pronunciation: '/ˌpɜːrsəˈvɪrəns/',
      meaning: 'continued effort to do or achieve something',
      translatedMeaning: 'sự kiên trì',
      example: 'Success requires perseverance.',
      exampleTranslation: 'Thành công đòi hỏi sự kiên trì.',
      category: 'Noun',
      level: 'Advanced',
      isBookmarked: true,
      isLearned: true,
    ),
  ];

  List<VocabularyWord> _filteredWords = [];
  final List<VocabularyWord> _apiWords = [];
  final TextEditingController _searchController = TextEditingController();

  // Debounce Timer để chống spam API
  Timer? _debounceTimer;

  bool _isSearching = false;
  bool _showApiResults = false;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: All, 1: Bookmarked, 2: Learned, 3: Not Learned

  // Cờ ưu tiên hiển thị tiếng Việt
  bool _preferVietnamese = true;

  @override
  void initState() {
    super.initState();
    _filteredWords = _localWords;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // --- LOGIC TÌM KIẾM ---
  void _onSearchChanged() {
    // Hủy timer cũ nếu người dùng đang gõ tiếp
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // Đợi 600ms mới bắt đầu tìm (khớp với logic bên Service)
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      final query = _searchController.text.trim().toLowerCase();

      setState(() {
        _searchQuery = query;
      });

      if (query.isEmpty) {
        // Nếu ô tìm kiếm rỗng -> Hiện từ vựng Local
        _showLocalWords();
      } else {
        // Có chữ -> Gọi API tìm kiếm
        _searchFromApi(query);
      }
    });
  }

  void _showLocalWords() {
    setState(() {
      _showApiResults = false;
      _apiWords.clear();
      _filterWords(); // Áp dụng bộ lọc cho local list
    });
  }

  Future<void> _searchFromApi(String query) async {
    setState(() {
      _isSearching = true;
      _showApiResults = true; // Chuyển sang chế độ hiển thị kết quả online
    });

    try {
      // Gọi Service (đã tối ưu hóa với Cache và Google Translator)
      final results = await _apiService.searchWords(query);

      if (mounted) {
        setState(() {
          _apiWords.clear();
          _apiWords.addAll(results);
          _filteredWords = _apiWords; // Hiển thị trực tiếp kết quả API
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _apiWords.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Lỗi kết nối: $e'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _filterWords() {
    // Nếu đang xem kết quả Online thì không lọc bookmark/learned
    if (_showApiResults) {
      setState(() => _filteredWords = _apiWords);
      return;
    }

    // Logic lọc cho Local Words
    List<VocabularyWord> filtered = _localWords;

    // Lọc theo từ khóa (trong local)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((word) {
        return word.word.toLowerCase().contains(_searchQuery) ||
            (word.translatedMeaning?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Lọc theo Tab (All/Saved/Learned)
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

  // --- LOGIC TƯƠNG TÁC ---
  void _toggleBookmark(String wordId) {
    setState(() {
      final listToUpdate = _showApiResults ? _apiWords : _localWords;
      final index = listToUpdate.indexWhere((word) => word.id == wordId);

      if (index != -1) {
        listToUpdate[index] = listToUpdate[index].copyWith(
            isBookmarked: !listToUpdate[index].isBookmarked
        );

        // Nếu đang ở Local và ở tab Bookmark, cần refresh list
        if (!_showApiResults) _filterWords();
      }
    });
  }

  void _toggleLearned(String wordId) {
    setState(() {
      final listToUpdate = _showApiResults ? _apiWords : _localWords;
      final index = listToUpdate.indexWhere((word) => word.id == wordId);

      if (index != -1) {
        listToUpdate[index] = listToUpdate[index].copyWith(
            isLearned: !listToUpdate[index].isLearned
        );
        if (!_showApiResults) _filterWords();
      }
    });
  }

  void _showWordDetail(VocabularyWord word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Để thấy bo góc
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tùy chỉnh hiển thị', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            const Text('Bộ lọc từ vựng', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _buildFilterChip('Tất cả', 0),
                _buildFilterChip('Đã lưu', 1),
                _buildFilterChip('Đã học', 2),
                _buildFilterChip('Chưa học', 3),
              ],
            ),

            const Divider(height: 30),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Ưu tiên Tiếng Việt", style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text("Hiển thị nghĩa dịch ở màn hình danh sách"),
              value: _preferVietnamese,
              activeColor: Colors.purple,
              onChanged: (val) {
                setState(() => _preferVietnamese = val);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
        Navigator.pop(context);
        _filterWords();
      },
      selectedColor: Colors.purple.shade100,
      labelStyle: TextStyle(
          color: isSelected ? Colors.purple.shade900 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      ),
    );
  }

  void _searchRandomWord() {
    final words = ['serendipity', 'ephemeral', 'eloquence', 'resilience', 'wanderlust', 'tranquility'];
    final randomWord = words[DateTime.now().millisecondsSinceEpoch % words.length];
    _searchController.text = randomWord;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền nhẹ nhàng
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Từ vựng',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),

                      // Nút đổi ngôn ngữ nhanh
                      InkWell(
                        onTap: () {
                          setState(() => _preferVietnamese = !_preferVietnamese);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(_preferVietnamese ? "Đã chuyển sang Tiếng Việt" : "Đã chuyển sang Tiếng Anh"),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.purple.shade800,
                          ));
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _preferVietnamese ? Colors.purple.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _preferVietnamese ? Colors.purple.shade200 : Colors.grey.shade300
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                _preferVietnamese ? 'assets/flags/vn.png' : 'assets/flags/uk.png', // Nếu không có ảnh thì dùng Text bên dưới
                                width: 20,
                                height: 20,
                                errorBuilder: (c,e,s) => Icon(Icons.language, size: 18, color: _preferVietnamese ? Colors.purple : Colors.grey),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _preferVietnamese ? "VI" : "EN",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _preferVietnamese ? Colors.purple.shade700 : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    _showApiResults
                        ? 'Kết quả Online cho "$_searchQuery"'
                        : 'Kho từ vựng cá nhân (${_localWords.length} từ)',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // --- SEARCH BAR SECTION ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Nhập từ cần tra...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          prefixIcon: _isSearching
                              ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.purple.shade300)
                            ),
                          )
                              : Icon(Icons.search, color: Colors.purple.shade300),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
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

                  // Filter Button
                  InkWell(
                    onTap: _showFilterBottomSheet,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTENT LIST ---
            Expanded(
              child: _isSearching
              // 1. Loading State
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.purple),
                    const SizedBox(height: 20),
                    Text(
                      'Đang tìm "$_searchQuery"...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
              // 2. Empty State
                  : _filteredWords.isEmpty
                  ? Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _showApiResults ? Icons.search_off_rounded : Icons.library_books_rounded,
                          size: 60,
                          color: Colors.purple.shade200,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _showApiResults
                            ? 'Không tìm thấy từ này'
                            : 'Bạn chưa có từ vựng nào',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _showApiResults
                            ? 'Hãy thử kiểm tra lại chính tả xem sao'
                            : 'Hãy bắt đầu tra cứu và lưu từ mới nhé!',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      if (!_showApiResults) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _searchRandomWord,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Gợi ý từ ngẫu nhiên'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              )
              // 3. List Data
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _filteredWords.length,
                itemBuilder: (context, index) {
                  final word = _filteredWords[index];

                  // LOGIC HIỂN THỊ ĐA NGÔN NGỮ:
                  // Kiểm tra xem có bản dịch tiếng Việt chưa
                  final hasVietnamese = word.translatedMeaning != null && word.translatedMeaning!.isNotEmpty;

                  // Quyết định hiển thị:
                  // Nếu user thích Tiếng Việt + Có bản dịch -> Hiện Tiếng Việt
                  // Ngược lại -> Hiện Tiếng Anh
                  final displayMeaning = (_preferVietnamese && hasVietnamese)
                      ? word.translatedMeaning!
                      : word.meaning;

                  // Tương tự với ví dụ
                  final displayExample = (_preferVietnamese && word.exampleTranslation != null && word.exampleTranslation!.isNotEmpty)
                      ? word.exampleTranslation!
                      : word.example;

                  // Tạo object hiển thị (Adapter pattern)
                  final displayWord = word.copyWith(
                    meaning: displayMeaning,
                    example: displayExample,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: VocabularyCard(
                      word: displayWord,
                      onTap: () => _showWordDetail(word), // Truyền word gốc vào chi tiết
                      onBookmarkToggle: () => _toggleBookmark(word.id),
                      onLearnedToggle: () => _toggleLearned(word.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Nút Floating Action Button chỉ hiện khi ở màn hình Local
      floatingActionButton: !_showApiResults && _filteredWords.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _searchRandomWord,
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.shuffle, color: Colors.white),
        label: const Text("Khám phá", style: TextStyle(color: Colors.white)),
      )
          : null,
    );
  }
}