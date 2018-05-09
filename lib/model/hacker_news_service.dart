import 'dart:async';
import 'dart:convert';
import 'package:hackers_news_light/model/news_entry.dart';
import 'package:http/http.dart' as http;

const defaultBaseUrl = 'https://api.hnpwa.com/v0';

class HackerNewsService {
  final String _baseUrl = defaultBaseUrl;

  // Store the last feed in memory to instantly load when requested.
  String _cacheFeedKey;
  List<NewsEntry> _cacheFeedResult;

  Future<List<NewsEntry>> getNewsEntries(int page) async {
    final url = '$_baseUrl/news/$page.json';
    if (_cacheFeedKey == url) {
      return _cacheFeedResult;
    }
    final response = await http.get(url);
    final decoded = json.decode(response.body) as List;
    _cacheFeedKey = url;
    final jsonMapList = decoded.cast<Map>();
    _cacheFeedResult = jsonMapList.map((e) => NewsEntry.fromMap(e)).toList();
    return _cacheFeedResult;
  }

  Future<Map> getItem(String id) async {
    final url = '$_baseUrl/item/$id.json';
    final response = await http.get(url);
    return json.decode(response.body);
  }
}
