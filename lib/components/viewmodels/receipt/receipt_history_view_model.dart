import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/receipt.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/receipt/receipt_view_model.dart';
import 'package:stocker/components/viewmodels/stock/stock_view_model.dart';

class ReceiptHistoryViewModel extends StockViewModel {

  ReceiptHistoryViewModel(
      Store store,
      Stock stock,
      Product product,
      DocumentReference userRef)
      : super(stock, product, store, userRef);

  List<bool> buttons = [
    true,  // 15 days
    false, // 30 days
    false  // all
  ];

  String get amountAvailable => '${stock.quantity} ${stock.unity}';

  DateTime get date =>
      buttons[0] ? DateTime.now().subtract(Duration(days: 15)) :
      buttons[1] ? DateTime.now().subtract(Duration(days: 30)) :
      DateTime(2020); // 01/01/2020

  Stream<List<Receipt>> get receipts => userRef.collection('stores')
      .document(store.id)
      .collection('stocks')
      .document(stock.id)
      .collection('receipts')
      .orderBy('date', descending: true)
      .where('date', isGreaterThan: date)
      .snapshots()
      .map((snapshot) => snapshot.documents.map((e) => Receipt.fromMap(e.documentID, e.data)).toList().cast<Receipt>());

  void selectButton(int index) {
    buttons = [ false, false, false ];
    buttons[index] = true;
  }

  Stream<dynamic> getReceiptClient(Receipt receipt) {
    Future<dynamic> future = receipt.client_id == null ? Future.value(true) : userRef.collection('stores')
        .document(store.id)
        .collection('clients')
        .document(receipt.client_id)
        .get();
    return future.asStream()
        .map((snapshot) => snapshot is DocumentSnapshot ? Client.fromMap(snapshot.documentID, snapshot.data) : true);
  }

  Future<void> deleteReceipt(Receipt receipt) =>
      userRef.collection('stores')
          .document(store.id)
          .collection('stocks')
          .document(stock.id)
          .collection('receipts')
          .document(receipt.id)
          .delete();

}