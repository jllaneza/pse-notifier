import 'stock.dart';

class Stocks {
  List<Stock> stock;

  Stocks({this.stock});

  factory Stocks.fromJson(Map<String, dynamic> json) {
    return Stocks(
      stock: json['stock'] != null ? (json['stock'] as List).map((i) => Stock.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.stock != null) {
      data['stock'] = this.stock.map((v) => v.toJson()).toList();
    }
    return data;
  }
}