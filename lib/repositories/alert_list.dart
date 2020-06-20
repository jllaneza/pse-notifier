import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:psenotifier/models/alert.dart';

const _alertCollection = 'Alert';
const _userDeviceCollection = 'UserDevice';

class AlertListRepository {
  Future<CollectionReference> get collectionRef async {
    String token = await FirebaseMessaging().getToken();
    return Firestore.instance
        .collection(_userDeviceCollection)
        .document(token)
        .collection(_alertCollection);
  }

  Future<String> createAlert(Alert alert) async {
    DocumentReference documentRef = await collectionRef.then((ref) => ref.add(alert.toJson()));
    return documentRef.documentID;
  }

  Future<bool> updateAlert(Alert alert) async {
    Map<String, dynamic> data = alert.toJson();
    bool success = false;

    try {
      await collectionRef.then((ref) => ref.document(alert.id).updateData(data));
      success = true;
    } catch (e) {
      print(e.toString());
    }
    return success;
  }

  Future<List<Alert>> getStockAlerts(String symbol) async {
    QuerySnapshot snapshot = await collectionRef.then((ref) => ref.where('symbol', isEqualTo: symbol).getDocuments());
    List<DocumentSnapshot> documents = snapshot.documents ?? [];
    return documents.map((element) {
      Alert alert = Alert.fromJson(element.data);
      alert.id = element.documentID;
      return alert;
    }).toList();
  }

  Future<bool> deleteAlert(String id) async {
    bool success = false;
    try {
      await collectionRef.then((ref) => ref.document(id).delete());
      success = true;
    } catch (e) {
      print(e.toString());
    }
    return success;
  }
}