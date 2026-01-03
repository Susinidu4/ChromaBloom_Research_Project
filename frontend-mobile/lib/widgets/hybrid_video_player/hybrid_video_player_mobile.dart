import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HybridVideoPlayer extends StatefulWidget {
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
  State<HybridVideoPlayer> createState() => _HybridVideoPlayerMobileState();
}

class _HybridVideoPlayerMobileState extends State<HybridVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initError = false;

  @override
  void initState() {
    super.initState();
    _init(widget.videoUrl);
  }

  @override
  void didUpdateWidget(covariant HybridVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _init(widget.videoUrl);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _init(String url) async {
    if (url.trim().isEmpty) {
      setState(() => _initError = true);
      return;
    }

    try {
      _initError = false;

      final old = _controller;
      _controller = null;
      await old?.pause();
      await old?.dispose();

      final c = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _controller = c;

      await c.initialize();
      await c.setLooping(true);

      if (widget.autoPlay) {
        await c.play();
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      _initError = true;
      debugPrint("MOBILE VIDEO INIT ERROR: $e");
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _toggle() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        border: Border.all(color: const Color(0xFFD8C6B4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _initError
            ? const Center(
                child: Text(
                  "Video failed to load",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            : (c == null)
                ? const Center(child: CircularProgressIndicator())
                : ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: c,
                    builder: (context, v, _) {
                      if (!v.isInitialized) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return GestureDetector(
                        onTap: _toggle,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio: v.aspectRatio,
                                child: VideoPlayer(c),
                              ),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.35),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                v.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
