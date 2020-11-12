import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/product/product_view_model.dart';

class StockViewModel extends ProductViewModel {

  final Stock stock;

  StockViewModel(this.stock, Product product, Store store, DocumentReference userRef)
      : super(product, store, userRef);

}