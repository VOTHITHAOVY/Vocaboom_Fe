import 'package:flutter/material.dart';
import '../models/vocabulary_word.dart';
import '../services/tts_service.dart';

class VocabularyDetailSheet extends StatefulWidget {
  final VocabularyWord word;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleLearned;

  const VocabularyDetailSheet({
    Key? key,
    required this.word,
    required this.onToggleBookmark,
    required this.onToggleLearned,
  }) : super(key: key);

  @override
  State<VocabularyDetailSheet> createState() => _VocabularyDetailSheetState();
}

class _VocabularyDetailSheetState extends State<VocabularyDetailSheet> {
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              fontSize: 12,
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      widget.word.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: widget.word.isBookmarked ? Colors.orange : Colors.grey,
                      size: 28,
                    ),
                    onPressed: widget.onToggleBookmark,
                  ),
                  IconButton(
                    icon: Icon(
                      widget.word.isLearned ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: widget.word.isLearned ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                    onPressed: widget.onToggleLearned,
                  ),
                ],
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: Text(
                  widget.word.word,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _speakWord,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isSpeaking ? Colors.purple[300] : Colors.purple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _isSpeaking
                      ? const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                  )
                      : const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),

          if (widget.word.pronunciation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Row(
                children: [
                  Text(
                    widget.word.pronunciation,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '👆 Nhấn loa để nghe',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          if (widget.word.hasTranslatedMeaning && widget.word.translatedMeaning != 'Không thể dịch') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.translate, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Nghĩa tiếng Việt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.word.translatedMeaning,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          const Text(
            'Nghĩa tiếng Anh:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.word.meaning,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          if (widget.word.hasExample) ...[
            const Text(
              'Ví dụ:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.word.example,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (widget.word.exampleTranslation.isNotEmpty && widget.word.exampleTranslation != 'Không thể dịch') ...[
                    const SizedBox(height: 8),
                    Divider(color: Colors.blue[300]),
                    const SizedBox(height: 8),
                    Text(
                      widget.word.exampleTranslation,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          Row(
            children: [
              if (widget.word.hasSynonyms)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Từ đồng nghĩa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          children: widget.word.synonyms.take(5).map((synonym) => Chip(
                            label: Text(synonym),
                            backgroundColor: Colors.blue[100],
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              if (widget.word.hasSynonyms && widget.word.hasAntonyms) const SizedBox(width: 12),
              if (widget.word.hasAntonyms)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Từ trái nghĩa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          children: widget.word.antonyms.take(5).map((antonym) => Chip(
                            label: Text(antonym),
                            backgroundColor: Colors.red[100],
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Đóng', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
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