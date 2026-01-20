import 'package:flutter/material.dart';
import 'dart:math';
import 'quiz/quiz_today_screen.dart';
import '../widgets/video_card.dart';
import 'video_detail_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final int heartCount;
  final int coinCount;
  final Function(int)? onHeartCountChanged;
  final Function(int)? onCoinCountChanged;

  const HomeScreen({
    Key? key,
    this.heartCount = 5,
    this.coinCount = 0,
    this.onHeartCountChanged,
    this.onCoinCountChanged,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showNotice = true;
  List<bool> _videoLikes = [false, false, false, false];
  List<int> _videoLikeCounts = [1, 3, 2, 5];
  List<bool> _snackLikes = List.generate(5, (index) => false);
  List<int> _snackLikeCounts = List.generate(5, (index) => Random().nextInt(10) + 1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleVideoLike(int index) {
    setState(() {
      if (_videoLikes[index]) {
        _videoLikeCounts[index]--;
        widget.onHeartCountChanged?.call(widget.heartCount + 1);
      } else {
        if (widget.heartCount > 0) {
          _videoLikeCounts[index]++;
          _videoLikes[index] = true;
          widget.onHeartCountChanged?.call(widget.heartCount - 1);
          _showLikeAnimation(context);
        } else {
          _showNoHeartsDialog(context);
        }
      }
      _videoLikes[index] = !_videoLikes[index];
    });
  }

  void _toggleSnackLike(int index) {
    setState(() {
      if (_snackLikes[index]) {
        _snackLikeCounts[index]--;
        widget.onHeartCountChanged?.call(widget.heartCount + 1);
      } else {
        if (widget.heartCount > 0) {
          _snackLikeCounts[index]++;
          _snackLikes[index] = true;
          widget.onHeartCountChanged?.call(widget.heartCount - 1);
          _showLikeAnimation(context);
        } else {
          _showNoHeartsDialog(context);
        }
      }
      _snackLikes[index] = !_snackLikes[index];
    });
  }

  void _showLikeAnimation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.pink[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, color: Colors.pink, size: 40),
              const SizedBox(height: 10),
              const Text(
                'Đã thêm vào yêu thích!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Trái tim còn lại: ${widget.heartCount - 1}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  void _showNoHeartsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hết trái tim!'),
        content: const Text('Bạn đã hết trái tim. Hãy hoàn thành quiz để nhận thêm trái tim.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Làm Quiz ngay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.water_drop_outlined, color: Colors.grey, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.coinCount.toString(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Điểm số của bạn'),
                                content: Text('Bạn có ${widget.coinCount} điểm. Hoàn thành bài học để nhận thêm điểm!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.diamond, color: Colors.orange, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  widget.coinCount.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationsScreen(
                                  heartCount: widget.heartCount,
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              const Icon(Icons.notifications_outlined, size: 28),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.pink,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '1',
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  heartCount: widget.heartCount,
                                  coinCount: widget.coinCount,
                                  onHeartCountChanged: widget.onHeartCountChanged,
                                  onCoinCountChanged: widget.onCoinCountChanged,
                                ),
                              ),
                            );
                          },
                          child: const Icon(Icons.person_outline, size: 28),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(Icons.search, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        _tabController.animateTo(0);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Tất cả',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        _tabController.animateTo(1);
                      },
                      child: const Text('Đăng ký', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        _tabController.animateTo(2);
                      },
                      child: Row(
                        children: const [
                          Text('Du lịch', style: TextStyle(fontSize: 16)),
                          Icon(Icons.flight, size: 20, color: Colors.blue),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        _tabController.animateTo(3);
                      },
                      child: const Text('Hoạt h...', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            if (_showNotice)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'notice',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Lần đầu sử dụng Cake? Tìm hiểu cách sử dụng nhanh chóng và dễ dàng ngay tại đ...',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _showNotice = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizTodayScreen(
                      heartCount: widget.heartCount,
                      onHeartCountChanged: widget.onHeartCountChanged,
                      onCoinCountChanged: widget.onCoinCountChanged,
                    )),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(20),
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
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.cake, color: Colors.purple[700], size: 30),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.pink,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.favorite, color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Bắt đầu Quiz hôm nay',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Keira Knightley',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    VideoCard(
                      imageUrl: 'https://picsum.photos/400/300?random=1',
                      likes: _videoLikeCounts[0],
                      isLiked: _videoLikes[0],
                      videoCount: 7,
                      title: '"Tôi vẫn giữ nguyên lập trường đó."',
                      subtitle: 'I\'m ________ to it.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => VideoDetailScreen(
                            heartCount: widget.heartCount,
                            onHeartCountChanged: widget.onHeartCountChanged,
                          )),
                        );
                      },
                      onLikePressed: () => _toggleVideoLike(0),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow, color: Colors.pink, size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            'Snacks',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Snacks PLUS',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text('Nội dung đặc biệt dành cho thành viên PLUS'),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {},
                                        child: const Text('Nâng cấp PLUS'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: const [
                                  Icon(Icons.favorite, color: Colors.pink, size: 24),
                                  Positioned(
                                    bottom: -2,
                                    child: Text(
                                      '5',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Snack Content'),
                                  content: Text('Video snack #${index + 1} - Nội dung đặc biệt'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Đóng'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        widget.onHeartCountChanged?.call(widget.heartCount - 1);
                                        _toggleSnackLike(index);
                                      },
                                      child: const Text('Yêu thích'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      'https://picsum.photos/200/300?random=$index',
                                      width: 140,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.diamond, color: Colors.orange, size: 12),
                                          SizedBox(width: 4),
                                          Text(
                                            'PLUS Only',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _toggleSnackLike(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _snackLikes[index] ? Icons.favorite : Icons.favorite_border,
                                          color: _snackLikes[index] ? Colors.pink : Colors.grey,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  VideoCard(
                    imageUrl: 'https://picsum.photos/400/300?random=10',
                    likes: _videoLikeCounts[1],
                    isLiked: _videoLikes[1],
                    videoCount: 5,
                    title: 'Practice Makes Perfect',
                    subtitle: 'Let\'s ________ English together!',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VideoDetailScreen(
                          heartCount: widget.heartCount,
                          onHeartCountChanged: widget.onHeartCountChanged,
                        )),
                      );
                    },
                    onLikePressed: () => _toggleVideoLike(1),
                  ),
                  const SizedBox(height: 16),
                  VideoCard(
                    imageUrl: 'https://picsum.photos/400/300?random=11',
                    likes: _videoLikeCounts[2],
                    isLiked: _videoLikes[2],
                    videoCount: 8,
                    title: 'Daily Conversation',
                    subtitle: 'How are you ________ today?',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VideoDetailScreen(
                          heartCount: widget.heartCount,
                          onHeartCountChanged: widget.onHeartCountChanged,
                        )),
                      );
                    },
                    onLikePressed: () => _toggleVideoLike(2),
                  ),
                  const SizedBox(height: 16),
                  VideoCard(
                    imageUrl: 'https://picsum.photos/400/300?random=12',
                    likes: _videoLikeCounts[3],
                    isLiked: _videoLikes[3],
                    videoCount: 6,
                    title: 'Business English',
                    subtitle: 'Let\'s ________ a meeting.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VideoDetailScreen(
                          heartCount: widget.heartCount,
                          onHeartCountChanged: widget.onHeartCountChanged,
                        )),
                      );
                    },
                    onLikePressed: () => _toggleVideoLike(3),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}