class Alert {
    int id;
    bool isAbove;
    bool isEnable;
    double price;
    String symbol;

    Alert({this.id, this.isAbove, this.isEnable, this.price, this.symbol});

    factory Alert.fromJson(Map<String, dynamic> json) {
        return Alert(
            id: json['id'], 
            isAbove: json['isAbove'] == 1,
            isEnable: json['isEnable'] == 1,
            price: json['price'], 
            symbol: json['symbol'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['isAbove'] = this.isAbove ? 1 : 0;
        data['isEnable'] = this.isEnable ? 1 : 0;
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