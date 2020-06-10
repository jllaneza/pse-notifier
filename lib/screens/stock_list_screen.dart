import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:psenotifier/blocs/stock_list_block.dart';
import 'package:psenotifier/models/stock.dart';
import 'package:psenotifier/models/stocks.dart';
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
        child: StreamBuilder<Response<Stocks>>(
          stream: _bloc.stockListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return StockList(stockList: snapshot.data.data.stock);
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
  StockList({Key key, this.stockList}) : super(key: key);

  final List<Stock> stockList;

  @override
  _StockListState createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  List<Stock> filteredList;
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredList = widget.stockList;
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
        title: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Search Stocks",
            suffixIcon: IconButton(
              onPressed: () => controller.clear(),
              icon: Icon(Icons.clear),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredList[index].name),
            subtitle: Text(filteredList[index].symbol),
            trailing: Icon(
              FontAwesomeIcons.eye,
              size: 18.0,
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
