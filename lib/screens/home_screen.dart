import 'package:flutter/material.dart';
import 'dart:math';

// Import các màn hình liên quan
import 'quiz/quiz_today_screen.dart';
import 'video_detail_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'LoginScreen.dart'; // <--- 1. NHỚ IMPORT FILE LOGIN CỦA BẠN
import '../widgets/video_card.dart';

class HomeScreen extends StatefulWidget {
  final int heartCount;
  final int coinCount;
  final Function(int)? onHeartCountChanged;
  final Function(int)? onCoinCountChanged;
  final Map<String, dynamic>? userData;

  const HomeScreen({
    Key? key,
    this.heartCount = 5,
    this.coinCount = 0,
    this.userData,
    this.onHeartCountChanged,
    this.onCoinCountChanged,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Tất cả', 'Đăng ký', 'Du lịch', 'Hoạt hình', 'Phim ảnh', 'Âm nhạc'];
  bool _showNotice = true;

  final List<bool> _videoLikes = [false, false, false, false];
  final List<int> _videoLikeCounts = [1, 3, 2, 5];
  final List<bool> _snackLikes = List.generate(5, (index) => false);
  final List<int> _snackLikeCounts = List.generate(5, (index) => Random().nextInt(10) + 1);

  // --- 2. HÀM KIỂM TRA ĐĂNG NHẬP (QUAN TRỌNG) ---
  void _requireLogin(VoidCallback onSuccess) {
    // Kiểm tra userData, nếu null hoặc rỗng tức là chưa đăng nhập
    if (widget.userData != null && widget.userData!.isNotEmpty) {
      onSuccess(); // Đã đăng nhập -> Thực hiện hành động
    } else {
      // Chưa đăng nhập -> Hiện Dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.lock_person_outlined, color: Colors.orange),
              SizedBox(width: 8),
              Text('Yêu cầu đăng nhập'),
            ],
          ),
          content: const Text('Bạn cần đăng nhập để sử dụng tính năng này và lưu lại tiến trình học tập.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0277BD)),
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                // Chuyển hướng sang màn hình đăng nhập
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Đăng nhập ngay', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  // --- Logic Xử lý ---

  void _handleHeartDeduction(VoidCallback onSuccess) {
    if (widget.heartCount > 0) {
      widget.onHeartCountChanged?.call(widget.heartCount - 1);
      _showLikeAnimation(context);
      onSuccess();
    } else {
      _showNoHeartsDialog(context);
    }
  }

  void _toggleVideoLike(int index) {
    // Yêu cầu đăng nhập mới được thả tim
    _requireLogin(() {
      setState(() {
        if (_videoLikes[index]) {
          _videoLikeCounts[index]--;
          widget.onHeartCountChanged?.call(widget.heartCount + 1);
          _videoLikes[index] = false;
        } else {
          _handleHeartDeduction(() {
            _videoLikeCounts[index]++;
            _videoLikes[index] = true;
          });
        }
      });
    });
  }

  void _toggleSnackLike(int index) {
    // Yêu cầu đăng nhập mới được thả tim snack
    _requireLogin(() {
      setState(() {
        if (_snackLikes[index]) {
          _snackLikeCounts[index]--;
          widget.onHeartCountChanged?.call(widget.heartCount + 1);
          _snackLikes[index] = false;
        } else {
          _handleHeartDeduction(() {
            _snackLikeCounts[index]++;
            _snackLikes[index] = true;
          });
        }
      });
    });
  }

  // --- Dialogs & Animations ---

  void _showLikeAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Đã yêu thích!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Tim còn lại: ${widget.heartCount - 1}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (Navigator.canPop(context)) Navigator.pop(context);
    });
  }

