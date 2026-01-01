import 'package:flutter/material.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;

class HybridVideoPlayer extends StatefulWidget {
  const HybridVideoPlayer({
    super.key,
    required this.videoUrl,
    this.height = 180,
  });

  final String videoUrl;
  final double height;

  @override
  State<HybridVideoPlayer> createState() => _HybridVideoPlayerState();
}

class _HybridVideoPlayerState extends State<HybridVideoPlayer> {
  String? _viewType;
  String? _lastUrl;

  @override
  void didUpdateWidget(covariant HybridVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _register(widget.videoUrl);
    }
  }

  @override
  void initState() {
    super.initState();
    _register(widget.videoUrl);
  }

  void _register(String url) {
    if (url.isEmpty) return;
    if (_lastUrl == url && _viewType != null) return;

    _lastUrl = url;
    final id = "web-video-${DateTime.now().millisecondsSinceEpoch}";
    _viewType = id;

    ui.platformViewRegistry.registerViewFactory(id, (int viewId) {
      final v = html.VideoElement()
        ..src = url
        ..controls = true
        ..autoplay = false
        ..style.width = "100%"
        ..style.height = "100%"
        ..style.objectFit = "contain";
      return v;
    });

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
        child: (_viewType == null)
            ? const Center(child: CircularProgressIndicator())
            : HtmlElementView(viewType: _viewType!),
      ),
    );
  }
}
