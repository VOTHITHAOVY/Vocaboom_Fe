import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final int heartCount;

  const NotificationsScreen({Key? key, required this.heartCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.pink),
            title: const Text('Nhận trái tim mỗi ngày'),
            subtitle: const Text('Đã nhận 5 trái tim'),
            trailing: Text('$heartCount/5'),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.amber),
            title: const Text('Hoàn thành Quiz hôm nay'),
            subtitle: const Text('Nhận thưởng streak'),
          ),
          ListTile(
            leading: const Icon(Icons.cake, color: Colors.purple),
            title: const Text('Thú cưng đói bụng'),
            subtitle: const Text('Cho thú cưng ăn để nhận thưởng'),
          ),
          ListTile(
            leading: const Icon(Icons.update, color: Colors.blue),
            title: const Text('Cập nhật ứng dụng'),
            subtitle: const Text('Phiên bản mới đã có sẵn'),
          ),
        ],
      ),
    );
  }
}