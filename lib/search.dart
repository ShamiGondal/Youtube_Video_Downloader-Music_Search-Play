import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'video_player_page.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _videoResult = [];
  bool _isLoading = false;
  double _downloadProgress = 0.0;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchMusic(String query) async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://youtube-music6.p.rapidapi.com/ytmusic/?query=$query';
    final headers = {
      'X-RapidAPI-Key': '',
      'X-RapidAPI-Host': 'youtube-music6.p.rapidapi.com'
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _videoResult = data ?? [];
        });
      } else {
        setState(() {
          _videoResult = [];
        });
        print('Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      setState(() {
        _videoResult = [];
      });
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.black87,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            _searchMusic(_searchController.text);
                          },
                        ),
                      ),
                      onSubmitted: (_) {
                        _searchMusic(_searchController.text);
                      },
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _videoResult.length,
                  itemBuilder: (context, index) {
                    final video = _videoResult[index];
                    final title = video['title'] ?? 'No title';
                    final artists = (video['artists'] as List?)
                        ?.map((artist) => artist['name'] as String?)
                        .where((name) => name != null)
                        .join(', ') ?? 'Unknown artist';
                    final thumbnails = video['thumbnails'] as List?;
                    final thumbnailUrl = thumbnails != null && thumbnails.isNotEmpty
                        ? thumbnails[0]['url'] as String? ?? ''
                        : '';
                    final videoId = video['videoId'] as String?;
                    final streamingUrl = video['videoId'] as String?;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      padding: EdgeInsets.all(8.0),
                      color: Colors.black87,
                      child: Column(
                        children: [
                          if (thumbnailUrl.isNotEmpty)
                            Image.network(
                              thumbnailUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ListTile(
                            title: Text(
                              title,
                              style: TextStyle(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              artists,
                              style: TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.play_arrow, color: Colors.white),
                                  onPressed: () {
                                    if (videoId != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VideoPlayerPage(videoId: videoId),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.link, color: Colors.white),
                                  onPressed: () {
                                    if (streamingUrl != null) {
                                      Clipboard.setData(ClipboardData(text: streamingUrl));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Link copied to clipboard'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              ),
          ],
        ),
      ),
    );
  }
}
