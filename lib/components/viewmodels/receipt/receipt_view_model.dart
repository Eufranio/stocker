import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/receipt.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/stock/stock_view_model.dart';

class ReceiptViewModel extends StockViewModel {

  final Receipt receipt;

  ReceiptViewModel(this.receipt, Stock stock, Product product, Store store, DocumentReference userRef)
      : super(stock, product, store, userRef);

}