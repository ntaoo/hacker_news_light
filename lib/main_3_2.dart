import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hacker_news_light/model/hacker_news_service_mock.dart';
import 'package:hacker_news_light/model/news_entry.dart';

void main() => runApp(HackerNewsLight());

class HackerNewsLight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacker News Light',
      theme: ThemeData(primaryColor: Colors.amber),
      home: NewsEntriesPage(),
    );
  }
}

class NewsEntriesPage extends StatefulWidget {
  @override
  createState() => NewsEntriesState();
}

class NewsEntriesState extends State<NewsEntriesPage> {
  final List<NewsEntry> _newsEntries = [];
  final HackerNewsServiceMock hackerNewsService = HackerNewsServiceMock();
  final TextStyle _biggerFontStyle = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hacker News Light'),
      ),
      body: _buildBody(),
    );
  }

  @override
  void initState() {
    super.initState();
    _getNewsEntries();
  }

  Widget _buildBody() {
    if (_newsEntries.isEmpty) {
      return Center(
        child: Container(
          margin: EdgeInsets.only(top: 8.0),
          width: 32.0,
          height: 32.0,
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return _buildNewsEntriesListView();
    }
  }

  Widget _buildNewsEntriesListView() {
    return ListView.builder(itemBuilder: (BuildContext context, int index) {
      if (index.isOdd) return Divider();

      final i = index ~/ 2;
      if (i < _newsEntries.length) {
        return _buildNewsEntryRow(_newsEntries[i]);
      } else {
        return null;
      }
    });
  }

  Widget _buildNewsEntryRow(NewsEntry newsEntry) {
    return ListTile(
      title: Text(
        newsEntry.title,
        style: _biggerFontStyle,
      ),
    );
  }

  Future<Null> _getNewsEntries() async {
    final newsEntries = await hackerNewsService.getNewsEntries(1);
    setState(() {
      _newsEntries.addAll(newsEntries);
    });
  }
}
