import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoDetails {
  final File file;
  final String title;
  final String description;

  VideoDetails({this.file, this.title, this.description});
}

class VideoRecorder extends StatefulWidget {
  @override
  _VideoRecorderState createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {
  File _videoFile;
  String _title;
  String _description;

  final picker = ImagePicker();
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  Future<void> _pickVideoFromCamera() async {
    final pickedFile = await picker.getVideo(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _videoFile = File(pickedFile.path);
        _controller = VideoPlayerController.file(_videoFile);
        _initializeVideoPlayerFuture = _controller.initialize();
      } else {
        print('No video selected.');
      }
    });
  }

  void _showVideoDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Video Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: 'Title'),
                onChanged: (value) => _title = value,
              ),
              TextField(
                decoration: InputDecoration(hintText: 'Description'),
                onChanged: (value) => _description = value,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(VideoDetails(
                  file: _videoFile,
                  title: _title ?? '',
                  description: _description ?? '',
                ));
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Recorder'),
      ),
      body: Center(
        child: _controller == null
            ? Text('No video selected.')
            : FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _pickVideoFromCamera();
          _showVideoDetailsDialog();
        },
        tooltip: 'Record Video',
        child: Icon(Icons.videocam),
      ),
    );
  }
}
