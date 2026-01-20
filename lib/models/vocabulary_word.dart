class VocabularyWord {
  final String id;
  final String word;
  final String pronunciation;
  final String meaning;
  final String example;
  final String exampleTranslation;
  final String category;
  final String level;
  final bool isBookmarked;
  final bool isLearned;
  final String audioUrl;
  final List<String> synonyms;
  final List<String> antonyms;
  final String translatedMeaning;

  VocabularyWord({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.meaning,
    required this.example,
    required this.exampleTranslation,
    required this.category,
    required this.level,
    required this.isBookmarked,
    required this.isLearned,
    this.audioUrl = '',
    this.synonyms = const [],
    this.antonyms = const [],
    this.translatedMeaning = '',
  });

  VocabularyWord copyWith({
    String? id,
    String? word,
    String? pronunciation,
    String? meaning,
    String? example,
    String? exampleTranslation,
    String? category,
    String? level,
    bool? isBookmarked,
    bool? isLearned,
    String? audioUrl,
    List<String>? synonyms,
    List<String>? antonyms,
    String? translatedMeaning,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      word: word ?? this.word,
      pronunciation: pronunciation ?? this.pronunciation,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      category: category ?? this.category,
      level: level ?? this.level,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLearned: isLearned ?? this.isLearned,
      audioUrl: audioUrl ?? this.audioUrl,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      translatedMeaning: translatedMeaning ?? this.translatedMeaning,
    );
  }

  String get displayCategory {
    const categoryMap = {
      'noun': 'Danh từ',
      'verb': 'Động từ',
      'adjective': 'Tính từ',
      'adverb': 'Trạng từ',
      'pronoun': 'Đại từ',
      'preposition': 'Giới từ',
      'conjunction': 'Liên từ',
      'interjection': 'Thán từ',
    };
    return categoryMap[category.toLowerCase()] ?? category;
  }

  bool get hasAudio => audioUrl.isNotEmpty;
  bool get hasExample => example.isNotEmpty;
  bool get hasSynonyms => synonyms.isNotEmpty;
  bool get hasAntonyms => antonyms.isNotEmpty;
  bool get hasTranslatedMeaning => translatedMeaning.isNotEmpty;
}