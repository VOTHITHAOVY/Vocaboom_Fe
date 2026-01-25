import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart'; // ✅ Dùng thư viện chuẩn này
import '../models/vocabulary_word.dart';

class VocabularyApiService {
  static const String _dictionaryUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  // Khởi tạo đối tượng dịch từ thư viện translator
  final _translator = GoogleTranslator();

  // Cache lưu trữ kết quả để tìm kiếm lần 2 siêu nhanh (0ms)
  static final Map<String, List<VocabularyWord>> _cache = {};

  /// Hàm tìm kiếm chính
  Future<List<VocabularyWord>> searchWords(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    // 1. TỐI ƯU: Kiểm tra Cache trước
    if (_cache.containsKey(cleanQuery)) {
      print('🚀 Lấy từ Cache (Không tốn mạng): "$cleanQuery"');
      return _cache[cleanQuery]!;
    }

    try {
      print('🔍 Đang tìm từ online: "$cleanQuery"');

      // 2. Gọi API Từ điển Anh-Anh
      final response = await http.get(
        Uri.parse('$_dictionaryUrl/$cleanQuery'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // 3. Xử lý dữ liệu và Dịch song song (Anh -> Việt)
        final results = await _parseWithVietnameseTranslation(jsonData, cleanQuery);

        // Lưu vào Cache cho lần sau
        if (results.isNotEmpty) {
          _cache[cleanQuery] = results;
        }
        return results;

      } else if (response.statusCode == 404) {
        // Fallback: Nếu từ điển Anh-Anh không có, dịch thẳng từ khóa đó
        final fallbackTranslation = await _safeTranslate(cleanQuery);

        if (fallbackTranslation.toLowerCase() != cleanQuery) {
          return [VocabularyWord(
            id: DateTime.now().toString(),
            word: query,
            pronunciation: '',
            meaning: fallbackTranslation, // Nghĩa tiếng Việt
            example: 'Không có ví dụ',
            exampleTranslation: '',
            category: 'General',
            level: 'Beginner',
            isBookmarked: false,
            isLearned: false,
            translatedMeaning: fallbackTranslation,
          )];
        }
        return [];
      } else {
        throw Exception('Lỗi API Dictionary: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi tìm kiếm: $e');
      return [];
    }
  }

  /// Hàm xử lý JSON và dịch Anh-Việt song song
  Future<List<VocabularyWord>> _parseWithVietnameseTranslation(dynamic json, String query) async {
    final List<VocabularyWord> words = [];
    final List<Future<void>> processingTasks = [];

    // TỐI ƯU: Chỉ dịch 3 định nghĩa đầu tiên để app chạy nhanh
    int translationCount = 0;
    const int maxTranslations = 3;

    if (json is! List || json.isEmpty) return words;

    for (var entry in json) {
      try {
        final word = entry['word']?.toString() ?? query;
        final phonetics = entry['phonetics'] as List?;
        final meanings = entry['meanings'] as List?;

        // Lấy phát âm và audio
        String pronunciation = '';
        String audioUrl = '';
        if (phonetics != null) {
          for (var item in phonetics) {
            if (item['text'] != null && pronunciation.isEmpty) pronunciation = item['text'];
            if (item['audio'] != null && item['audio'].toString().isNotEmpty) {
              audioUrl = item['audio'];
            }
          }
        }

        if (meanings != null) {
          for (var meaningEntry in meanings) {
            final partOfSpeech = meaningEntry['partOfSpeech']?.toString() ?? 'unknown';
            final definitions = meaningEntry['definitions'] as List?;
            final synonyms = (meaningEntry['synonyms'] as List?)?.map((s) => s.toString()).toList() ?? [];
            final antonyms = (meaningEntry['antonyms'] as List?)?.map((a) => a.toString()).toList() ?? [];

            if (definitions != null) {
              for (var definition in definitions) {
                final englishMeaning = definition['definition']?.toString() ?? '';
                final englishExample = definition['example']?.toString() ?? '';

                if (englishMeaning.isNotEmpty) {
                  bool shouldTranslate = translationCount < maxTranslations;
                  if (shouldTranslate) translationCount++;

                  // TỐI ƯU: Đẩy việc dịch vào luồng xử lý song song (không chặn UI)
                  processingTasks.add(() async {
                    String vietnameseMeaning = englishMeaning;
                    String vietnameseExample = '';

                    if (shouldTranslate) {
                      // Dịch nghĩa Anh -> Việt
                      vietnameseMeaning = await _safeTranslate(englishMeaning);

                      // Dịch ví dụ Anh -> Việt (nếu có)
                      if (englishExample.isNotEmpty) {
                        vietnameseExample = await _safeTranslate(englishExample);
                      }
                    }

                    final vocabWord = VocabularyWord(
                      id: '${word}_${words.length}_${DateTime.now().microsecondsSinceEpoch}',
                      word: word,
                      pronunciation: pronunciation,
                      meaning: englishMeaning,          // Nghĩa gốc (Anh)
                      translatedMeaning: vietnameseMeaning, // Nghĩa dịch (Việt)
                      example: englishExample,          // Ví dụ gốc (Anh)
                      exampleTranslation: vietnameseExample, // Ví dụ dịch (Việt)
                      category: partOfSpeech,
                      level: _determineLevel(englishMeaning),
                      isBookmarked: false,
                      isLearned: false,
                      audioUrl: audioUrl,
                      synonyms: synonyms,
                      antonyms: antonyms,
                    );

                    words.add(vocabWord);
                  }());
                }
              }
            }
          }
        }
      } catch (e) {
        print('⚠️ Lỗi parse entry: $e');
        continue;
      }
    }

    // Đợi tất cả các luồng dịch hoàn tất trước khi trả kết quả
    if (processingTasks.isNotEmpty) {
      await Future.wait(processingTasks);
    }

    return words;
  }

  /// Hàm dịch an toàn sử dụng thư viện translator
  Future<String> _safeTranslate(String text) async {
    if (text.isEmpty) return '';
    try {
      // Dịch từ tiếng Anh (en) sang tiếng Việt (vi)
      var translation = await _translator.translate(text, from: 'en', to: 'vi');
      return translation.text;
    } catch (e) {
      print('❌ Lỗi dịch thuật: $e');
      return text; // Nếu lỗi mạng thì trả về text gốc
    }
  }

  String _determineLevel(String meaning) {
    if (meaning.isEmpty) return 'Intermediate';
    final wordCount = meaning.split(' ').length;
    if (wordCount < 8) return 'Beginner';
    if (wordCount < 15) return 'Intermediate';
    return 'Advanced';
  }

  void clearCache() {
    _cache.clear();
  }
}