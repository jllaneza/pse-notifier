import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'watchlist';

class WatchlistRepository {
  Future<bool> saveStockToWatchlist(String symbol, bool isNew) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> watchlist = prefs.getStringList(_prefKey) ?? [];
    isNew ? watchlist.add(symbol) : watchlist.remove(symbol);
    return prefs.setStringList(_prefKey, watchlist);
  }

  Future<List<String>> getWatchlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefKey);
  }
}