import 'dart:async';

import 'package:psenotifier/models/stock.dart';
import 'package:psenotifier/networking/response.dart';
import 'package:psenotifier/repositories/stock_list.dart';
import 'package:psenotifier/repositories/watchlist.dart';

class StockListBloc {
  StockListRepository _stockRepository;
  WatchlistRepository _watchlistRepository;
  StreamController _stockListController;
  List<Stock> _stockList = [];

  StreamSink<Response<List<Stock>>> get stockListSink =>
      _stockListController.sink;

  Stream<Response<List<Stock>>> get stockListStream =>
      _stockListController.stream;

  StockListBloc() {
    _stockListController = StreamController<Response<List<Stock>>>();
    _stockRepository = StockListRepository();
    _watchlistRepository = WatchlistRepository();
    fetchStocks();
  }

  fetchStocks() async {
    stockListSink.add(Response.loading('Getting Stock List.'));
    try {
      List<String> _watchlist = await _watchlistRepository.getWatchlist();
      _stockList = (await _stockRepository.fetchStockListData()).map((stock) {
        stock.isWatch = _watchlist.contains(stock.symbol);
        return stock;
      }).toList();

      stockListSink.add(Response.completed(_stockList));
    } catch (e) {
      stockListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  saveStockToWatchlist(String symbol) async {
    Stock stock = _stockList.firstWhere((stock) => stock.symbol == symbol);
    bool isNew = !stock.isWatch;
    await _watchlistRepository.saveStockToWatchlist(symbol, isNew);
    stock.isWatch = isNew;
    stockListSink.add(Response.completed(_stockList));
  }

  dispose() {
    _stockListController?.close();
  }
}
