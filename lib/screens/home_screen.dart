import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ✅ Sửa lại Import cho đúng tên file bạn đang có
import 'quiz/quiz_today_screen.dart';
import 'video_detail_screen.dart';
import 'notifications_screen.dart';
import '../widgets/video_card.dart';
import '../models/video_lesson.dart';

import 'LoginScreen.dart';   // ✅ Tên file viết Hoa như bạn muốn
import 'profile_screen.dart'; // File profile
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

  // Giả lập trạng thái like cho phần Snacks
  final List<bool> _snackLikes = List.generate(5, (index) => false);
  final List<int> _snackLikeCounts = List.generate(5, (index) => Random().nextInt(10) + 1);

  late Future<List<VideoLesson>> _futureVideos;

  @override
  void initState() {
    super.initState();
    _futureVideos = fetchVideos();
  }

  // --- 🔥 HÀM GỌI API (ĐÃ TỐI ƯU) ---
  Future<List<VideoLesson>> fetchVideos() async {
    const String baseUrl = "https://api.buivietquangvinh.xyz/api/v1/videos";
    print("🚀 Đang gọi API tới: $baseUrl");

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': '*/*',
        },
      );

      print("📩 Server trả về Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        print("✅ Đã tải thành công ${body.length} video!");
        return body.map((dynamic item) => VideoLesson.fromJson(item)).toList();
      } else {
        print("❌ Lỗi API Code: ${response.statusCode}");
        throw Exception('Lỗi tải dữ liệu: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ LỖI KẾT NỐI: $e");
      return [];
    }
  }

  // --- LOGIC YÊU CẦU ĐĂNG NHẬP ---
  void _requireLogin(VoidCallback onSuccess) {
    if (widget.userData != null && widget.userData!.isNotEmpty) {
      onSuccess();
    } else {
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
          content: const Text('Bạn cần đăng nhập để sử dụng tính năng này.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0277BD)),
              onPressed: () {
                Navigator.pop(context);
                // ✅ Sửa tên Class: LoginScreen (Viết hoa chữ đầu)
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              child: const Text('Đăng nhập ngay', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  // --- LOGIC TRỪ TIM ---
  void _handleHeartDeduction(VoidCallback onSuccess) {
    if (widget.heartCount > 0) {
      widget.onHeartCountChanged?.call(widget.heartCount - 1);
      _showLikeAnimation(context);
      onSuccess();
    } else {
      _showNoHeartsDialog(context);
    }
  }

  void _toggleSnackLike(int index) {
    _requireLogin(() {
      setState(() {
        if (_snackLikes[index]) {
          _snackLikeCounts[index]--;
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
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    });
  }

  void _showNoHeartsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hết trái tim!'),
        content: const Text('Hãy làm Quiz để kiếm thêm tim nhé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 4 : 2;

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

            // Tiêu đề
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                    'Dành cho ${widget.userData?['fullName'] ?? widget.userData?['name'] ?? 'bạn'}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),

            // Lưới Video
            FutureBuilder<List<VideoLesson>>(
              future: _futureVideos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Center(child: CircularProgressIndicator())
                    ),
                  );
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(child: Center(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text("Không thể tải video.\nVui lòng kiểm tra mạng.", textAlign: TextAlign.center),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _futureVideos = fetchVideos();
                            });
                          },
                          child: const Text("Thử lại"),
                        )
                      ],
                    ),
                  )));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverToBoxAdapter(child: Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Chưa có video nào."),
                  )));
                }

                final videos = snapshot.data!;

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final video = videos[index];
                        String thumb = video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty
                            ? video.thumbnailUrl!
                            : "https://img.youtube.com/vi/${video.youtubeId}/hqdefault.jpg";

                        return VideoCard(
                          imageUrl: thumb,
                          likes: 10 + index * 5,
                          isLiked: false,
                          videoCount: 1,
                          title: video.title,
                          subtitle: "Có phụ đề",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoDetailScreen(
                                  videoData: video,
                                  heartCount: widget.heartCount,
                                  onHeartCountChanged: widget.onHeartCountChanged,
                                ),
                              ),
                            );
                          },
                          onLikePressed: () {
                            _requireLogin(() {
                              _handleHeartDeduction(() {});
                            });
                          },
                        );
                      },
                      childCount: videos.length,
                    ),
                  ),
                );
              },
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _buildSnacksSection()),
            SliverToBoxAdapter(child: const SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON ---
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.blueAccent, size: 18),
                const SizedBox(width: 6),
                Text('${widget.coinCount}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.pink[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.pink[100]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.pink, size: 18),
                    const SizedBox(width: 4),
                    Text('${widget.heartCount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _requireLogin(() {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen(heartCount: widget.heartCount)));
                }),
                child: const Icon(Icons.notifications_outlined, size: 28),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    // ✅ Sửa lỗi chính ở đây: profile_screen -> ProfileScreen (Viết hoa chữ cái đầu)
                    builder: (_) => ProfileScreen(
                      heartCount: widget.heartCount, coinCount: widget.coinCount, userData: widget.userData,
                      onHeartCountChanged: widget.onHeartCountChanged, onCoinCountChanged: widget.onCoinCountChanged,
                    ),
                  ));
                },
                child: CircleAvatar(
                  radius: 16, backgroundColor: Colors.grey[200],
                  backgroundImage: widget.userData?['avatarUrl'] != null ? NetworkImage(widget.userData!['avatarUrl']) : null,
                  child: widget.userData?['avatarUrl'] == null ? const Icon(Icons.person, color: Colors.grey) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ... Các widget còn lại giữ nguyên ...
  Widget _buildCategoryBar() {
    return Container(
      color: Colors.white, height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1, separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) return const Center(child: Icon(Icons.search, color: Colors.grey));
          final categoryIndex = index - 1;
          final isSelected = _selectedCategoryIndex == categoryIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = categoryIndex),
            child: Chip(
              label: Text(_categories[categoryIndex]),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
              backgroundColor: isSelected ? Colors.black : Colors.grey[100],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoticeBanner() {
    if (!_showNotice) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.pink, borderRadius: BorderRadius.circular(8)),
            child: const Text('NOTICE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Chào mừng bạn đến với Vocaboom!', style: TextStyle(fontSize: 13))),
          InkWell(onTap: () => setState(() => _showNotice = false), child: const Icon(Icons.close, size: 18)),
        ],
      ),
    );
  }

  Widget _buildQuizCard() {
    return GestureDetector(
      onTap: () => _requireLogin(() {
        Navigator.push(context, MaterialPageRoute(builder: (_) => QuizTodayScreen(
          heartCount: widget.heartCount, onHeartCountChanged: widget.onHeartCountChanged, onCoinCountChanged: widget.onCoinCountChanged,
        )));
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.purple[50]!, Colors.white]),
          borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purple.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cake, color: Colors.purple, size: 28),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bắt đầu Quiz hôm nay', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Kiếm thêm tim và điểm thưởng', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Snacks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 140, margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), color: Colors.grey[300],
                  image: DecorationImage(image: NetworkImage('https://picsum.photos/200/300?random=$index'), fit: BoxFit.cover),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 8, right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleSnackLike(index),
                        child: CircleAvatar(
                          radius: 14, backgroundColor: Colors.white70,
                          child: Icon(_snackLikes[index] ? Icons.favorite : Icons.favorite_border, size: 16, color: _snackLikes[index] ? Colors.pink : Colors.grey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SliverCategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverCategoryHeaderDelegate({required this.child});
  @override
  double get minExtent => 50.0;
  @override
  double get maxExtent => 50.0;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: Colors.white, child: child);
  @override
  bool shouldRebuild(covariant _SliverCategoryHeaderDelegate oldDelegate) => false;
}