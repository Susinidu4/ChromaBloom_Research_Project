import 'package:flutter/material.dart';

class HybridVideoPlayer extends StatelessWidget {
  const HybridVideoPlayer({
    super.key,
    required this.videoUrl,
    this.height = 180,
    this.autoPlay = false,
  });

  final String videoUrl;
  final double height;
  final bool autoPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        border: Border.all(color: const Color(0xFFD8C6B4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text("Video not supported on this platform"),
    );
  }
}
