import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/receipt.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/receipt/receipt_view_model.dart';

class EditReceiptViewModel extends ReceiptViewModel {

  EditReceiptViewModel(
      Receipt receipt,
      Stock stock,
      Product product,
      Store store,
      DocumentReference userRef)
      : super(receipt, stock, product, store, userRef);

  Client selectedClient;
  List<bool> buttons = [
    true, // adding
    false // removing
  ];

  bool get isAdding => buttons[0];

  bool get isRemoving => buttons[1];

  bool get isClientFieldEnabled => selectedClient != null;

  String get selectedClientName => selectedClient != null ? '${selectedClient.name} (${selectedClient.city})' : null;

  String validateField(String field) => (field == null || field.isEmpty) ? 'Esse campo não pode ser vazio!' : null;

  String validateClient() => validateField(receipt.client_id);

  String validateQuantity(String quantity) {
    var validateField = this.validateField(quantity);
    if (validateField != null)
      return validateField;

    int amount = int.parse(quantity);
    if (isRemoving) {
      if (amount > stock.quantity)
        return 'Menor que estoque!';
    }

    return null;
  }

  void saveReceiptSeller(String name) => this.receipt.client_name = name;

  void saveClientId() => this.receipt.client_id = selectedClient.id;

  void saveReceiptDescription(String description) => this.receipt.description = description;

  void resetClient() {
    this.selectedClient = null;
    this.receipt.client_id = null;
  }

  void saveQuantity(String quantity) {
    int amount = int.parse(quantity);
    this.receipt.amount = amount;
    if (isAdding) {
      stock.quantity += amount;
      receipt.adding = true;
    } else {
      stock.quantity -= amount;
      receipt.adding = false;
    }
  }

  void selectClient(Client client) {
    this.selectedClient = client;
    this.receipt.client_id = client?.id;
  }

  void pushButton(int index) {
    if (index == 0) {
      buttons = [true, false];
    } else if (index == 1) {
      buttons = [false, true];
    }
  }

  Future<void> saveReceipt() {
    this.receipt.date = DateTime.now();
    var ref = userRef.collection('stores')
        .document(store.id)
        .collection('stocks')
        .document(stock.id);
    return ref.setData(stock.toJson())
        .then((_) => ref.collection('receipts').document().setData(receipt.toJson()));
  }

}