import 'dart:io';
import 'package:path/path.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'video_player_page.dart';  // Import the VideoPlayerPage
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoDetailsPage extends StatefulWidget {
  final Map<String, dynamic> videoData;

  VideoDetailsPage({required this.videoData, Key? key}) : super(key: key);

  @override
  _VideoDetailsPageState createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends State<VideoDetailsPage> {
  double _downloadProgress = 0.0;
  bool _downloading = false;

  Future<void> _downloadVideo(String url, String quality) async {
    setState(() {
      _downloading = true;
      _downloadProgress = 0.0;
    });

    final appDocDirectory = await getAppDocDirectory();
    final finalVideoPath = join(
      appDocDirectory.path,
      'Video-$quality-${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    final dio = Dio();

    await dio.download(
      url,
      finalVideoPath,
      onReceiveProgress: (received, total) {
        setState(() {
          _downloadProgress = received / total;
        });
      },
    );

    setState(() {
      _downloading = false;
    });

    await saveDownloadedVideoToGallery(videoPath: finalVideoPath);
    await removeDownloadedVideo(videoPath: finalVideoPath);
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
      Directory(videoPath).deleteSync(recursive: true);
    } catch (error) {
      debugPrint('$error');
    }
  }

  void _navigateToVideoPlayer(BuildContext context) {
    final url = widget.videoData['src_url'];
    String videoId = YoutubePlayer.convertUrlToId(url)!;
    if (url.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerPage(videoId: videoId),
        ),
      );
    } else {
      // Handle the case when videoId is invalid
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid video URL.'))
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey, // Set the background color
      appBar: AppBar(
        backgroundColor: Colors.black, // Set the background color to blue
        title: Text(
          'Video Details',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold), // Set text color to white
        ),
        iconTheme: IconThemeData(
            color: Colors.white), // Set icon (back button) color to white
        automaticallyImplyLeading: true, // Show back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.videoData['picture']),
            SizedBox(height: 8),
            Text(
              widget.videoData['description'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Author: ',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${widget.videoData['author']['name']}',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Views: ',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${widget.videoData['stats']['views']}',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Published: ',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${widget.videoData['stats']['publishedText']}',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Downloading:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(height: 8),
            _downloading
                ? LinearProgressIndicator(
              value: _downloadProgress,
              minHeight: 20,
            )
                : Container(),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.videoData['links'].length,
                itemBuilder: (context, index) {
                  final link = widget.videoData['links'][index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 200,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black38),
                          foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                          overlayColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        onPressed: () {
                          _downloadVideo(link['link'], link['quality']);
                        },
                        child: Text(
                          link['quality'],
                          style: TextStyle(
                              color: Colors.white, fontSize: 15), // colour
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _navigateToVideoPlayer(context);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow), // Play button icon
                  SizedBox(width: 8), // Add some spacing between the icon and the text
                  Text('Play Video'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
