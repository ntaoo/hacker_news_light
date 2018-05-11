import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hacker_news_light/model/hacker_news_service_mock.dart';
import 'package:hacker_news_light/model/news_entry.dart';

void main() => runApp(HackerNewsLight());

typedef void FavoritePressedCallback(
    NewsEntry newsEntry, bool isAlreadySaved, Set<NewsEntry> savedEntries);

class FavoriteButton extends StatelessWidget {
  final NewsEntry newsEntry;
  final Set<NewsEntry> savedEntries;
  final FavoritePressedCallback handleFavoritePressed;
  final bool isAlreadySaved;
  FavoriteButton(
      {@required this.newsEntry,
      @required this.savedEntries,
      @required this.handleFavoritePressed})
      : isAlreadySaved = savedEntries.contains(newsEntry);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(0.0),
        child: IconButton(
            icon: Icon(
              isAlreadySaved ? Icons.favorite : Icons.favorite_border,
              color: isAlreadySaved ? Colors.red : null,
            ),
            onPressed: () {
              handleFavoritePressed(newsEntry, isAlreadySaved, savedEntries);
            }));
  }
}

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
  NewsEntriesPage({Key key}) : super(key: key);

  @override
  createState() => NewsEntriesState();
}

class NewsEntriesState extends State<NewsEntriesPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final List<NewsEntry> _newsEntries = [];
  final Set<NewsEntry> _savedEntries = Set<NewsEntry>();
  final TextStyle _biggerFontStyle = TextStyle(fontSize: 18.0);
  final HackerNewsServiceMock hackerNewsService = HackerNewsServiceMock();

  int _nextPage = 1;
  bool _isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hacker News Light'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _navigateToSavedPage)
        ],
      ),
      body: _buildBody(),
    );
  }

  @override
  void initState() {
    super.initState();
    _getInitialNewsEntries();
  }

  Widget _buildBadge(int points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2.0),
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        color: (points == null || points < 100) ? Colors.red : Colors.green,
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: EdgeInsets.all(1.0),
        child: Center(
          child: Text(
            points == null ? '' : '$points',
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
    );
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
      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _getInitialNewsEntries,
        child: _buildNewsEntriesListView(),
      );
    }
  }

  Widget _buildNewsEntriesListView() {
    return ListView.builder(itemBuilder: (BuildContext context, int index) {
      if (index.isOdd) return Divider();

      final i = index ~/ 2;
      if (i < _newsEntries.length) {
        return _buildNewsEntryRow(_newsEntries[i]);
      } else if (i == _newsEntries.length) {
        if (_isLastPage) {
          return null;
        } else {
          _getNewsEntries();
          return Center(
            child: Container(
              margin: EdgeInsets.only(top: 8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            ),
          );
        }
      } else if (i > _newsEntries.length) {
        return null;
      }
    });
  }

  Widget _buildNewsEntryRow(NewsEntry newsEntry) {
    return ListTile(
      leading: _buildBadge(newsEntry.points),
      title: Text(
        newsEntry.title,
        style: _biggerFontStyle,
      ),
      subtitle:
          Text('${newsEntry.domain} | ${newsEntry.commentsCount} comments'),
      trailing: FavoriteButton(
          newsEntry: newsEntry,
          savedEntries: _savedEntries,
          handleFavoritePressed: _handleFavoritePressed),
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

  _handleFavoritePressed(
      NewsEntry newsEntry, bool isAlreadySaved, Set<NewsEntry> savedEntries) {
    setState(
      () {
        if (isAlreadySaved) {
          savedEntries.remove(newsEntry);
        } else {
          savedEntries.add(newsEntry);
        }
      },
    );
  }

  void _navigateToSavedPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final tiles = _savedEntries.map(
            (entry) {
              return ListTile(
                title: Text(
                  entry.title,
                  style: _biggerFontStyle,
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
}
