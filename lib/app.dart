// lib/main.dart

import 'package:flutter/material.dart';
import 'package:testvideo/search.dart';
import 'package:testvideo/url_input_page.dart';
import 'package:testvideo/video_player_page.dart';


class mainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mp3 Downloader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.cyan,
        ),
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[800],
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple[700],
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.cyanAccent,
          unselectedItemColor: Colors.white70,
        ),
      ),
      home: MyAppStateful(),
    );
  }
}

class MyAppStateful extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyAppStateful> {
  int currentTabIndex = 0;

  final List<Widget> tabs = [
    URLInputPage(),
    Search()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: tabs[currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.download_for_offline),
            label: 'Download',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note_rounded),
            label: 'Search Music',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple[700],
              ),
              child: Text(
                'FitPro Free',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.download),
              title: Text('Mp3 Downloader'),
              onTap: () {
                setState(() {
                  currentTabIndex = 0;
                });
                Navigator.pop(context); // close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Video Search'),
              onTap: () {
                setState(() {
                  currentTabIndex = 1;
                });
                Navigator.pop(context); // close the drawer
              },
            ),
          ],
        ),
      ),
    );
  }
}
