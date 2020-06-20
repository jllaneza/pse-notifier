class Alert {
    String id;
    bool isAbove;
    bool isEnable;
    double price;
    String symbol;

    Alert({this.id, this.isAbove, this.isEnable, this.price, this.symbol});

    factory Alert.fromJson(Map<String, dynamic> json) {
        return Alert(
            isAbove: json['isAbove'],
            isEnable: json['isEnable'],
            price: json['price'], 
            symbol: json['symbol'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['isAbove'] = this.isAbove;
        data['isEnable'] = this.isEnable;
        data['price'] = this.price;
        data['symbol'] = this.symbol;
        return data;
    }
}

class AlertListScreenArguments {
    final double price;
    final String symbol;

    AlertListScreenArguments(this.price, this.symbol);
}