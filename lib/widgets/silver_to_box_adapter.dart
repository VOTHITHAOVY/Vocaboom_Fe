import 'package:flutter/material.dart';

class SliverToBoxAdapter extends StatelessWidget {
  final Widget child;

  const SliverToBoxAdapter({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: child);
  }
}