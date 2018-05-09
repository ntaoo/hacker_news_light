import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hackers_news_light/model/hacker_news_service.dart';
import 'package:hackers_news_light/model/hacker_news_service_mock.dart';
import 'package:hackers_news_light/model/news_entry.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

void main() => runApp(HackerNewsLight());

class HackerNewsLight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacker News Light',
      theme: ThemeData(
        primaryColor: Colors.amber,
      ),
      home: NewsEntriesPage(),
    );
  }
}

class NewsEntriesPage extends StatefulWidget {
  @override
  createState() => NewsEntriesState();
}

class NewsEntriesState extends State<NewsEntriesPage> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final _newsEntries = <NewsEntry>[];
  final _saved = Set<NewsEntry>();
  final _biggerFont = TextStyle(fontSize: 18.0);
  final HackerNewsServiceMock hackerNewsService = HackerNewsServiceMock();

  int _nextPage = 1;
  bool _isLastPage = false;

  @override
  void initState() {
    super.initState();
    _getInitialNewsEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hacker News Light'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved)
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_newsEntries.isEmpty) {
      return Center(child: Text('Loading...'));
    } else {
      return _buildNewsEntriesListView();
    }
  }

  Widget _buildNewsEntriesListView() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _getInitialNewsEntries,
      child: ListView.builder(itemBuilder: (BuildContext context, int index) {
        if (index.isOdd) return Divider();

        final i = index ~/ 2;
        if (i < _newsEntries.length) {
//          _newsEntries.addAll(generateWordPairs().take(10));
          return _buildRow(_newsEntries[i]);
        } else if (i == _newsEntries.length) {
          if (_isLastPage) {
            return null;
          } else {
            _getNewsEntries();

            return new Center(
              child: new Container(
                margin: const EdgeInsets.only(top: 8.0),
                width: 32.0,
                height: 32.0,
                child: const CircularProgressIndicator(),
              ),
            );
          }
        } else if (i > _newsEntries.length) {
          return null;
        }
      }),
    );
  }

  Widget _buildBadge(int points) {
    return new Container(
      margin: const EdgeInsets.only(bottom: 2.0),
      width: 36.0,
      height: 36.0,
      decoration: new BoxDecoration(
        color: points >= 100 ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
      child: new Container(
        padding: const EdgeInsets.all(1.0),
        child: new Center(
          child: new Text(
            '$points',
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(NewsEntry entry) {
    final alreadySaved = _saved.contains(entry);
    return ListTile(
      leading: _buildBadge(entry.points),
      title: Text(
        entry.title,
        style: _biggerFont,
      ),
      subtitle: Text('${entry.domain} | ${entry.commentsCount} comments'),
      trailing: new Container(
        padding: new EdgeInsets.all(0.0),
        child: IconButton(
          icon: Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),
          onPressed: () {
            setState(
              () {
                if (alreadySaved) {
                  _saved.remove(entry);
                } else {
                  _saved.add(entry);
                }
              },
            );
          },
        ),
      ),
      onTap: () {
        _viewNewsEntry(entry);
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final tiles = _saved.map(
            (entry) {
              return ListTile(
                title: Text(
                  entry.title,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile
              .divideTiles(
                context: context,
                tiles: tiles,
              )
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Entries'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  Future<Null> _getInitialNewsEntries() async {
    _nextPage = 1;
    await _getNewsEntries();
  }

  Future<Null> _getNewsEntries() async {
    final newsEntries = await hackerNewsService.getNewsEntries(_nextPage);
    if (newsEntries.isEmpty) {
      setState(() {
        _isLastPage = true;
      });
    } else {
      setState(() {
        _newsEntries.addAll(newsEntries);
        _nextPage++;
      });
    }
  }

  void _viewNewsEntry(NewsEntry entry) {
    url_launcher.launch(entry.url);
  }
}
