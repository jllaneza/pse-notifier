import 'dart:async';

import 'package:psenotifier/models/alert.dart';
import 'package:psenotifier/networking/response.dart';
import 'package:psenotifier/repositories/alert_list.dart';

class AlertListBloc {
  AlertListRepository _alertRepository;
  StreamController _alertListController;
  List<Alert> _alertList = [];

  StreamSink<Response<List<Alert>>> get alertListSink =>
      _alertListController.sink;

  Stream<Response<List<Alert>>> get alertListStream =>
      _alertListController.stream;

  AlertListBloc(String symbol) {
    _alertListController = StreamController<Response<List<Alert>>>();
    _alertRepository = AlertListRepository();
    getStockAlerts(symbol);
  }

  getStockAlerts(String symbol) async {
    alertListSink.add(Response.loading('Getting Alert List.'));
    try {
      _alertList = await _alertRepository.getStockAlerts(symbol);

      alertListSink.add(Response.completed(_alertList));
    } catch (e) {
      alertListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  createAlert(Alert alert) async {
    int id = await _alertRepository.createAlert(alert);
    alert.id = id;
    _alertList.add(alert);
    alertListSink.add(Response.completed(_alertList));
  }

  toggleAlertNotification(Alert alert) async {
    int index = _alertList.indexWhere((a) => a.id == alert.id);
    _alertList[index].isEnable = !_alertList[index].isEnable;
    await _alertRepository.updateAlert(alert);
    alertListSink.add(Response.completed(_alertList));
  }

  deleteAlert(int id) async {
    await _alertRepository.deleteAlert(id);
    _alertList.removeWhere((alert) => alert.id == id);
    alertListSink.add(Response.completed(_alertList));
  }

  dispose() {
    _alertListController?.close();
  }
}
