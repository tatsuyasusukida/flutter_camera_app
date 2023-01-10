import 'dart:io';

import 'package:abacam/database/database.dart';
import 'package:abacam/provider/database_provider.dart';
import 'package:abacam/provider/video_provider_family.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoDetailsPage extends ConsumerStatefulWidget {
  final int id;

  const VideoDetailsPage({super.key, required this.id});

  @override
  ConsumerState<VideoDetailsPage> createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends ConsumerState<VideoDetailsPage> {
  late final VideoPlayerController _videoPlayerController;
  late final Future<void> _initializeVideoPlayerFuture;
  late final Video _video;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _video = await ref.read(videoFutureProvider(widget.id));
    _videoPlayerController = VideoPlayerController.file(File(_video.filepath));
    _videoPlayerController.addListener(_onChangeVideo);

    await _videoPlayerController.initialize();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('動画の詳細'),
          actions: [
            IconButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final result = await showOkCancelAlertDialog(
                  context: context,
                  message: '削除してもよろしいですか?',
                  isDestructiveAction: true,
                  okLabel: '削除',
                );

                if (result == OkCancelResult.ok) {
                  navigator.pop();
                }
              },
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        body: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _videoPlayer(context),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _video.title,
                          decoration: const InputDecoration(
                            label: Text('タイトル'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          initialValue: '',
                          minLines: 1,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            label: Text('メモ'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: null,
                            child: Text('保存'),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _videoPlayer(BuildContext context) {
    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              _togglePlaying();
            },
            child: VideoPlayer(_videoPlayerController),
          ),
          ...(_videoPlayerController.value.isPlaying
              ? []
              : [
                  Center(
                    child: ElevatedButton(
                      onPressed: _togglePlaying,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.all(15.0),
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 30.0,
                        color: Colors.white,
                      ),
                    ),
                  )
                ]),
        ],
      ),
    );
  }

  void _togglePlaying() {
    setState(() {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      } else {
        _videoPlayerController.play();
      }
    });
  }

  void _onChangeVideo() {
    final video = _videoPlayerController.value;
    const start = Duration();
    final end = video.duration;

    if (video.position == start || video.position == end) {
      setState(() {});
    }
  }
}
