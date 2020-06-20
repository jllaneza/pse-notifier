import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:psenotifier/blocs/alert_list.dart';
import 'package:psenotifier/components/error.dart';
import 'package:psenotifier/components/loading.dart';
import 'package:psenotifier/models/alert.dart';
import 'package:psenotifier/networking/response.dart';

const _title = 'Alerts';
final _currencyFormatter = NumberFormat.currency(symbol: 'PHP');
final _percentFormatter = NumberFormat.decimalPercentPattern(locale: 'en', decimalDigits: 3);

class AlertListScreen extends StatefulWidget {
  AlertListScreen({Key key, this.symbol, this.price}) : super(key: key);

  final double price;
  final String symbol;

  @override
  _AlertListScreenState createState() => _AlertListScreenState();
}

class _AlertListScreenState extends State<AlertListScreen> {
  AlertListBloc bloc;
  String symbol;
  double price;

  @override
  void initState() {
    super.initState();
    price = widget.price;
    symbol = widget.symbol;
    bloc = AlertListBloc(symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_title),
            InkWell(
              child: Icon(Icons.add),
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) => AlertBottomSheet(
                    bloc: bloc,
                    symbol: symbol,
                    price: price,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  symbol,
                  style: TextStyle(fontSize: 18.0),
                ),
                Text(
                  _currencyFormatter.format(price),
                  style: TextStyle(fontSize: 18.0),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<Response<List<Alert>>>(
              stream: bloc.alertListStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  switch (snapshot.data.status) {
                    case Status.LOADING:
                      return Loading(loadingMessage: snapshot.data.message);
                      break;
                    case Status.COMPLETED:
                      return AlertList(
                        alertList: snapshot.data.data,
                        bloc: bloc,
                      );
                      break;
                    case Status.ERROR:
                      return Error(
                        errorMessage: snapshot.data.message,
                        onRetryPressed: () => bloc.getStockAlerts(symbol),
                      );
                      break;
                  }
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AlertBottomSheet extends StatefulWidget {
  AlertBottomSheet({Key key, this.symbol, this.bloc, this.price}) : super(key: key);

  final AlertListBloc bloc;
  final String symbol;
  final double price;

  @override
  _AlertBottomSheetState createState() => _AlertBottomSheetState();
}

class _AlertBottomSheetState extends State<AlertBottomSheet> {
  AlertListBloc bloc;
  Color trackBarColor;
  double priceChange = 0;
  double priceValue;
  double initPrice;
  double min;
  double max;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;
    trackBarColor = Colors.transparent;
    initPrice = priceValue = widget.price;
    min = (priceValue.ceil() - 500).toDouble();
    max = (priceValue.ceil() + 500).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250.0,
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                ),
                child: Center(
                  child: Text(
                    'New price alert',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12.0,
                right: 15.0,
                child: InkWell(
                  child: Icon(Icons.close),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          Divider(
            height: 1.0,
            color: Colors.white24,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Below',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: priceValue < initPrice
                        ? Colors.blueAccent
                        : Colors.white,
                  ),
                ),
                Column(
                  children: <Widget>[
                    Text(
                      _currencyFormatter.format(priceValue),
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    Text(
                      _percentFormatter.format(priceChange),
                      style: TextStyle(
                        fontSize: 14.0,
                        color: initPrice == priceValue ? Colors.white24 : trackBarColor
                      ),
                    ),
                  ],
                ),
                Text(
                  'Above',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: priceValue > initPrice
                        ? Colors.blueAccent
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          FlutterSlider(
            values: [priceValue],
            max: max,
            min: min,
            step: FlutterSliderStep(step: 1),
            centeredOrigin: true,
            trackBar: FlutterSliderTrackBar(
              activeTrackBar: BoxDecoration(color: trackBarColor),
              inactiveTrackBar: BoxDecoration(color: Colors.white24),
            ),
            handler: buildSliderHandler(Icons.drag_handle),
            onDragging: (handlerIndex, lowerValue, upperValue) {
              setState(() {
                priceChange =  (lowerValue - initPrice) / initPrice;
                if (lowerValue > initPrice) {
                  trackBarColor = Colors.green;
                } else {
                  trackBarColor = Colors.red;
                }
                priceValue = lowerValue;
              });
            },
          ),
          Spacer(),
          SizedBox(
            child: FlatButton(
              child: Text(
                'CREATE ALERT',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              color: Colors.blueAccent,
              onPressed: priceValue != initPrice ? createAlert : null,
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            width: double.infinity,
          )
        ],
      ),
    );
  }

  createAlert() {
    Alert alert = Alert();
    alert.symbol = widget.symbol;
    alert.price = priceValue;
    alert.isEnable = true;
    alert.isAbove = priceValue > initPrice;

    bloc.createAlert(alert);
    Navigator.pop(context);
  }

  FlutterSliderHandler buildSliderHandler(IconData icon) {
    return FlutterSliderHandler(
      decoration: BoxDecoration(),
      child: Container(
        child: Container(
          margin: EdgeInsets.all(5),
          child: Icon(
            icon,
            color: Colors.black87,
            size: 23,
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              spreadRadius: 0.05,
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertList extends StatefulWidget {
  AlertList({Key key, this.alertList, this.bloc}) : super(key: key);

  final List<Alert> alertList;
  final AlertListBloc bloc;

  @override
  _AlertListState createState() => _AlertListState();
}

class _AlertListState extends State<AlertList> {
  List<Alert> alertList;
  AlertListBloc bloc;

  @override
  void initState() {
    super.initState();
//    alertList = [];
//    Alert alert1 = new Alert(
//        isAbove: true, symbol: 'ABS', price: 29.0, isEnable: true, id: 1);
//    Alert alert2 = new Alert(
//        isAbove: false, symbol: 'ABS', price: 29.0, isEnable: false, id: 2);
//    alertList.add(alert1);
//    alertList.add(alert2);
    alertList = widget.alertList;
    bloc = widget.bloc;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        Alert alert = alertList[index];
        IconData icon = alert.isAbove
            ? FontAwesomeIcons.arrowAltCircleUp
            : FontAwesomeIcons.arrowAltCircleDown;
        return Dismissible(
          key: Key(alert.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: AlignmentDirectional.centerEnd,
            color: Colors.white24,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Icon(FontAwesomeIcons.trash,
                color: Colors.white,
              ),
            ),
          ),
          onDismissed: (direction) {
            bloc.deleteAlert(alert.id);
          },
          child: ListTile(
            title: Text(
                '${alert.isAbove ? 'Above' : 'Below'} ${_currencyFormatter.format(alert.price)}'),
            leading: Icon(
              icon,
              size: 25.0,
              color: Colors.grey,
            ),
            trailing: Switch(
              value: alert.isEnable,
              onChanged: (enable) {
                bloc.toggleAlertNotification(alert);
              },
              activeColor: Colors.blueAccent,
            ),
          ),
        );
      },
      itemCount: alertList.length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
    );
  }
}
