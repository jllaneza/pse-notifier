import 'dart:async';

import 'package:psenotifier/networking/response.dart';
import 'package:psenotifier/repositories/stock_list_repository.dart';
import 'package:psenotifier/models/stocks.dart';

class StockListBloc {
  StockListRepository _stockRepository;
  StreamController _stockListController;

  StreamSink<Response<Stocks>> get stockListSink =>
      _stockListController.sink;

  Stream<Response<Stocks>> get stockListStream =>
      _stockListController.stream;

  StockListBloc() {
    _stockListController = StreamController<Response<Stocks>>();
    _stockRepository = StockListRepository();
    fetchStocks();
  }

  fetchStocks() async {
    stockListSink.add(Response.loading('Getting Stock List.'));
    try {
      Stocks stockList =
      await _stockRepository.fetchStockListData();
      stockListSink.add(Response.completed(stockList));
    } catch (e) {
      stockListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _stockListController?.close();
  }
}