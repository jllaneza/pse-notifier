import 'dart:ffi';

import 'package:flutter/material.dart';

import 'package:psenotifier/components/loading.dart';
import 'package:psenotifier/components/error.dart';
import 'package:psenotifier/blocs/stock_list_block.dart';
import 'package:psenotifier/models/stock.dart';
import 'package:psenotifier/networking/response.dart';
import 'package:psenotifier/models/stocks.dart';

const List<String> _rowHeader = ['Stock', 'Price', 'Actions'];

class WatchlistScreen extends StatefulWidget {
  WatchlistScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  StockListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = StockListBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.title),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              top: 20.0,
              bottom: 8.0,
              left: 15.0,
              right: 15.0,
            ),
            padding: EdgeInsets.only(bottom: 15.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white24,
                  width: 1.0,
                ),
              ),
            ),
            child: _buildHeader(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _bloc.fetchStocks(),
              child: StreamBuilder<Response<Stocks>>(
                stream: _bloc.stockListStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return Loading(loadingMessage: snapshot.data.message);
                        break;
                      case Status.COMPLETED:
                        return Watchlist(watchlist: snapshot.data.data.stock);
                        break;
                      case Status.ERROR:
                        return Error(
                          errorMessage: snapshot.data.message,
                          onRetryPressed: () => _bloc.fetchStocks(),
                        );
                        break;
                    }
                  }
                  return Container();
                },
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        height: 55,
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: RawMaterialButton(
          onPressed: () {},
          elevation: 2.0,
          fillColor: Colors.white,
          child: Text(
            '+',
            style: TextStyle(fontSize: 28.0, color: Colors.black87),
          ),
          shape: CircleBorder(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    List<Expanded> headers = _rowHeader
        .map(
          (row) => Expanded(
            child: Text(
              row,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
        .toList();
    return Row(
      children: headers,
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class Watchlist extends StatefulWidget {
  Watchlist({Key key, this.watchlist}) : super(key: key);

  final List<Stock> watchlist;

  @override
  _WatchlistState createState() => _WatchlistState();
}

class _WatchlistState extends State<Watchlist> {
  List<Stock> watchlist;

  @override
  void initState() {
    super.initState();
    watchlist = widget.watchlist;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 8.0),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.white24,
          ),
          itemCount: watchlist.length,
          itemBuilder: (context, index) => _buildListItem(
            watchlist[index],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(Stock stock) {
    String price = '${stock.price.currency}${stock.price.amount}';
    double percentage = stock.percentChange;
    String percentChange = percentage > 0 ? '+$percentage%' : '$percentage%';
    Color percentageColor = percentage > 0 ? Colors.green : Colors.red;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(
          child: Text(
            stock.symbol,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                percentChange,
                style: TextStyle(
                  color: percentageColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => {},
              ),
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () => {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
