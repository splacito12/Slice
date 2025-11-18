import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBubble extends StatefulWidget{
  final String videoUrl;
  final bool isSender;

  const VideoBubble({
    super.key,
    required this.videoUrl,
    required this.isSender,
  });

  @override
  State<VideoBubble> createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<VideoBubble>{
  late VideoPlayerController _videoPlayerController;
  bool _init = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_){
        setState(() => _init = true);
      });

      _videoPlayerController.setLooping(false);
  }

  @override
  void dispose(){
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    if(!_init){
      return const Padding(
        padding: EdgeInsets.all(18),
        child: CircularProgressIndicator(),
        );
    }

    return GestureDetector(
      onTap: (){
        _videoPlayerController.value.isPlaying ? _videoPlayerController.pause() : _videoPlayerController.play();
        setState(() {});
      },
      child: AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: VideoPlayer(_videoPlayerController),
        ),
    );
  }
}