import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/store/store_view_model.dart';

class ClientViewModel extends StoreViewModel {

  final Client client;

  ClientViewModel(this.client, Store store, DocumentReference userRef) : super(store, userRef);

}