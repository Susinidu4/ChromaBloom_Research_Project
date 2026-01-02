import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HybridVideoPlayer extends StatefulWidget {
  const HybridVideoPlayer({
    super.key,
    required this.videoUrl,
    this.height = 180,
  });

  final String videoUrl;
  final double height;

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
    if (url.isEmpty) return;

    try {
      _initError = false;
      await _controller?.pause();
      await _controller?.dispose();

      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = c;

      await c.initialize();
      c.setLooping(true);

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      _initError = true;
      debugPrint("MOBILE VIDEO INIT ERROR: $e");
      if (!mounted) return;
      setState(() {});
    }
  }

  void _toggle() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    setState(() {
      c.value.isPlaying ? c.pause() : c.play();
    });
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
        borderRadius: BorderRadius.circular(2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: _initError
            ? const Center(
                child: Text(
                  "Video failed to load",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            : (c == null || !c.value.isInitialized)
                ? const Center(child: CircularProgressIndicator())
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggle,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: c.value.aspectRatio,
                              child: VideoPlayer(c),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.35),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                c.value.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
