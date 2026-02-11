import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 1. Import cái này để chỉnh full màn hình
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 👉 2. ẨN thanh trạng thái (Pin, Sóng) & Thanh điều hướng dưới đáy
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Cấu hình hiệu ứng Fade in
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Đợi 3 giây rồi chuyển trang
    Future.delayed(const Duration(seconds: 3), () {
      // 👉 3. HIỆN LẠI thanh trạng thái trước khi sang màn hình mới
      // Nếu không có dòng này, sang màn hình Welcome nó vẫn bị mất thanh pin/sóng
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    // Phòng hờ: Đảm bảo khi tắt widget này thì hiện lại UI hệ thống
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để đảm bảo ảnh scale đúng
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // --- 1. ẢNH NỀN FULL MÀN HÌNH ---
            Positioned.fill(
              child: Image.asset(
                'assets/images/welcome_bg.png',
                fit: BoxFit.cover, // Ảnh sẽ tràn ra cả khu vực tai thỏ/pin sóng
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.white);
                },
              ),
            ),

            // --- 2. LỚP PHỦ MỜ ---
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.7),
              ),
            ),

            // --- 3. NỘI DUNG CHÍNH ---
            Center(
              child: FadeTransition(
                opacity: _animation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ảnh Logo
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo3.png',
                        width: 180,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.rocket_launch, size: 100, color: Colors.orange);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tên App
                    const Text(
                      "VOCABOOM",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF7E5F),
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: Colors.black12,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Loading xoay vòng
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7E5F)),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}