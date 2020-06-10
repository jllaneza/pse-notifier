import 'dart:async';

import 'package:psenotifier/networking/api_provider.dart';
import 'package:psenotifier/models/stocks.dart';

class StockListRepository {
  ApiProvider _provider = ApiProvider();

  Future<Stocks> fetchStockListData() async {
    final response = await _provider.get("stocks.json");
    return Stocks.fromJson(response);
  }
}