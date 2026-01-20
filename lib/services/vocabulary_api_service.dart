import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vocabulary_word.dart';

class VocabularyApiService {
  static const String _dictionaryUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';
  static const String _translateUrl = 'https://api.mymemory.translated.net/get';

  // 1. TỐI ƯU: Bộ nhớ đệm (Cache) lưu tạm các từ đã tìm để không gọi API lại
  static final Map<String, List<VocabularyWord>> _cache = {};

  Future<List<VocabularyWord>> searchWords(String query) async {
    // Chuẩn hóa từ khóa (viết thường, xóa khoảng trắng thừa)
    final cleanQuery = query.trim().toLowerCase();

    // Kiểm tra Cache trước
    if (_cache.containsKey(cleanQuery)) {
      print('🚀 Lấy từ Cache: "$cleanQuery" (Không tốn mạng)');
      return _cache[cleanQuery]!;
    }

    try {
      print('🔍 Đang tìm từ online: "$cleanQuery"');

      final response = await http.get(
        Uri.parse('$_dictionaryUrl/$cleanQuery'),
      ).timeout(const Duration(seconds: 10));

      print('📡 API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Gọi hàm parse đã được tối ưu song song
        final results = await _parseWithVietnameseTranslation(jsonData, cleanQuery);

        // Lưu vào Cache
        if (results.isNotEmpty) {
          _cache[cleanQuery] = results;
        }

        return results;
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy từ "$query" trong từ điển');
      } else {
        throw Exception('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi tìm kiếm: $e');
      throw Exception('Không thể tìm từ: $e');
    }
  }

  // 2. TỐI ƯU: Chuyển từ xử lý TUẦN TỰ sang SONG SONG (Parallel)
  Future<List<VocabularyWord>> _parseWithVietnameseTranslation(dynamic json, String query) async {
    final List<VocabularyWord> words = [];

    // Danh sách các tác vụ (Tasks) cần chạy song song
    final List<Future<void>> processingTasks = [];

    // Biến đếm để giới hạn số lượng request dịch (tránh bị ban IP)
    int translationCount = 0;
    const int maxTranslations = 5;

    if (json is! List || json.isEmpty) {
      return words;
    }

    for (var entry in json) {
      try {
        final word = entry['word']?.toString() ?? query;
        final phonetics = entry['phonetics'] as List?;
        final meanings = entry['meanings'] as List?;

        // Xử lý phát âm (giữ nguyên logic cũ)
        String pronunciation = '';
        String audioUrl = '';
        if (phonetics != null && phonetics.isNotEmpty) {
          for (var phonetic in phonetics) {
            if (phonetic['text'] != null && pronunciation.isEmpty) pronunciation = phonetic['text'].toString();
            if (phonetic['audio'] != null && audioUrl.isEmpty) audioUrl = phonetic['audio'].toString();
            if (pronunciation.isNotEmpty && audioUrl.isNotEmpty) break;
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
                  // Thay vì await ngay lập tức, ta thêm task vào danh sách để chạy sau
                  bool shouldTranslate = translationCount < maxTranslations;
                  if (shouldTranslate) translationCount++;

                  processingTasks.add(() async {
                    String vietnameseMeaning = 'Đang tải...';
                    String vietnameseExample = '';

                    // Chỉ gọi dịch nếu chưa vượt quá giới hạn (Tối ưu tốc độ)
                    if (shouldTranslate) {
                      // Chạy 2 request dịch song song cùng lúc cho nghĩa và ví dụ
                      final results = await Future.wait([
                        _translateToVietnamese(englishMeaning),
                        englishExample.isNotEmpty ? _translateToVietnamese(englishExample) : Future.value('')
                      ]);
                      vietnameseMeaning = results[0];
                      vietnameseExample = results[1];
                    } else {
                      vietnameseMeaning = englishMeaning; // Fallback nếu quá nhiều từ
                    }

                    final vocabWord = VocabularyWord(
                      id: '${word}_${partOfSpeech}_${words.length}_${DateTime.now().microsecondsSinceEpoch}', // Dùng micro để tránh trùng ID khi chạy nhanh
                      word: word,
                      pronunciation: pronunciation,
                      meaning: englishMeaning,
                      example: englishExample,
                      exampleTranslation: vietnameseExample,
                      category: partOfSpeech,
                      level: _determineLevel(englishMeaning),
                      isBookmarked: false,
                      isLearned: false,
                      audioUrl: audioUrl,
                      synonyms: synonyms,
                      antonyms: antonyms,
                      translatedMeaning: vietnameseMeaning,
                    );

                    // Thêm vào list kết quả (List.add trong Dart event loop là an toàn)
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

    // 3. TỐI ƯU: Chờ tất cả các task chạy xong cùng lúc
    if (processingTasks.isNotEmpty) {
      await Future.wait(processingTasks);
    }

    return words;
  }

  Future<String> _translateToVietnamese(String text) async {
    if (text.isEmpty) return '';
    try {
      final textToTranslate = text.length > 500 ? text.substring(0, 500) : text;

      // Giảm timeout xuống 3s để không làm treo app nếu mạng lag
      final response = await http.get(
        Uri.parse('$_translateUrl?q=${Uri.encodeComponent(textToTranslate)}&langpair=en|vi'),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final translated = jsonData['responseData']?['translatedText']?.toString() ?? text;
        if (translated.contains('[ERROR]') || translated.contains('PLEASE SELECT')) {
          return text; // Trả về text gốc nếu lỗi
        }
        return translated;
      }
    } catch (e) {
      // Slient fail: nếu lỗi dịch thì trả về tiếng Anh luôn cho nhanh
    }
    return text;
  }

  String _determineLevel(String meaning) {
    if (meaning.isEmpty) return 'Intermediate';
    final wordCount = meaning.split(' ').length;
    if (wordCount < 8) return 'Beginner';
    if (wordCount < 15) return 'Intermediate';
    return 'Advanced';
  }

  // Hàm xóa cache nếu cần (ví dụ khi user refresh)
  void clearCache() {
    _cache.clear();
  }
}