  void _showNoHeartsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.broken_image_outlined, color: Colors.grey),
            SizedBox(width: 8),
            Text('Hết trái tim!'),
          ],
        ),
        content: const Text('Bạn cần thêm trái tim để thực hiện hành động này. Hãy làm Quiz để kiếm thêm!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () {
              Navigator.pop(context);
              // Quiz cũng yêu cầu đăng nhập
              _requireLogin(() {
                Navigator.push(context, MaterialPageRoute(builder: (_) => QuizTodayScreen(
                  heartCount: widget.heartCount,
                  onHeartCountChanged: widget.onHeartCountChanged,
                  onCoinCountChanged: widget.onCoinCountChanged,
                )));
              });
            },
            child: const Text('Làm Quiz Ngay', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Widgets con ---

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Coin Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.blueAccent, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${widget.coinCount}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),

          Row(
            children: [
              // Points Badge
              GestureDetector(
                onTap: () { /* Show dialog logic */ },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.orange[100]!, Colors.orange[50]!]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.diamond, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text('${widget.coinCount}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Notification Icon - Yêu cầu Login
              GestureDetector(
                onTap: () => _requireLogin(() {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => NotificationsScreen(heartCount: widget.heartCount),
                  ));
                }),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined, size: 28, color: Colors.black87),
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Profile Icon
              GestureDetector(
                onTap: () {
                  // Profile có thể cho xem kể cả khi chưa login (để thấy nút đăng nhập bên trong)
                  // Hoặc bắt buộc login luôn tuỳ bạn. Ở đây mình cho vào xem luôn.
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      heartCount: widget.heartCount,
                      coinCount: widget.coinCount,
                      userData: widget.userData,
                      onHeartCountChanged: widget.onHeartCountChanged,
                      onCoinCountChanged: widget.onCoinCountChanged,
                    ),
                  ));
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: widget.userData?['avatarUrl'] != null
                      ? NetworkImage(widget.userData!['avatarUrl'])
                      : null,
                  child: widget.userData?['avatarUrl'] == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      color: Colors.white,
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Center(child: Icon(Icons.search, color: Colors.grey));
          }
          final categoryIndex = index - 1;
          final isSelected = _selectedCategoryIndex == categoryIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = categoryIndex),
            child: Chip(
              label: Text(_categories[categoryIndex]),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: isSelected ? Colors.black : Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoticeBanner() {
    if (!_showNotice) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.pink, borderRadius: BorderRadius.circular(8)),
            child: const Text('NOTICE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Lần đầu sử dụng Cake? Tìm hiểu cách sử dụng nhanh chóng...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          InkWell(
            onTap: () => setState(() => _showNotice = false),
            child: const Icon(Icons.close, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard() {
    return GestureDetector(
      onTap: () {
        // Yêu cầu Login mới được làm Quiz
        _requireLogin(() {
          Navigator.push(context, MaterialPageRoute(builder: (_) => QuizTodayScreen(
            heartCount: widget.heartCount,
            onHeartCountChanged: widget.onHeartCountChanged,
            onCoinCountChanged: widget.onCoinCountChanged,
          )));
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.purple[50]!, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.purple[100], borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.cake, color: Colors.purple, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bắt đầu Quiz hôm nay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Kiếm thêm tim và điểm thưởng', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSnacksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.play_circle_fill, color: Colors.pink, size: 24),
              const SizedBox(width: 8),
              const Text('Snacks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.pink[50], borderRadius: BorderRadius.circular(12)),
                child: const Text('Xem thêm', style: TextStyle(color: Colors.pink, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                  image: DecorationImage(
                    image: NetworkImage('https://picsum.photos/200/300?random=$index'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                    ),
                    // Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                        child: const Text('PLUS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // Like button
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleSnackLike(index),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: Icon(
                            _snackLikes[index] ? Icons.favorite : Icons.favorite_border,
                            color: _snackLikes[index] ? Colors.pink : Colors.grey[400],
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),

            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverCategoryHeaderDelegate(child: _buildCategoryBar()),
            ),

            SliverToBoxAdapter(child: _buildNoticeBanner()),
            SliverToBoxAdapter(child: _buildQuizCard()),

            // Section 1: Featured Video
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Dành cho ${widget.userData?['name'] ?? 'bạn'}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverToBoxAdapter(
              child: VideoCard(
                imageUrl: 'https://picsum.photos/400/300?random=1',
                likes: _videoLikeCounts[0],
                isLiked: _videoLikes[0],
                videoCount: 7,
                title: '"Tôi vẫn giữ nguyên lập trường đó."',
                subtitle: 'I\'m ________ to it.',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoDetailScreen(
                  heartCount: widget.heartCount,
                  onHeartCountChanged: widget.onHeartCountChanged,
                ))),
                onLikePressed: () => _toggleVideoLike(0),
              ),
            ),

            // Section 2: Snacks
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _buildSnacksSection()),

            // Section 3: More Videos
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: const Text('Bài học phổ biến', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final realIndex = index + 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: VideoCard(
                      imageUrl: 'https://picsum.photos/400/300?random=${10 + index}',
                      likes: _videoLikeCounts[realIndex],
                      isLiked: _videoLikes[realIndex],
                      videoCount: 5 + index,
                      title: index == 0 ? 'Practice Makes Perfect' : (index == 1 ? 'Daily Conversation' : 'Business English'),
                      subtitle: 'Learn English together!',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoDetailScreen(
                        heartCount: widget.heartCount,
                        onHeartCountChanged: widget.onHeartCountChanged,
                      ))),
                      onLikePressed: () => _toggleVideoLike(realIndex),
                    ),
                  );
                },
                childCount: 3,
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

// Helper class để ghim thanh Category khi cuộn
class _SliverCategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverCategoryHeaderDelegate({required this.child});

  @override
  double get minExtent => 50.0;
  @override
  double get maxExtent => 50.0;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }
  @override
  bool shouldRebuild(covariant _SliverCategoryHeaderDelegate oldDelegate) => false;
}