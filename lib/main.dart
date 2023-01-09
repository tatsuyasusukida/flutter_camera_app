import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '応用行動分析カメラ',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ja', 'JP'),
      ],
      home: VideoListPage(),
    );
  }
}

class VideoListPage extends StatelessWidget {
  const VideoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('動画リスト'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const VideoDetailPage(),
                ));
              },
              title: const Text('2023年1月9日 月曜日 9時15分'),
              trailing: const Icon(Icons.chevron_right),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'カメラを起動',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({super.key});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    const dataSource =
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
    _videoPlayerController = VideoPlayerController.network(dataSource);
    _initializeVideoPlayerFuture = _videoPlayerController.initialize();
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
                          initialValue: '2023年1月9日 月曜日 9時15分',
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
                    child: RawMaterialButton(
                      onPressed: _togglePlaying,
                      elevation: 2.0,
                      fillColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.all(15.0),
                      shape: const CircleBorder(),
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
}
