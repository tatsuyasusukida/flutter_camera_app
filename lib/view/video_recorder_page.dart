
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VideoRecorderPage extends StatefulWidget {
  const VideoRecorderPage({super.key});

  @override
  State<VideoRecorderPage> createState() => _VideoRecorderPageState();
}

class _VideoRecorderPageState extends State<VideoRecorderPage> {
  late CameraController _cameraController;
  late Future<void> _initializeCameraFuture;
  bool _isRecording = false;

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

    _cameraController = CameraController(cameraBack, ResolutionPreset.max);
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
      onPressed: () {
        setState(() {
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
    return ElevatedButton(
      onPressed: () {
        setState(() {
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
