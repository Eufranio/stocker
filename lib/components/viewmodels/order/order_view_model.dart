import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/components/models/order.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/stock/stock_view_model.dart';

class OrderViewModel extends StockViewModel {

  final Order order;

  OrderViewModel(this.order, Stock stock, Product product, Store store, DocumentReference userRef)
      : super(stock, product, store, userRef);

}