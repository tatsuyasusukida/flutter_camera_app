import 'dart:io';

import 'package:abacam/provider/videos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'video_details_page.dart';
import 'video_recorder_page.dart';

class VideoListPage extends ConsumerWidget {
  const VideoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosStream = ref.watch(videosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('動画リスト'),
      ),
      body: videosStream.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                itemCount: videosStream.value!.length,
                itemBuilder: (context, index) {
                  final video = videosStream.value![index];

                  return ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VideoDetailsPage(id: video.id),
                        ),
                      );
                    },
                    title: Text(
                      video.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: AspectRatio(
                      aspectRatio: 1,
                      child: Image.file(
                        File(video.thumbnail),
                        fit: BoxFit.cover,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const VideoRecorderPage(),
            ),
          );
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('カメラを起動'),
      ),
    );
  }
}
