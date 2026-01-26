import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  final String imageUrl;
  final int likes;
  final bool isLiked;
  final int videoCount;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onLikePressed;

  const VideoCard({
    Key? key,
    required this.imageUrl,
    required this.likes,
    required this.isLiked,
    required this.videoCount,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onLikePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ❌ BỎ MARGIN: Vì Grid (SliverGrid) bên ngoài đã lo phần khoảng cách rồi
        // Nếu để margin ở đây, thẻ sẽ bị thu nhỏ lại rất xấu.
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Bo góc nhỏ lại chút cho gọn
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PHẦN ẢNH THUMBNAIL (Chiếm phần lớn diện tích)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey, size: 30),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[100],
                        );
                      },
                    ),
                  ),
                ),
                // Badge số lượng video (Thu nhỏ lại)
                Positioned(
                  bottom: 6,
                  right: 6, // Đổi sang góc phải nhìn thoáng hơn
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_fill, color: Colors.white, size: 10),
                        const SizedBox(width: 3),
                        Text(
                          '$videoCount', // Chỉ hiện số cho gọn
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. PHẦN NỘI DUNG (Tối ưu padding và font size)
            Padding(
              padding: const EdgeInsets.all(10), // Giảm padding từ 16 xuống 10
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13, // 🔥 Giảm font size xuống 13-14
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Phụ đề (Subtitle)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11, // 🔥 Giảm font size phụ đề
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Footer: Chỉ giữ lại nút Tim (Bỏ nút Xem Video vì thừa)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Hiển thị dạng Text nhỏ thay vì nút to
                      Text(
                        "Học ngay",
                        style: TextStyle(fontSize: 10, color: Colors.blue[700], fontWeight: FontWeight.w600),
                      ),

                      // Nút Tim nhỏ gọn
                      InkWell(
                        onTap: onLikePressed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.pink,
                                  size: 12
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$likes',
                                style: const TextStyle(
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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