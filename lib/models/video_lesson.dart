class Subtitle {
  final double startSeconds;
  final double endSeconds;
  final String textEn;
  final String textVi;

  Subtitle({
    required this.startSeconds,
    required this.endSeconds,
    required this.textEn,
    required this.textVi,
  });

  factory Subtitle.fromJson(Map<String, dynamic> json) {
    return Subtitle(
      startSeconds: (json['startSeconds'] ?? 0).toDouble(),
      endSeconds: (json['endSeconds'] ?? 0).toDouble(),
      textEn: json['textEn'] ?? '',
      textVi: json['textVi'] ?? '',
    );
  }
}

class VideoLesson {
  final int id;
  final String title;
  final String youtubeId;
  final String thumbnailUrl;
  final List<Subtitle> subtitles;

  VideoLesson({
    required this.id,
    required this.title,
    required this.youtubeId,
    required this.thumbnailUrl,
    required this.subtitles,
  });

  factory VideoLesson.fromJson(Map<String, dynamic> json) {
    // 1. Xử lý danh sách phụ đề trước
    var list = json['subtitles'] as List? ?? [];
    List<Subtitle> subtitleList = list.map((i) => Subtitle.fromJson(i)).toList();

    // 2. Trả về đối tượng VideoLesson đầy đủ
    return VideoLesson(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title', // Đã sửa lỗi thiếu dấu nháy ở đây
      youtubeId: json['youtubeId'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      subtitles: subtitleList,
    );
  }
}