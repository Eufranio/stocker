import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/store/store_view_model.dart';

class ClientListViewModel extends StoreViewModel {

  ClientListViewModel(Store store, DocumentReference userRef) : super(store, userRef);

  String get appBarTitle => 'Clientes de ${store.name}';

  Stream<List<Client>> get clients => userRef.collection('stores')
      .document(store.id)
      .collection('clients')
      .snapshots()
      .map((snapshot) => snapshot.documents.map((e) => Client.fromMap(e.documentID, e.data)).toList().cast<Client>());

  Future<List<Client>> search(String str) async {
    return clients.first.then((list) => list.where((element) => element.name.toLowerCase().startsWith(str.toLowerCase())).toList());
  }

}