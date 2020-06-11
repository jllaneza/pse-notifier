import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:psenotifier/blocs/stock_list.dart';
import 'package:psenotifier/models/stock.dart';
import 'package:psenotifier/networking/response.dart';
import 'package:psenotifier/components/loading.dart';
import 'package:psenotifier/components/error.dart';

class StockListScreen extends StatefulWidget {
  @override
  _StockListScreenState createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  StockListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = StockListBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _bloc.fetchStocks(),
        child: StreamBuilder<Response<List<Stock>>>(
          stream: _bloc.stockListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return StockList(
                    stockList: snapshot.data.data,
                    bloc: _bloc,
                  );
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
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class StockList extends StatefulWidget {
  StockList({Key key, this.stockList, this.bloc}) : super(key: key);

  final List<Stock> stockList;
  final StockListBloc bloc;

  @override
  _StockListState createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  List<Stock> filteredList;
  StockListBloc bloc;
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredList = widget.stockList;
    bloc = widget.bloc;

    controller.addListener(() {
      filterStockList(controller.text);
    });
  }

  void filterStockList(filter) {
    setState(() {
      filteredList = widget.stockList
          .where((stock) =>
              stock.name.toLowerCase().contains(filter) ||
              stock.symbol.toLowerCase().contains(filter))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              child: Icon(
                Icons.arrow_back,
                size: 24.0,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, '/');
              },
            ),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search Stocks",
                  suffixIcon: IconButton(
                    onPressed: () => controller.clear(),
                    icon: Icon(Icons.clear),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          IconData icon = filteredList[index].isWatch
              ? FontAwesomeIcons.eyeSlash
              : FontAwesomeIcons.eye;
          return ListTile(
            title: Text(filteredList[index].name),
            subtitle: Text(filteredList[index].symbol),
            trailing: IconButton(
              icon: Icon(icon),
              iconSize: 18.0,
              onPressed: () {
                bloc.saveStockToWatchlist(filteredList[index].symbol);
              },
            ),
          );
        },
        itemCount: filteredList.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
