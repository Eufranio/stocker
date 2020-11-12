import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/store/store_view_model.dart';

class ProductListViewModel extends StoreViewModel {

  ProductListViewModel(Store store, DocumentReference userRef) : super(store, userRef);

  Stream<List<Product>> get products => userRef.collection('products')
      .snapshots()
      .map((snapshot) => snapshot.documents.map((e) => Product.fromMap(e.documentID, e.data)).toList().cast<Product>());

  Future<List<Product>> search(String str) async {
    return products.first.then((list) => list.where((element) => element.name.toLowerCase().startsWith(str.toLowerCase())).toList());
  }

  Future<void> createProduct(String name) {
    return userRef.collection('products')
        .document()
        .setData(Product(null, name).toJson());
  }

}