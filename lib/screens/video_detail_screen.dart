import 'package:flutter/material.dart';

class VideoDetailScreen extends StatefulWidget {
  final int heartCount;
  final Function(int)? onHeartCountChanged;

  const VideoDetailScreen({
    Key? key,
    required this.heartCount,
    this.onHeartCountChanged,
  }) : super(key: key);

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  bool _isPlaying = false;
  bool _isBookmarked = false;
  bool _isLiked = false;
  int _likeCount = 3;
  double _playbackPosition = 0.3;

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likeCount--;
        widget.onHeartCountChanged?.call(widget.heartCount + 1);
      } else {
        if (widget.heartCount > 0) {
          _likeCount++;
          _isLiked = true;
          widget.onHeartCountChanged?.call(widget.heartCount - 1);
        }
      }
      _isLiked = !_isLiked;
    });
  }

  void _seekForward() {
    setState(() {
      _playbackPosition = (_playbackPosition + 0.1).clamp(0.0, 1.0);
    });
  }

  void _seekBackward() {
    setState(() {
      _playbackPosition = (_playbackPosition - 0.1).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Image.network(
                      'https://picsum.photos/800/600?random=20',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
                            onPressed: _toggleBookmark,
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Chia sẻ video'),
                                  content: const Text('Chia sẻ video này với bạn bè!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: _togglePlayback,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 50),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'I\'m still sticking to it.',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tôi vẫn giữ nguyên lập trường đó.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 20,
                    right: 20,
                    child: GestureDetector(
                      onTapDown: (details) {
                        final width = MediaQuery.of(context).size.width - 40;
                        final tapPosition = details.localPosition.dx;
                        setState(() {
                          _playbackPosition = (tapPosition / width).clamp(0.0, 1.0);
                        });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _playbackPosition,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                          minHeight: 4,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(_playbackPosition * 45).floor()}:00',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_10, color: Colors.white),
                              onPressed: _seekBackward,
                            ),
                            IconButton(
                              icon: const Icon(Icons.forward_10, color: Colors.white),
                              onPressed: _seekForward,
                            ),
                          ],
                        ),
                        const Text(
                          '0:45',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'stick to',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'giữ nguyên, kiên trì',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.purple),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Phát âm'),
                              content: const Text('Phát âm từ "stick to"...'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? Colors.pink : Colors.grey),
                        onPressed: _toggleLike,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Các video liên quan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoDetailScreen(
                                  heartCount: widget.heartCount,
                                  onHeartCountChanged: widget.onHeartCountChanged,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage('https://picsum.photos/200/150?random=${index + 30}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: const Align(
                                alignment: Alignment.center,
                                child: Icon(Icons.play_circle_outline, color: Colors.white, size: 40),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}