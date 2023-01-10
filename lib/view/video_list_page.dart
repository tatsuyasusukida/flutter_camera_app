import 'package:flutter/material.dart';

import 'video_details_page.dart';
import 'video_recorder_page.dart';

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
                  builder: (context) => const VideoDetailsPage(),
                ));
              },
              title: const Text(
                '2023/1/9(月) 9:15',
                overflow: TextOverflow.ellipsis,
              ),
              leading: Image.network(
                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
              trailing: const Icon(Icons.chevron_right),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const VideoRecorderPage(),
          ));
        },
        tooltip: 'カメラを起動',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
