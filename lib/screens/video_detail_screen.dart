import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models/video_lesson.dart';

class VideoDetailScreen extends StatefulWidget {
  final VideoLesson videoData;
  final int heartCount;
  final Function(int)? onHeartCountChanged;

  const VideoDetailScreen({
    Key? key,
    required this.videoData,
    this.heartCount = 0,
    this.onHeartCountChanged,
  }) : super(key: key);

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late YoutubePlayerController _controller;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  int _currentIndex = -1; // Index của câu đang nói

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoData.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false,
        isLive: false,
        forceHD: false,
      ),
    )..addListener(_videoListener);
  }

  // --- LOGIC ĐỒNG BỘ SUBTITLE ---
  void _videoListener() {
    if (_controller.value.isPlaying && widget.videoData.subtitles.isNotEmpty) {
      final currentSeconds = _controller.value.position.inMilliseconds / 1000;

      // Tìm câu active
      int activeIndex = widget.videoData.subtitles.indexWhere((sub) =>
      currentSeconds >= sub.startSeconds && currentSeconds < sub.endSeconds);

      // Nếu tìm thấy và khác index cũ
      if (activeIndex != -1 && activeIndex != _currentIndex) {
        setState(() {
          _currentIndex = activeIndex;
        });
        // Tự động cuộn danh sách đến câu đang nói
        if (_itemScrollController.isAttached) {
          _itemScrollController.scrollTo(
            index: activeIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.4, // Căn ở khoảng giữa màn hình danh sách
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX LỖI FULLSCREEN: Dùng YoutubePlayerBuilder
    return YoutubePlayerBuilder(
      // 1. Cấu hình Player nằm ở đây
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressColors: const ProgressBarColors(
          playedColor: Colors.pink,
          handleColor: Colors.pinkAccent,
        ),
        onEnded: (metaData) {
          _controller.seekTo(Duration.zero);
          _controller.pause();
          setState(() => _currentIndex = -1);
        },
      ),
      // 2. Giao diện chính của App nằm trong builder
      // `player` ở đây chính là cái YoutubePlayer được pass xuống
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            title: Text(
              widget.videoData.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.favorite, color: Colors.pink, size: 16),
                  const SizedBox(width: 4),
                  Text('${widget.heartCount}',
                      style: const TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ]),
              )
            ],
          ),
          body: Column(
            children: [
              // 1. VIDEO PLAYER (Dùng biến player từ builder)
              // AspectRatio giúp giữ tỷ lệ khung hình khi ở màn hình dọc
              AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              ),

              // 2. CÂU ĐANG NÓI (ACTIVE SENTENCE)
              _buildActiveSentenceBox(),

              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

              // 3. DANH SÁCH CUỘN
              Expanded(
                child: _buildScrollableList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- CÁC WIDGET CON GIỮ NGUYÊN NHƯ CŨ ---

  Widget _buildActiveSentenceBox() {
    if (_currentIndex == -1 || widget.videoData.subtitles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        color: Colors.white,
        child: Column(
          children: [
            Icon(Icons.touch_app, color: Colors.pink[100], size: 30),
            const SizedBox(height: 8),
            const Text(
              "Bấm Play hoặc chọn một câu để bắt đầu",
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final sub = widget.videoData.subtitles[_currentIndex];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        border: Border(
          bottom: BorderSide(color: Colors.pink[100]!, width: 1),
        ),
      ),
      child: Column(
        children: [
          Text(
            sub.textEn,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub.textVi,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Colors.grey[700], height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableList() {
    if (widget.videoData.subtitles.isEmpty) {
      return const Center(child: Text("Không có dữ liệu phụ đề"));
    }

    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      padding: const EdgeInsets.only(bottom: 50),
      itemCount: widget.videoData.subtitles.length,
      itemBuilder: (context, index) {
        final sub = widget.videoData.subtitles[index];
        final isActive = index == _currentIndex;

        return InkWell(
          onTap: () {
            _controller.seekTo(
                Duration(milliseconds: (sub.startSeconds * 1000).toInt()));
            if (!_controller.value.isPlaying) _controller.play();
          },
          child: Container(
            color: isActive ? Colors.pink.withOpacity(0.05) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  child: Icon(
                    isActive ? Icons.bar_chart : Icons.play_arrow_rounded,
                    color: isActive ? Colors.pink : Colors.grey[300],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.textEn,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? Colors.black87 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sub.textVi,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                          isActive ? Colors.grey[700] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}