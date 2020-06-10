import 'price.dart';

class Stock {
  String name;
  double percentChange;
  Price price;
  String symbol;
  int volume;

  Stock({this.name, this.percentChange, this.price, this.symbol, this.volume});

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      name: json['name'],
      percentChange: json['percent_change'],
      price: json['price'] != null ? Price.fromJson(json['price']) : null,
      symbol: json['symbol'],
      volume: json['volume'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['percent_change'] = this.percentChange;
    data['symbol'] = this.symbol;
    data['volume'] = this.volume;
    if (this.price != null) {
      data['price'] = this.price.toJson();
    }
    return data;
  }
}