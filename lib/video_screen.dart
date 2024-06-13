import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key});

  @override
  State<StatefulWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  double _currentSliderValue = 0.0;
  double _totalVideoLength = 0.0;
  final List<double> _markerTimestamps = [];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'))
      ..initialize().then((_) {
        setState(() {
          _totalVideoLength = _controller.value.duration.inSeconds.toDouble();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? VideoBody(
                controller: _controller,
                sliderValue: _currentSliderValue,
                onDragged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                  });
                  _controller.seekTo(Duration(seconds: value.toInt()));
                },
                onAddMarker: () {
                  setState(() {
                    _controller.pause();
                    _isPlaying = false;
                    _markerTimestamps.add(_currentSliderValue);
                  });
                },
                onTabMarker: () {
                  // todo : show dialog
                  // setState(() {
                  //   _controller.pause();
                  //   _isPlaying = false;
                  //   _markerTimestamps.add(_currentSliderValue);
                  // });
                },
                markerTimestamps: _markerTimestamps,
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
              _isPlaying = false;
            } else {
              _controller.play();
              _isPlaying = true;
            }
          });
        },
        child: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class VideoBody extends StatelessWidget {
  final VideoPlayerController controller;
  final double sliderValue;
  final Function(double) onDragged;
  final VoidCallback onAddMarker;
  final VoidCallback onTabMarker;
  final List<double> markerTimestamps;

  const VideoBody({
    super.key,
    required this.controller,
    required this.sliderValue,
    required this.onDragged,
    required this.onAddMarker,
    required this.onTabMarker,
    required this.markerTimestamps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Expanded(
                  child: Container(
                    color : Colors.grey,
                    child: Slider(
                      value: sliderValue,
                      min: 0,
                      max: controller.value.duration.inSeconds.toDouble(),
                      onChanged: onDragged,
                    ),
                  ),
                ),
                ...markerTimestamps.map((timestamp) {
                  final position = timestamp / controller.value.duration.inSeconds;
                  return Positioned(
                    left: position * constraints.maxWidth,
                    // position * constraints.maxWidth - 8,
                    bottom: 0,
                    child: InkWell(
                      onTap: onTabMarker,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: onAddMarker,
            child: const Text('Add Marker'),
          ),
        ),
      ],
    );
  }
}
