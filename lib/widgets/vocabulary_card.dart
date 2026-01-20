import 'package:flutter/material.dart';
import '../models/vocabulary_word.dart';
import '../services/tts_service.dart';

class VocabularyCard extends StatefulWidget {
  final VocabularyWord word;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onLearnedToggle;

  const VocabularyCard({
    Key? key,
    required this.word,
    required this.onTap,
    required this.onBookmarkToggle,
    required this.onLearnedToggle,
  }) : super(key: key);

  @override
  State<VocabularyCard> createState() => _VocabularyCardState();
}

class _VocabularyCardState extends State<VocabularyCard> {
  final TtsService _ttsService = TtsService();
  bool _isSpeaking = false;

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _speakWord() async {
    setState(() {
      _isSpeaking = true;
    });

    await _ttsService.speakWord(widget.word.word);

    setState(() {
      _isSpeaking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(widget.word.category),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.word.displayCategory,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getLevelColor(widget.word.level),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.word.level,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.word.word,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _speakWord,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isSpeaking ? Colors.purple[300] : Colors.purple,
                                  shape: BoxShape.circle,
                                ),
                                child: _isSpeaking
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Icon(
                                  Icons.volume_up,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (widget.word.pronunciation.isNotEmpty)
                          Text(
                            widget.word.pronunciation,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '👉 Nhấn nút loa để nghe phát âm',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.purple[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (widget.word.hasTranslatedMeaning && widget.word.translatedMeaning != 'Không thể dịch')
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green[100]!),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.translate, size: 18, color: Colors.green[700]),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.word.translatedMeaning,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (widget.word.meaning.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Nghĩa tiếng Anh:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.word.meaning,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],

                        if (widget.word.hasExample) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.format_quote, size: 16, color: Colors.blue[600]),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ví dụ:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '"${widget.word.example}"',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                if (widget.word.exampleTranslation.isNotEmpty &&
                                    widget.word.exampleTranslation != 'Không thể dịch') ...[
                                  const SizedBox(height: 6),
                                  Divider(color: Colors.blue[200], height: 1),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.word.exampleTranslation,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        if (widget.word.hasSynonyms) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(Icons.swap_horiz, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Đồng nghĩa:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ...widget.word.synonyms.take(3).map((synonym) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[100]!),
                                ),
                                child: Text(
                                  synonym,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ],

                        if (widget.word.hasAntonyms) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(Icons.compare_arrows, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Trái nghĩa:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ...widget.word.antonyms.take(3).map((antonym) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[100]!),
                                ),
                                child: Text(
                                  antonym,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          widget.word.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: widget.word.isBookmarked ? Colors.orange : Colors.grey,
                          size: 26,
                        ),
                        onPressed: widget.onBookmarkToggle,
                      ),
                      IconButton(
                        icon: Icon(
                          widget.word.isLearned ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: widget.word.isLearned ? Colors.green : Colors.grey,
                          size: 26,
                        ),
                        onPressed: widget.onLearnedToggle,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'noun':
        return Colors.purple;
      case 'verb':
        return Colors.blue;
      case 'adjective':
        return Colors.green;
      case 'adverb':
        return Colors.orange;
      case 'pronoun':
        return Colors.pink;
      case 'preposition':
        return Colors.teal;
      case 'conjunction':
        return Colors.brown;
      case 'interjection':
        return Colors.indigo;
      default:
        return Colors.grey[600]!;
    }
  }
}