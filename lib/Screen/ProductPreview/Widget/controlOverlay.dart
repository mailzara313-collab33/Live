import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ControlsOverlay extends StatefulWidget {
  const ControlsOverlay({super.key, this.controller});

  final VideoPlayerController? controller;

  @override
  State<ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<ControlsOverlay> {
  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  late VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    _controller?.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _controller!.value.isPlaying
            ? const SizedBox.shrink()
            : Container(
                color: Colors.black26,
                child: const Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 100.0,
                  ),
                ),
              ),
        _controller!.value.isPlaying
            ? Container(
                color: Colors.black26,
                child: const Center(
                  child: Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 100.0,
                  ),
                ),
              )
            : const SizedBox.shrink(),
        GestureDetector(
          onTap: () {
            if (_controller!.value.isPlaying) {
              _controller!.pause();
            } else {
              _controller!.play();
            }
            setState(() {});
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: _controller!.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              _controller!.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text(
                      '${speed}x',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor),
                    ),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Text(
                '${_controller!.value.playbackSpeed}x',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.fontColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(() {});
    super.dispose();
  }
}
