import 'package:abacam/database/database.dart';
import 'package:abacam/provider/database_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class VideoRecorderPage extends ConsumerStatefulWidget {
  const VideoRecorderPage({super.key});

  @override
  ConsumerState<VideoRecorderPage> createState() => _VideoRecorderPageState();
}

class _VideoRecorderPageState extends ConsumerState<VideoRecorderPage> {
  late CameraController _cameraController;
  late Future<void> _initializeCameraFuture;
  bool _isRecording = false;
  bool _isWaiting = false;
  XFile? _picture;

  @override
  void initState() {
    super.initState();
    _initializeCameraFuture = _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    // final cameraFront = cameras.firstWhere((camera) {
    //   return camera.lensDirection == CameraLensDirection.front;
    // });

    final cameraBack = cameras.firstWhere((camera) {
      return camera.lensDirection == CameraLensDirection.back;
    });

    _cameraController = CameraController(cameraBack, ResolutionPreset.medium);
    await _cameraController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeCameraFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Stack(
          children: [
            Positioned.fill(
              child: CameraPreview(_cameraController),
            ),
            Positioned.fill(
              bottom: 40,
              child: Align(
                alignment: Alignment.bottomCenter,
                child:
                    _isRecording ? _stopButton(context) : _startButton(context),
              ),
            ),
          ],
        );
      },
    );
  }

  _startButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isWaiting
          ? null
          : () async {
              HapticFeedback.heavyImpact();

              setState(() {
                _isWaiting = true;
              });

              _picture = await _cameraController.takePicture();
              await _cameraController.startVideoRecording();

              setState(() {
                _isWaiting = false;
                _isRecording = true;
              });
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.all(20),
        shape: const CircleBorder(),
      ),
      child: const Icon(Icons.circle, size: 35),
    );
  }

  _stopButton(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return ElevatedButton(
      onPressed: _isWaiting
          ? null
          : () async {
              HapticFeedback.heavyImpact();

              setState(() {
                _isWaiting = true;
              });

              final video = await _cameraController.stopVideoRecording();

              await db.into(db.videos).insert(VideosCompanion.insert(
                title: DateFormat('y/M/d(E) HH:mm', 'ja_JP').format(DateTime.now()),
                description: '',
                thumbnail: _picture!.path,
                filepath: video.path,
              ));

              setState(() {
                _isWaiting = false;
                _isRecording = false;
              });
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.all(20),
        shape: const CircleBorder(),
      ),
      child: const Icon(Icons.square_rounded, size: 35),
    );
  }
}
