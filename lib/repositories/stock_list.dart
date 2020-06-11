import 'dart:async';

import 'package:psenotifier/networking/api_provider.dart';
import 'package:psenotifier/models/stocks.dart';
import 'package:psenotifier/models/stock.dart';

class StockListRepository {
  ApiProvider _provider = ApiProvider();

  Future<List<Stock>> fetchStockListData() async {
    final response = await _provider.get("stocks.json");
    return Stocks.fromJson(response)?.stock ?? [];
  }
}