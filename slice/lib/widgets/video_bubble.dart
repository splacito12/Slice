import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class VideoBubble extends StatefulWidget{
  final Uint8List bytes;
  final bool isSender;

  const VideoBubble({
    super.key,
    required this.bytes,
    required this.isSender,
  });

  @override
  State<VideoBubble> createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<VideoBubble>{
  VideoPlayerController? _videoPlayerController;
  bool _init = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async{
    //write decryption into a temporary file
    final dirTemp = await getTemporaryDirectory();
    final fileTemp = File("${dirTemp.path}/${DateTime.now().millisecondsSinceEpoch}.mp4");

    await fileTemp.writeAsBytes(widget.bytes);

    //now we need to load a video
    _videoPlayerController = VideoPlayerController.file(fileTemp);
    await _videoPlayerController!.initialize();

    setState(() {
      _init = true;
    });
  }

  @override
  void dispose(){
    _videoPlayerController?.dispose();
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
        if(_videoPlayerController!.value.isPlaying){
          _videoPlayerController!.pause();
        }else{
          _videoPlayerController!.play();
        }
        setState(() {});
      },
      child: AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: VideoPlayer(_videoPlayerController!),
        ),
    );
  }
}