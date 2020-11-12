import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/store/store_view_model.dart';

class StockListViewModel extends StoreViewModel {

  StockListViewModel(Store store, DocumentReference userRef)
      : super(store, userRef);

  Stream<List<Stock>> get stocks => storeRef.collection('stocks')
      .snapshots()
      .map((snapshot) => snapshot.documents.map((e) => Stock.fromMap(e.documentID, e.data)).toList().cast<Stock>());

  Future<Product> getProduct(Stock stock) {
    return userRef.collection('products')
        .document(stock.product)
        .get()
        .then((value) => Product.fromMap(value.documentID, value.data));
  }

  Future<List<Stock>> search(String str) async {
    var stockToReference = (Stock stock) =>
        this.getProduct(stock)
            .then((prod) => StockProductReference(stock, prod));

    var referenceToStocks = (List<StockProductReference> references) =>
        references.where((ref) => ref.product.name.toLowerCase().startsWith(str.toLowerCase()))
            .map((ref) => ref.stock).toList();

    return stocks.first.then((list) => Future.wait(list.map(stockToReference))
        .then(referenceToStocks));
  }

}

class StockProductReference {
  Stock stock;
  Product product;
  StockProductReference(this.stock, this.product);
}