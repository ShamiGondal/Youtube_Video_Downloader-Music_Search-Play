import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoDownloaderScreen(),
    );
  }
}

class VideoDownloaderScreen extends StatefulWidget {
  @override
  _VideoDownloaderScreenState createState() => _VideoDownloaderScreenState();
}

class _VideoDownloaderScreenState extends State<VideoDownloaderScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  bool _isDownloading = false;
  String _progress = '';

  Future<void> downloadVideo(String url, String fileName) async {
    final appDocDirectory = await getAppDocDirectory();

    final finalVideoPath = join(
      appDocDirectory.path,
      '$fileName-${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    final dio = Dio();

    setState(() {
      _isDownloading = true;
      _progress = '0%';
    });

    try {
      await dio.download(
        url,
        finalVideoPath,
        onReceiveProgress: (actualBytes, totalBytes) {
          final percentage = (actualBytes / totalBytes * 100).toStringAsFixed(0);
          setState(() {
            _progress = '$percentage%';
          });
        },
      );

      await saveDownloadedVideoToGallery(videoPath: finalVideoPath);
    } catch (e) {
      debugPrint('Error downloading video: $e');
    } finally {
      await removeDownloadedVideo(videoPath: finalVideoPath);
      setState(() {
        _isDownloading = false;
        _progress = '';
      });
    }
  }

  Future<Directory> getAppDocDirectory() async {
    if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }
    return (await getExternalStorageDirectory())!;
  }

  Future<void> saveDownloadedVideoToGallery({required String videoPath}) async {
    await ImageGallerySaver.saveFile(videoPath);
  }

  Future<void> removeDownloadedVideo({required String videoPath}) async {
    try {
      File(videoPath).deleteSync();
    } catch (error) {
      debugPrint('Error deleting video: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Downloader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'Video URL'),
            ),
            TextField(
              controller: _fileNameController,
              decoration: InputDecoration(labelText: 'File Name'),
            ),
            SizedBox(height: 20),
            _isDownloading
                ? Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Downloading: $_progress'),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      final url = _urlController.text;
                      final fileName = _fileNameController.text;
                      if (url.isNotEmpty && fileName.isNotEmpty) {
                        downloadVideo(url, fileName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter both URL and file name')),
                        );
                      }
                    },
                    child: Text('Download Video'),
                  ),
          ],
        ),
      ),
    );
  }
}
