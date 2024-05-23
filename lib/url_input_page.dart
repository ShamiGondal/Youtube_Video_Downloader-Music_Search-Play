import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'video_details_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class URLInputPage extends StatefulWidget {
  URLInputPage({key});

  @override
  _URLInputPageState createState() => _URLInputPageState();
}
class _URLInputPageState extends State<URLInputPage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isFetching = false; // Track fetching state

  void _fetchVideoDetails() async {
    setState(() {
      _isFetching = true; // Set fetching state to true when fetching starts
    });

    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      try {
        final response = await Dio().get(
          'https://youtube-video-and-shorts-downloader1.p.rapidapi.com/api/getYTVideo',
          queryParameters: {'url': url},
          options: Options(
            headers: {
              'X-RapidAPI-Key':
                  '',
              'X-RapidAPI-Host':
                  'youtube-video-and-shorts-downloader1.p.rapidapi.com',
            },
          ),
        );

        if (response.data['error'] == false) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VideoDetailsPage(
                videoData: response.data,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${response.data['error_message']}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to fetch video details'),
        ));
      } finally {
        setState(() {
          _isFetching = false; // Set fetching state to false when fetching ends
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey, // Set the background color
      appBar: AppBar(
        backgroundColor: Colors.black, // Set the background color to black
        title: Row(
          children: [
            SizedBox(width: 10),
            Text(
              'Download Songs ',
              style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold), // Set text color to white
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon (back button) color to white
        ),
        automaticallyImplyLeading: true, // Show back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'YouTube URL',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isFetching
                ? CircularProgressIndicator() // Show CircularProgressIndicator if fetching
                : ElevatedButton(
                    onPressed: _fetchVideoDetails,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.black54), // Blue background color
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.white), // White text color
                    ),
                    child: Text('Fetch Video Details'),
                  ),
          ],
        ),
      ),
    );
  }
}
