import 'package:flutter/material.dart';

class HybridVideoPlayer extends StatelessWidget {
  const HybridVideoPlayer({
    super.key,
    required this.videoUrl,
    this.height = 180,
  });

  final String videoUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      child: const Text("Video not supported on this platform"),
    );
  }
}
